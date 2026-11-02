/// Procedural, seamlessly looping background music for each [MusicTrack].
///
/// A track is described by a declarative [_Style] (tempo, scale, chord
/// progression, step patterns, timbres). The composer renders five layers —
/// drums, bass, chord pad, arpeggio and a generated lead melody — into a
/// single mono loop. Every voice writes with wrap-around, so note and echo
/// tails spill into the loop head and the loop point is inaudible.
///
/// Rendering is deterministic (seeded) and CPU-heavy (~1 s per track on a
/// phone), so callers should run [MusicComposer.render] on a background
/// isolate.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../engine/audio/envelope.dart';
import '../../engine/audio/filters.dart';
import '../../engine/audio/oscillators.dart';
import '../../engine/audio/synth_voice.dart';
import 'music_track.dart';

/// Renders procedural music loops.
abstract final class MusicComposer {
  /// Sample rate of rendered music, in Hz.
  static const int sampleRate = 22050;

  /// Peak level of the rendered loop.
  static const double masterPeak = 0.85;

  /// Length of the loop for [track] in seconds.
  static double loopSeconds(MusicTrack track) => _styleFor(track).loopSeconds;

  /// Renders one full loop of [track] as mono samples in [-1, 1].
  static Float32List render(MusicTrack track) =>
      _Composer(_styleFor(track)).render();
}

// ---------------------------------------------------------------------------
// Style definitions
// ---------------------------------------------------------------------------

const List<int> _major = [0, 2, 4, 5, 7, 9, 11];
const List<int> _minor = [0, 2, 3, 5, 7, 8, 10];
const List<int> _dorian = [0, 2, 3, 5, 7, 9, 10];
const List<int> _harmonicMinor = [0, 2, 3, 5, 7, 8, 11];

/// Declarative description of a track. Step patterns use 16 steps per bar:
///
/// * drums: `X` accent, `x` normal, `o` ghost, `.` rest;
/// * bass: `R` root, `T` third, `F` fifth, `O` octave, `-` tie, `.` rest;
/// * pad: `X` chord onset, `-` tie, `.` rest.
class _Style {
  const _Style({
    required this.bpm,
    required this.bars,
    required this.root,
    required this.scale,
    required this.progression,
    required this.kick,
    required this.snare,
    required this.hat,
    required this.bass,
    required this.pad,
    required this.leadPlan,
    required this.seed,
    this.openHat = '................',
    this.fill = '................',
    this.swing = 0,
    this.sevenths = false,
    this.bassWave = Waveform.saw,
    this.bassCutoff = 900,
    this.padWave = Waveform.saw,
    this.padCutoff = 1400,
    this.padEnvelope = const Adsr.pad(),
    this.padGain = 0.3,
    this.leadWave = Waveform.square,
    this.leadPulse = 0.5,
    this.leadCutoff = 3000,
    this.leadGain = 0.32,
    this.leadVibrato = 0.15,
    this.leadDensity = 0.55,
    this.leadEcho = 0.3,
    this.arpEvery = 0,
    this.arpGain = 0.12,
    this.drumGain = 0.9,
    this.sidechain = 0.0,
    this.lofi = false,
    this.riser = false,
    this.crashBars = const [],
  });

  final double bpm;
  final int bars;

  /// MIDI note of the tonic (lead register; bass and pad derive from it).
  final int root;
  final List<int> scale;

  /// Scale degree (0-based) of the chord for each bar, cycled.
  final List<int> progression;
  final String kick, snare, hat, openHat, bass, pad;

  /// Extra snare hits on the last bar of every 8-bar block.
  final String fill;

  /// Swing amount (0..0.5) applied to off-beat 16ths/8ths.
  final double swing;
  final bool sevenths;
  final Waveform bassWave, padWave, leadWave;
  final double bassCutoff, padCutoff, padGain;
  final Adsr padEnvelope;
  final double leadPulse, leadCutoff, leadGain, leadVibrato, leadDensity;
  final double leadEcho;

  /// One letter per 4-bar phrase; equal letters repeat the same melody and
  /// `-` leaves the phrase without lead.
  final List<String> leadPlan;

  /// Arpeggio step size in 16ths (0 = no arpeggio).
  final int arpEvery;
  final double arpGain, drumGain;

  /// Depth of the kick-triggered volume ducking on bass/pad (0..1).
  final double sidechain;
  final bool lofi;

  /// Adds a noise riser on the last bar of every 8 bars.
  final bool riser;
  final List<int> crashBars;
  final int seed;

