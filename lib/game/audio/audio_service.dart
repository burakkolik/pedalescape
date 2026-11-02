/// Runtime audio playback for Pedal Escape.
///
/// [AudioService] owns every `AudioPlayer` in the game. Sound effects and
/// music are synthesised in code (see `sound_bank.dart` and
/// `music_composer.dart`) on background isolates, encoded as WAV and cached
/// in the system temp directory, then played from those files with
/// `DeviceFileSource` (the most reliable source type on Android, and the
/// only one supported by the low-latency SoundPool backend).
///
/// Every public method is fail-safe: audio problems are logged in debug
/// builds and otherwise ignored, and calls made before [AudioService.init]
/// has completed are skipped (music requests are remembered and start as
/// soon as the track is ready).
library;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../../engine/audio/wav_encoder.dart';
import 'music_composer.dart';
import 'music_track.dart';
import 'sfx_id.dart';
import 'sound_bank.dart';

/// Game-wide audio facade: pooled sound effects and crossfaded music loops.
class AudioService {
  AudioService._();

  /// The single shared instance.
  static final AudioService instance = AudioService._();

  /// Number of pooled SFX players (max simultaneous effects).
  static const int sfxPoolSize = 6;

  /// Bump whenever recipes change to invalidate cached music files.
  static const String _cacheVersion = 'v1';
  static const Duration _crossfadeTime = Duration(milliseconds: 700);
  static const Duration _fadeTick = Duration(milliseconds: 50);

  // -- settings -------------------------------------------------------------

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.6;
  double _sfxVolume = 1;

  /// Whether sound effects play. Disabling stops effects immediately.
  bool get sfxEnabled => _sfxEnabled;
  set sfxEnabled(bool value) {
    if (_sfxEnabled == value) return;
    _sfxEnabled = value;
    if (!value) _stopAllSfx();
  }

  /// Whether music plays. Toggling pauses / resumes the current track.
  bool get musicEnabled => _musicEnabled;
  set musicEnabled(bool value) {
    if (_musicEnabled == value) return;
    _musicEnabled = value;
    if (value) {
      _resumeMusic();
    } else {
      _haltMusic(pause: true);
    }
  }

  /// Music volume in 0..1, applied immediately.
  double get musicVolume => _musicVolume;
  set musicVolume(double value) {
    _musicVolume = value.isFinite ? value.clamp(0.0, 1.0) : _musicVolume;
    if (_fadeTimer == null) _safe(() => _activeMusic?.setVolume(_musicVolume));
  }

  /// Master gain for sound effects in 0..1 (multiplied with per-call volume).
  double get sfxVolume => _sfxVolume;
  set sfxVolume(double value) {
    _sfxVolume = value.isFinite ? value.clamp(0.0, 1.0) : _sfxVolume;
  }

  /// True once [init] has rendered the sound effects and created players.
  bool get isReady => _ready;

  // -- state ----------------------------------------------------------------

  Future<void>? _initFuture;
  bool _ready = false;
  bool _paused = false;
  String? _cacheDir;
  final Stopwatch _clock = Stopwatch()..start();

  final List<_SfxSlot> _pool = [];
  int _cursor = 0;
  final Map<SfxId, _SfxFile> _sfxFiles = {};

  final Map<MusicTrack, Future<String?>> _musicFiles = {};
  final List<AudioPlayer?> _musicPlayers = [null, null];
  int _activeIndex = 0;
  MusicTrack? _activeTrack; // Track loaded in the active music player.
  MusicTrack? _track; // Track the game wants to hear.
  int _musicToken = 0;
  Timer? _fadeTimer;
  AudioPlayer? _fadingOut;
  Future<void> _musicLock = Future.value();

  AudioPlayer? get _activeMusic => _musicPlayers[_activeIndex];