  double get beat => 60 / bpm;
  double get step => beat / 4;
  double get bar => beat * 4;
  double get loopSeconds => bar * bars;
}

_Style _styleFor(MusicTrack track) => switch (track) {
  // Chill, upbeat: bright major I–V–vi–IV with off-beat hats.
  MusicTrack.menu => const _Style(
    bpm: 104,
    bars: 16,
    root: 72,
    scale: _major,
    progression: [0, 4, 5, 3],
    kick: 'X.....x...x.....',
    snare: '....x.......x...',
    hat: '..x...x...x...xo',
    openHat: '..............x.',
    bass: 'R..R..F.R...O.F.',
    pad: 'X---------------',
    padWave: Waveform.triangle,
    padCutoff: 2200,
    padGain: 0.32,
    bassWave: Waveform.triangle,
    bassCutoff: 1200,
    leadWave: Waveform.square,
    leadPulse: 0.25,
    leadCutoff: 2600,
    leadGain: 0.26,
    leadDensity: 0.5,
    leadPlan: ['A', 'B', 'A', 'C'],
    arpEvery: 2,
    arpGain: 0.1,
    sidechain: 0.25,
    crashBars: [0],
    seed: 101,
  ),
  // Energetic, driving: A minor four-on-the-floor with 16th arps.
  MusicTrack.mission => const _Style(
    bpm: 128,
    bars: 16,
    root: 69,
    scale: _minor,
    progression: [0, 5, 2, 6],
    kick: 'X...x...x...x...',
    snare: '....X.......X...',
    hat: 'x.x.x.x.x.x.x.x.',
    openHat: '..x...x...x...x.',
    fill: '........o.x.xXxX',
    bass: 'R.RR.RR.R.RF.FO.',
    pad: 'X---------------',
    bassWave: Waveform.saw,
    bassCutoff: 1100,
    padCutoff: 1600,
    padGain: 0.22,
    leadWave: Waveform.saw,
    leadCutoff: 3200,
    leadGain: 0.26,
    leadDensity: 0.65,
    leadVibrato: 0.2,
    leadPlan: ['-', 'A', 'B', 'A'],
    arpEvery: 1,
    arpGain: 0.11,
    sidechain: 0.5,
    crashBars: [0, 4, 8, 12],
    seed: 202,
  ),
  // Tense, faster: D harmonic minor, syncopated break and rolling bass.
  MusicTrack.endless => const _Style(
    bpm: 150,
    bars: 16,
    root: 62,
    scale: _harmonicMinor,
    progression: [0, 0, 5, 4],
    kick: 'X..x..x...X..x..',
    snare: '....X.......X..o',
    hat: 'xoxoxoxoxoxoxoxo',
    openHat: '......x.......x.',
    fill: '..........o.xXXX',
    bass: 'RRORRFRRRRORRTFR',
    pad: 'X-------X-------',
    bassWave: Waveform.square,
    bassCutoff: 800,
    padCutoff: 1100,
    padGain: 0.2,
    padEnvelope: Adsr.pad(attack: 0.15, release: 0.3),
    leadWave: Waveform.square,
    leadPulse: 0.4,
    leadCutoff: 3600,
    leadGain: 0.24,
    leadDensity: 0.7,
    leadVibrato: 0.25,
    leadPlan: ['A', 'B', 'A', 'C'],
    arpEvery: 1,
    arpGain: 0.09,
    sidechain: 0.45,
    riser: true,
    crashBars: [0, 8],
    seed: 303,
  ),
  // Relaxed lo-fi: swung D dorian seventh chords, soft keys, vinyl crackle.
  MusicTrack.freeRide => const _Style(
    bpm: 82,
    bars: 8,
    root: 62,
    scale: _dorian,
    progression: [1, 4, 0, 5],
    sevenths: true,
    swing: 0.22,
    kick: 'X......x..x.....',
    snare: '....x.......x...',
    hat: 'x.x.x.x.x.x.x.xo',
    bass: 'R.....F...R..O..',
    pad: 'X-----X---------',
    bassWave: Waveform.sine,
    bassCutoff: 600,
    padWave: Waveform.triangle,
    padCutoff: 1800,
    padGain: 0.3,
    padEnvelope: Adsr(attack: 0.01, decay: 1.4, sustain: 0.35, release: 0.5),
    leadWave: Waveform.triangle,
    leadCutoff: 2400,
    leadGain: 0.3,
    leadDensity: 0.35,
    leadVibrato: 0.12,
    leadEcho: 0.4,
    leadPlan: ['A', 'B'],
    drumGain: 0.7,
    lofi: true,
    seed: 404,
  ),
};

// ---------------------------------------------------------------------------
// Composer
// ---------------------------------------------------------------------------

class _LeadNote {
  const _LeadNote(this.step, this.length, this.degree);

  /// Start, in 8th-note steps from the phrase start.
  final int step;

  /// Length in 8th-note steps.
  final int length;

  /// Absolute scale degree relative to the style's root.
  final int degree;
}

class _Composer {
  _Composer(this.s)
    : _len = samplesFor(s.loopSeconds, MusicComposer.sampleRate);

  final _Style s;
  final int _len;
  static const int _sr = MusicComposer.sampleRate;

  Float32List render() {
    final drums = Float32List(_len);
    final ducked = Float32List(_len); // Bass + pad + arp (side-chained).
    final lead = Float32List(_len);

    _renderDrums(drums);
    _renderBass(ducked);
    _renderPad(ducked);
    _renderArp(ducked);
    if (s.sidechain > 0) _applySidechain(ducked);
    _renderLead(lead);
    if (s.leadEcho > 0) {
      applyEcho(
        lead,
        sampleRate: _sr,
        time: s.beat * 0.75,
        feedback: 0.35,
        mix: s.leadEcho,
        damping: 2500,
        wrap: true,
      );
    }

    final master = Float32List(_len);
    for (var i = 0; i < _len; i++) {
      master[i] = drums[i] * s.drumGain + ducked[i] + lead[i];
    }
    if (s.lofi) _applyLofi(master);

    _warmFilter(master, OnePoleHighPass(cutoff: 30, sampleRate: _sr));
    normalize(master, target: 1.0);
    softClip(master, drive: 1.4);
    normalize(master, target: MusicComposer.masterPeak);
    return master;
  }

  // -- timing ---------------------------------------------------------------

  /// Time in seconds of 16th step [i] (absolute), including swing.
  double _stepTime(int i) {
    var t = i * s.step;
    if (s.swing > 0) {
      if (i.isOdd) t += s.swing * s.step;
      if (i % 4 == 2) t += s.swing * s.step;
    }
    return t;
  }

  int get _steps => s.bars * 16;

  double _velocity(String c) => switch (c) {
    'X' => 1.0,
    'x' => 0.75,
    'o' => 0.4,
    _ => 0.0,
  };

  // -- harmony --------------------------------------------------------------

  int _degreeToMidi(int degree, int base) {
    final len = s.scale.length;
    final octave = (degree / len).floor();
    return base + s.scale[degree - octave * len] + 12 * octave;
  }

  /// Chord tone degrees of [chordDegree] (triad or seventh).
  List<int> _chordDegrees(int chordDegree) => [
    chordDegree,
    chordDegree + 2,
    chordDegree + 4,
    if (s.sevenths) chordDegree + 6,
  ];

  int _chordAt(int bar) => s.progression[bar % s.progression.length];

  /// Places pitch class of [midi] inside [low, low + 12).
  int _inRange(int midi, int low) {
    var m = midi;
    while (m < low) {
      m += 12;
    }
    while (m >= low + 12) {
      m -= 12;
    }
    return m;
  }

  // -- drums ----------------------------------------------------------------

  Float32List _kickSample() {
    final out = silence(0.4, sampleRate: _sr);
    renderTone(
      out,
      sampleRate: _sr,
      frequency: s.lofi ? 110 : 160,
      endFrequency: s.lofi ? 45 : 48,
      sweepTime: 0.08,
      duration: 0.01,
      envelope: Adsr(
        attack: 0.001,
        decay: 0,
        sustain: 1,
        release: s.lofi ? 0.22 : 0.3,
      ),
      gain: 0.95,
    );
    renderNoise(
      out,
      sampleRate: _sr,
      duration: 0.012,
      decay: 0.003,
      gain: s.lofi ? 0.1 : 0.3,
      filter: BiquadType.lowPass,
      cutoff: 3000,
    );
    return out;
  }