  static final AudioContext _sfxContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.game,
      // Effects must never steal focus from our own music player.
      audioFocus: AndroidAudioFocus.none,
    ),
  );

  static final AudioContext _musicContext = AudioContext(
    android: const AudioContextAndroid(
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

  // -- lifecycle ------------------------------------------------------------

  /// Creates players, pre-renders all sound effects and starts rendering the
  /// music loops in the background. Safe to call repeatedly.
  Future<void> init() => _initFuture ??= _init().catchError((Object e) {
    _log('init failed', e);
  });

  Future<void> _init() async {
    final dir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}pedalescape_audio',
    );
    await dir.create(recursive: true);
    _cacheDir = dir.path;

    for (var i = 0; i < sfxPoolSize; i++) {
      final slot = await _createSfxSlot(i);
      if (slot != null) _pool.add(slot);
    }

    final files = await _renderSfxFiles(dir.path);
    _sfxFiles.addAll(files);
    _ready = true;

    // Music: start the requested track (if any), then warm the rest.
    unawaited(_warmMusic());
    if (_track != null && _musicEnabled && !_paused) {
      unawaited(_startTrack(_track!, _musicToken));
    }
  }

  /// Pauses music and silences effects (e.g. app moved to background).
  void pauseAll() {
    _paused = true;
    _stopAllSfx();
    _haltMusic(pause: true);
  }

  /// Resumes whatever [pauseAll] interrupted.
  void resumeAll() {
    if (!_paused) return;
    _paused = false;
    _resumeMusic();
  }

  // -- sound effects --------------------------------------------------------

  /// Plays [id] at [volume] (0..1) and playback [rate] (0.5..2, also shifts
  /// pitch). Fire-and-forget; silently skipped if audio is unavailable.
  void playSfx(SfxId id, {double volume = 1, double rate = 1}) {
    try {
      if (!_sfxEnabled || _paused || !_ready || _pool.isEmpty) return;
      final file = _sfxFiles[id];
      if (file == null) return;
      final vol = (volume.isFinite ? volume : 1.0).clamp(0.0, 1.0) * _sfxVolume;
      if (vol <= 0) return;
      final r = (rate.isFinite ? rate : 1.0).clamp(0.5, 2.0);

      final slot = _pickSlot(id);
      if (slot == null) return;
      final now = _clock.elapsedMilliseconds;
      slot
        ..busy = true
        ..idleAt = now + (file.seconds * 1000 / r).ceil() + 30
        ..startedAt = now;
      unawaited(
        _startSfx(slot, id, file.path, vol, r)
            .catchError((Object e) {
              slot.loaded = null;
              _log('playSfx($id) failed', e);
            })
            .whenComplete(() => slot.busy = false),
      );
    } catch (e) {
      _log('playSfx($id) failed', e);
    }
  }

  /// Chooses a player: idle with the sound already loaded, else the least
  /// recently used idle player, else steal the oldest playing one.
  _SfxSlot? _pickSlot(SfxId id) {
    final now = _clock.elapsedMilliseconds;
    _SfxSlot? idle;
    _SfxSlot? oldest;
    for (var k = 0; k < _pool.length; k++) {
      final slot = _pool[(_cursor + k) % _pool.length];
      if (slot.busy) continue;
      if (slot.idleAt <= now) {
        if (slot.loaded == id) return _advance(slot);
        if (idle == null || slot.idleAt < idle.idleAt) idle = slot;
      } else if (oldest == null || slot.startedAt < oldest.startedAt) {
        oldest = slot;
      }
    }
    final chosen = idle ?? oldest;
    return chosen == null ? null : _advance(chosen);
  }

  _SfxSlot _advance(_SfxSlot slot) {
    _cursor = (_pool.indexOf(slot) + 1) % _pool.length;
    return slot;
  }

  Future<void> _startSfx(
    _SfxSlot slot,
    SfxId id,
    String path,
    double volume,
    double rate,
  ) async {
    final p = slot.player;
    // SoundPool never reports completion, so always stop before restarting.
    await p.stop();
    if (slot.loaded != id) {
      slot.loaded = null;
      await p.setSource(DeviceFileSource(path, mimeType: 'audio/wav'));
      slot.loaded = id;
    }
    if (slot.volume != volume) {
      await p.setVolume(volume);
      slot.volume = volume;
    }
    if (slot.rate != rate) {
      await p.setPlaybackRate(rate);
      slot.rate = rate;
    }
    if (!_sfxEnabled || _paused) return;
    await p.resume();
  }

  void _stopAllSfx() {
    for (final slot in _pool) {
      slot.idleAt = 0;
      _safe(slot.player.stop);
    }
  }

  // -- music ----------------------------------------------------------------

  /// Starts looping [track], crossfading from the current one. No-op when
  /// [track] is already the current track.
  Future<void> playMusic(MusicTrack track) async {
    try {
      if (_track == track) return;
      _track = track;
      final token = ++_musicToken;
      if (!_musicEnabled || _paused || !_ready) return;
      await _startTrack(track, token);
    } catch (e) {
      _log('playMusic($track) failed', e);
    }
  }

  /// Fades out and stops the current music.
  Future<void> stopMusic() async {
    try {
      _track = null;
      ++_musicToken;
      final player = _activeMusic;
      if (player == null || _activeTrack == null) return;
      _activeTrack = null;
      _crossfade(from: player, to: null);
    } catch (e) {
      _log('stopMusic failed', e);
    }
  }

  Future<void> _startTrack(MusicTrack track, int token) async {
    final path = await _ensureMusic(track);
    if (path == null || !_isCurrent(token)) return;
    // Serialise player switching so rapid track changes never interleave
    // commands on the same player.
    final run = _musicLock.then((_) => _switchTo(track, path, token));
    _musicLock = run;
    await run;
  }

  Future<void> _switchTo(MusicTrack track, String path, int token) async {
    try {
      if (!_isCurrent(token)) return;
      if (_activeTrack == track && _activeMusic != null) {
        // Already loaded (e.g. switched away and back mid-fade): just resume.
        final player = _activeMusic!;
        await player.resume();
        _crossfade(to: player);
        return;
      }
      final nextIndex = 1 - _activeIndex;
      final next = _musicPlayers[nextIndex] ??= await _createMusicPlayer(
        nextIndex,
      );
      if (next == null || !_isCurrent(token)) return;
      if (identical(next, _fadingOut)) _finishFade();

      await next.stop();
      await next.setVolume(0);
      await next.play(DeviceFileSource(path, mimeType: 'audio/wav'));
      if (!_isCurrent(token)) {
        _safe(next.stop);
        return;
      }

      final previous = _activeMusic;
      _activeIndex = nextIndex;
      _activeTrack = track;
      _crossfade(from: previous, to: next);
    } catch (e) {
      _log('starting $track failed', e);
    }
  }

  bool _isCurrent(int token) =>
      token == _musicToken && _musicEnabled && !_paused;

  /// Stops or pauses music output without forgetting the desired track.
  void _haltMusic({required bool pause}) {
    _finishFade();
    final player = _activeMusic;
    if (player == null) return;
    _safe(pause ? player.pause : player.stop);
  }

  /// Resumes the desired track after a pause or re-enable.
  void _resumeMusic() {
    final track = _track;
    if (track == null || !_musicEnabled || _paused || !_ready) return;
    final player = _activeMusic;
    if (player != null && _activeTrack == track) {
      _safe(() async {
        await player.setVolume(_musicVolume);
        await player.resume();
      });
    } else {
      unawaited(_startTrack(track, ++_musicToken));
    }
  }

  /// Linear crossfade; [to] ramps up to [musicVolume], [from] down and stops.
  void _crossfade({AudioPlayer? from, AudioPlayer? to}) {
    _finishFade();
    final out = identical(from, to) ? null : from;
    _fadingOut = out;
    final steps = _crossfadeTime.inMilliseconds ~/ _fadeTick.inMilliseconds;
    final outStart = out?.volume ?? 0;
    final inStart = to?.volume ?? 0;
    var i = 0;
    _fadeTimer = Timer.periodic(_fadeTick, (timer) {
      i++;
      final x = (i / steps).clamp(0.0, 1.0);
      if (out != null) _safe(() => out.setVolume(outStart * (1 - x)));
      if (to != null) {
        _safe(() => to.setVolume(inStart + (_musicVolume - inStart) * x));
      }
      if (i >= steps) _finishFade();
    });
  }

  /// Completes any running fade immediately.
  void _finishFade() {
    final timer = _fadeTimer;
    if (timer == null) return;
    timer.cancel();
    _fadeTimer = null;
    final out = _fadingOut;
    _fadingOut = null;
    if (out != null) _safe(out.stop);
    final active = _activeMusic;
    if (active != null && _activeTrack != null) {
      _safe(() => active.setVolume(_musicVolume));
    }
  }

  /// Returns the cached WAV path for [track], rendering it if necessary.
  Future<String?> _ensureMusic(MusicTrack track) {
    final dir = _cacheDir;
    if (dir == null) return Future.value();
    return _musicFiles[track] ??= _renderMusicFile(track, dir).catchError((
      Object e,
    ) {
      _log('rendering $track failed', e);
      _musicFiles.remove(track); // Allow a retry later.
      return null;
    });
  }

  Future<void> _warmMusic() async {
    final order = [?_track, ...MusicTrack.values.where((t) => t != _track)];
    for (final track in order) {
      await _ensureMusic(track);
    }
  }

  // -- player creation ------------------------------------------------------

  Future<_SfxSlot?> _createSfxSlot(int index) async {
    try {
      final player = AudioPlayer(playerId: 'pedalescape_sfx_$index');
      try {
        await player.setPlayerMode(PlayerMode.lowLatency);
      } catch (e) {
        _log('lowLatency unsupported, using mediaPlayer', e);
      }
      await player.setAudioContext(_sfxContext);
      await player.setReleaseMode(ReleaseMode.stop);
      return _SfxSlot(player);
    } catch (e) {
      _log('creating SFX player $index failed', e);
      return null;
    }
  }

  Future<AudioPlayer?> _createMusicPlayer(int index) async {
    try {
      final player = AudioPlayer(playerId: 'pedalescape_music_$index');
      await player.setAudioContext(_musicContext);
      await player.setReleaseMode(ReleaseMode.loop);
      return player;
    } catch (e) {
      _log('creating music player $index failed', e);
      return null;
    }
  }

  // -- background rendering -------------------------------------------------

  /// Renders every SFX to `<dir>/sfx_<name>.wav` off the UI isolate.
  static Future<Map<SfxId, _SfxFile>> _renderSfxFiles(String dir) =>
      _inBackground(() => _writeAllSfx(dir));

  static Map<SfxId, _SfxFile> _writeAllSfx(String dir) {
    final result = <SfxId, _SfxFile>{};
    for (final id in SfxId.values) {
      try {
        final samples = SoundBank.render(id);
        final path = '$dir${Platform.pathSeparator}sfx_${id.name}.wav';
        _writeAtomically(
          path,
          WavEncoder.encode(samples, sampleRate: SoundBank.sampleRate),
        );
        result[id] = _SfxFile(path, samples.length / SoundBank.sampleRate);
      } catch (_) {
        // Skip just this effect; the rest of the bank stays usable.
      }
    }
    return result;
  }

  /// Renders [track] to a cached WAV file (reused across launches).
  static Future<String?> _renderMusicFile(MusicTrack track, String dir) async {
    final path =
        '$dir${Platform.pathSeparator}music_${track.name}_$_cacheVersion.wav';
    final file = File(path);
    if (await file.exists() && await file.length() > WavEncoder.headerSize) {
      return path;
    }
    return _inBackground(() {
      final samples = MusicComposer.render(track);
      _writeAtomically(
        path,
        WavEncoder.encode(samples, sampleRate: MusicComposer.sampleRate),
      );
      return path;
    });
  }

  static void _writeAtomically(String path, Uint8List bytes) {
    final tmp = File('$path.part');
    tmp.writeAsBytesSync(bytes, flush: true);
    tmp.renameSync(path);
  }

  /// Runs [work] on a background isolate, falling back to the current one.
  static Future<T> _inBackground<T>(T Function() work) async {
    try {
      return await Isolate.run(work);
    } on Object catch (e) {
      _log('background isolate unavailable, rendering inline', e);
      return work();
    }
  }

  // -- helpers --------------------------------------------------------------

  /// Runs [action] (sync or async) swallowing every error.
  static void _safe(FutureOr<void> Function() action) {
    try {
      final result = action();
      if (result is Future<void>) {
        unawaited(result.catchError((Object e) => _log('audio call', e)));
      }
    } catch (e) {
      _log('audio call', e);
    }
  }

  static void _log(String message, Object error) {
    if (kDebugMode) debugPrint('[AudioService] $message: $error');
  }
}

/// A pooled SFX player and what it currently has loaded.
class _SfxSlot {
  _SfxSlot(this.player);

  final AudioPlayer player;
  SfxId? loaded;
  bool busy = false;
  int idleAt = 0;
  int startedAt = 0;
  double volume = 1;
  double rate = 1;
}

/// Location and duration of a rendered SFX file.
class _SfxFile {
  const _SfxFile(this.path, this.seconds);

  final String path;
  final double seconds;
}