  Float32List _snareSample() {
    final out = silence(0.3, sampleRate: _sr);
    renderNoise(
      out,
      sampleRate: _sr,
      duration: 0.25,
      decay: s.lofi ? 0.05 : 0.07,
      gain: 0.6,
      filter: BiquadType.bandPass,
      cutoff: s.lofi ? 1500 : 2000,
      q: 0.7,
      seed: 3,
    );
    renderTone(
      out,
      sampleRate: _sr,
      frequency: 200,
      endFrequency: 165,
      duration: 0.01,
      envelope: const Adsr(attack: 0.001, decay: 0, sustain: 1, release: 0.1),
      gain: 0.4,
    );
    return out;
  }

  Float32List _hatSample({required bool open}) {
    final out = silence(open ? 0.3 : 0.06, sampleRate: _sr);
    renderNoise(
      out,
      sampleRate: _sr,
      duration: open ? 0.3 : 0.06,
      decay: open ? 0.07 : 0.012,
      gain: 0.35,
      filter: BiquadType.highPass,
      cutoff: s.lofi ? 5500 : 7000,
      seed: open ? 13 : 9,
    );
    return out;
  }

  Float32List _crashSample() {
    final out = silence(1.6, sampleRate: _sr);
    renderNoise(
      out,
      sampleRate: _sr,
      duration: 1.6,
      decay: 0.45,
      gain: 0.25,
      filter: BiquadType.highPass,
      cutoff: 4500,
      seed: 21,
    );
    return out;
  }

  void _renderDrums(Float32List out) {
    final kick = _kickSample();
    final snare = _snareSample();
    final hat = _hatSample(open: false);
    final openHat = _hatSample(open: true);
    final rng = math.Random(s.seed);

    void hit(Float32List sample, int step, double gain) {
      if (gain <= 0) return;
      mixInto(
        out,
        sample,
        sampleRate: _sr,
        at: _stepTime(step),
        gain: gain,
        wrap: true,
      );
    }

    for (var i = 0; i < _steps; i++) {
      final bar = i ~/ 16;
      final j = i % 16;
      final fillBar = bar % 8 == 7;
      hit(kick, i, _velocity(s.kick[j]));
      final snareChar = fillBar && s.fill[j] != '.' ? s.fill[j] : s.snare[j];
      hit(snare, i, _velocity(snareChar) * 0.8);
      final human = 0.85 + rng.nextDouble() * 0.3;
      if (s.openHat[j] != '.') {
        hit(openHat, i, _velocity(s.openHat[j]) * 0.5 * human);
      } else {
        hit(hat, i, _velocity(s.hat[j]) * 0.55 * human);
      }
    }

    if (s.crashBars.isNotEmpty) {
      final crash = _crashSample();
      for (final b in s.crashBars) {
        if (b < s.bars) hit(crash, b * 16, 1);
      }
    }

    if (s.riser) {
      for (var b = 7; b < s.bars; b += 8) {
        renderNoise(
          out,
          sampleRate: _sr,
          start: b * s.bar,
          duration: s.bar,
          envelope: Adsr(
            attack: s.bar * 0.95,
            decay: 0,
            sustain: 1,
            release: 0.05,
          ),
          gain: 0.25,
          filter: BiquadType.bandPass,
          cutoff: 500,
          cutoffEnd: 6000,
          q: 1.5,
          seed: 31 + b,
          wrap: true,
        );
      }
    }
  }

  // -- bass -----------------------------------------------------------------

  void _renderBass(Float32List out) {
    final bassLow = s.root - 33; // Roughly two octaves under the lead.
    for (var i = 0; i < _steps; i++) {
      final c = s.bass[i % 16];
      if (c == '-' || c == '.') continue;
      var ties = 1;
      while (ties < 8 && s.bass[(i + ties) % 16] == '-') {
        ties++;
      }
      final chord = _chordDegrees(_chordAt(i ~/ 16));
      final rootMidi = _inRange(_degreeToMidi(chord[0], s.root), bassLow);
      final midi = switch (c) {
        'T' =>
          rootMidi + (_degreeToMidi(chord[1], 0) - _degreeToMidi(chord[0], 0)),
        'F' =>
          rootMidi + (_degreeToMidi(chord[2], 0) - _degreeToMidi(chord[0], 0)),
        'O' => rootMidi + 12,
        _ => rootMidi,
      };
      final length = ties * s.step * 0.85;
      renderNote(
        out,
        sampleRate: _sr,
        midi: midi,
        start: _stepTime(i),
        duration: length,
        waveform: s.bassWave,
        envelope: Adsr(
          attack: 0.004,
          decay: 0.12,
          sustain: 0.65,
          release: 0.05,
        ),
        gain: s.bassWave == Waveform.sine ? 0.7 : 0.45,
        lowPass: s.bassCutoff,
        lowPassEnd: s.bassCutoff * 0.6,
        lowPassQ: 1.2,
        wrap: true,
      );
      // Sub reinforcement for thin waveforms.
      if (s.bassWave != Waveform.sine) {
        renderNote(
          out,
          sampleRate: _sr,
          midi: midi,
          start: _stepTime(i),
          duration: length,
          envelope: Adsr(
            attack: 0.004,
            decay: 0.12,
            sustain: 0.7,
            release: 0.05,
          ),
          gain: 0.3,
          wrap: true,
        );
      }
    }
  }

  // -- pad ------------------------------------------------------------------

  void _renderPad(Float32List out) {
    final padLow = s.root - 14;
    for (var i = 0; i < _steps; i++) {
      if (s.pad[i % 16] != 'X') continue;
      var ties = 1;
      while (ties < 16 && s.pad[(i + ties) % 16] == '-') {
        ties++;
      }
      final chord = _chordDegrees(_chordAt(i ~/ 16));
      final length = ties * s.step;
      for (final d in chord) {
        final midi = _inRange(_degreeToMidi(d, s.root), padLow);
        for (final detune
            in s.padWave == Waveform.saw ? const [-7.0, 7.0] : const [0.0]) {
          renderNote(
            out,
            sampleRate: _sr,
            midi: midi,
            detuneCents: detune,
            start: _stepTime(i),
            duration: length,
            waveform: s.padWave,
            envelope: s.padEnvelope,
            gain: s.padGain / chord.length,
            lowPass: s.padCutoff,
            vibratoDepth: s.lofi ? 0.08 : 0,
            vibratoRate: 0.7,
            vibratoDelay: 0,
            wrap: true,
          );
        }
        if (s.lofi) {
          // Electric-piano style bell overtone.
          renderNote(
            out,
            sampleRate: _sr,
            midi: midi + 12,
            start: _stepTime(i),
            duration: 0.02,
            envelope: const Adsr(
              attack: 0.002,
              decay: 0,
              sustain: 1,
              release: 0.6,
            ),
            gain: s.padGain * 0.25 / chord.length,
            wrap: true,
          );
        }
      }
    }
  }

  // -- arpeggio -------------------------------------------------------------

  void _renderArp(Float32List out) {
    if (s.arpEvery <= 0) return;
    for (var i = 0; i < _steps; i += s.arpEvery) {
      final chord = _chordDegrees(_chordAt(i ~/ 16));
      final tones = [
        ...chord,
        chord[0] + 7,
        ...chord.skip(1).map((d) => d + 7),
      ];
      // Up-down pattern across the bar.
      final pos = (i % 16) ~/ s.arpEvery;
      final cycle = tones.length * 2 - 2;
      final k = pos % cycle;
      final idx = k < tones.length ? k : cycle - k;
      renderNote(
        out,
        sampleRate: _sr,
        midi: _degreeToMidi(tones[idx], s.root - 12),
        start: _stepTime(i),
        duration: s.step * s.arpEvery * 0.5,
        waveform: Waveform.square,
        pulseWidth: 0.3,
        envelope: Adsr.pluck(decay: s.step * s.arpEvery * 0.8),
        gain: s.arpGain,
        lowPass: 2800,
        wrap: true,
      );
    }
  }

  // -- lead -----------------------------------------------------------------

  /// Generates a 4-bar phrase on an 8th-note grid.
  List<_LeadNote> _phrase(int seed, int firstBar, int register) {
    final rng = math.Random(seed);
    const steps = 32;
    final notes = <_LeadNote>[];
    var degree = 4 + register;
    final lowest = -2 + register;
    final highest = 9 + register;

    final onsets = <int>[];
    for (var st = 0; st < steps; st++) {
      if (st == 0) {
        onsets.add(st);
        continue;
      }
      if (st > 24) break; // Final bar: one long resolving note.
      if (st == 24) {
        onsets.add(st);
        continue;
      }
      final strong = st % 4 == 0;
      final p = strong
          ? s.leadDensity + 0.25
          : (st.isEven ? s.leadDensity : s.leadDensity * 0.6);
      if (rng.nextDouble() < p) onsets.add(st);
    }

    for (var n = 0; n < onsets.length; n++) {
      final st = onsets[n];
      final next = n + 1 < onsets.length ? onsets[n + 1] : steps;
      final length = math.min(next - st, st == 24 ? 6 : 4);
      final bar = firstBar + st ~/ 8;
      final chord = _chordDegrees(_chordAt(bar));

      if (st % 4 == 0 || st == 24) {
        // Strong beat: land on the nearest chord tone (any octave).
        var best = degree;
        var bestDist = 1 << 20;
        for (final c in chord) {
          for (var o = -14; o <= 14; o += 7) {
            final cand = c + o;
            if (cand < lowest || cand > highest) continue;
            final dist = (cand - degree).abs() + (rng.nextDouble() * 2).floor();
            if (dist < bestDist) {
              bestDist = dist;
              best = cand;
            }
          }
        }
        degree = best;
      } else {
        const moves = [-2, -1, -1, 1, 1, 2, 3, -3];
        var move = moves[rng.nextInt(moves.length)];
        // Drift back towards the centre of the range.
        final centre = (lowest + highest) / 2;
        if (degree > centre + 3 && move > 0) move = -move;
        if (degree < centre - 3 && move < 0) move = -move;
        degree = (degree + move).clamp(lowest, highest);
      }
      notes.add(_LeadNote(st, length, degree));
    }
    return notes;
  }

  void _renderLead(Float32List out) {
    final cache = <String, List<_LeadNote>>{};
    final step8 = s.step * 2;
    for (var p = 0; p < s.leadPlan.length; p++) {
      final letter = s.leadPlan[p];
      if (letter == '-') continue;
      final firstBar = p * 4;
      if (firstBar >= s.bars) break;
      final register = letter == 'B' ? 2 : (letter == 'C' ? 1 : 0);
      final phrase = cache.putIfAbsent(
        letter,
        () => _phrase(s.seed * 31 + letter.codeUnitAt(0), firstBar, register),
      );
      for (final note in phrase) {
        final step16 = firstBar * 16 + note.step * 2;
        renderNote(
          out,
          sampleRate: _sr,
          midi: _degreeToMidi(note.degree, s.root),
          start: _stepTime(step16),
          duration: note.length * step8 * 0.82,
          waveform: s.leadWave,
          pulseWidth: s.leadPulse,
          envelope: const Adsr(
            attack: 0.01,
            decay: 0.15,
            sustain: 0.6,
            release: 0.12,
          ),
          gain: s.leadGain,
          lowPass: s.leadCutoff,
          vibratoDepth: note.length >= 2 ? s.leadVibrato : 0,
          vibratoRate: 5.5,
          vibratoDelay: 0.18,
          wrap: true,
        );
      }
    }
  }

  // -- mix processing -------------------------------------------------------

  void _applySidechain(Float32List buf) {
    final gain = Float32List(_len)..fillRange(0, _len, 1);
    final tail = samplesFor(s.beat * 0.9, _sr);
    final tau = s.beat * 0.18;
    for (var i = 0; i < _steps; i++) {
      if (_velocity(s.kick[i % 16]) < 0.7) continue;
      final start = samplesFor(_stepTime(i), _sr);
      for (var k = 0; k < tail; k++) {
        final idx = (start + k) % _len;
        final g = 1 - s.sidechain * math.exp(-k / (_sr * tau));
        if (g < gain[idx]) gain[idx] = g;
      }
    }
    for (var i = 0; i < _len; i++) {
      buf[i] *= gain[i];
    }
  }

  void _applyLofi(Float32List buf) {
    // Vinyl crackle and hiss.
    final rng = math.Random(s.seed + 7);
    final noise = NoiseSource(seed: s.seed);
    final hissFilter = OnePoleLowPass(cutoff: 3000, sampleRate: _sr);
    var crackle = 0.0;
    for (var i = 0; i < _len; i++) {
      if (rng.nextDouble() < 0.0006) {
        crackle = (rng.nextDouble() - 0.5) * 0.35;
      }
      buf[i] += crackle + hissFilter.process(noise.next()) * 0.012;
      crackle *= 0.6;
    }
    // Warm, dark tape tone.
    _warmFilter(buf, Biquad.lowPass(3800, _sr, q: 0.6));
  }

  /// Runs [filter] over [buf] after warming its state on the loop tail, so
  /// the filtered loop has no seam at the wrap point.
  void _warmFilter(Float32List buf, AudioFilter filter) {
    final warm = math.min(_len, samplesFor(0.5, _sr));
    for (var i = _len - warm; i < _len; i++) {
      filter.process(buf[i]);
    }
    applyFilter(buf, filter);
  }
}
