/// Procedural recipes for every [SfxId].
///
/// Each recipe layers oscillators, filtered noise and additive partials from
/// the engine synthesis toolkit into a short mono buffer at [SoundBank.sampleRate].
/// Output is deterministic, click-free and normalised to a per-sound peak
/// level (always <= 1.0) so effects sit together consistently in the mix.
library;

import 'dart:math' as math;
import 'dart:typed_data';

import '../../engine/audio/envelope.dart';
import '../../engine/audio/filters.dart';
import '../../engine/audio/oscillators.dart';
import '../../engine/audio/synth_voice.dart';
import 'sfx_id.dart';

/// Renders sound effects from code.
abstract final class SoundBank {
  /// Sample rate of all rendered effects, in Hz.
  static const int sampleRate = 22050;

  /// Renders the effect for [id] as mono samples in [-1, 1].
  static Float32List render(SfxId id) {
    final raw = switch (id) {
      SfxId.uiTap => _uiTap(),
      SfxId.uiBack => _uiBack(),
      SfxId.uiPurchase => _uiPurchase(),
      SfxId.uiUpgrade => _uiUpgrade(),
      SfxId.uiError => _uiError(),
      SfxId.uiReward => _uiReward(),
      SfxId.coin => _coin(),
      SfxId.gem => _gem(),
      SfxId.jump => _jump(),
      SfxId.land => _land(),
      SfxId.duck => _duck(),
      SfxId.laneSwitch => _laneSwitch(),
      SfxId.nearMiss => _nearMiss(),
      SfxId.crash => _crash(),
      SfxId.stumble => _stumble(),
      SfxId.powerUp => _powerUp(),
      SfxId.shieldHit => _shieldHit(),
      SfxId.turboStart => _turboStart(),
      SfxId.magnetOn => _magnetOn(),
      SfxId.levelComplete => _levelComplete(),
      SfxId.starEarned => _starEarned(),
      SfxId.gameOver => _gameOver(),
      SfxId.countdownBeep => _countdownBeep(),
      SfxId.countdownGo => _countdownGo(),
      SfxId.chestOpen => _chestOpen(),
      SfxId.spinTick => _spinTick(),
      SfxId.levelUp => _levelUp(),
      SfxId.bell => _bell(),
      SfxId.thunder => _thunder(),
      SfxId.whoosh => _whoosh(),
    };
    return _finish(raw, peakLevel(id));
  }

  /// Target peak level of [id] after normalisation (0..1).
  static double peakLevel(SfxId id) => switch (id) {
    SfxId.uiTap || SfxId.spinTick => 0.5,
    SfxId.uiBack || SfxId.laneSwitch => 0.55,
    SfxId.countdownBeep || SfxId.uiError => 0.65,
    SfxId.crash || SfxId.thunder || SfxId.levelComplete => 0.95,
    SfxId.gameOver || SfxId.countdownGo || SfxId.turboStart => 0.85,
    _ => 0.75,
  };

  static Float32List _finish(Float32List buf, double level) {
    final out = buf.isEmpty ? Float32List(1) : buf;
    fadeEdges(out, sampleRate: sampleRate, fadeIn: 0.001, fadeOut: 0.012);
    // Remove DC so heavy low-end layers do not offset the waveform.
    applyFilter(out, OnePoleHighPass(cutoff: 25, sampleRate: sampleRate));
    // Gentle saturation glues layered voices and lifts perceived loudness;
    // the final normalisation pins the peak to the requested level.
    normalize(out, target: 1);
    softClip(out, drive: 1.5);
    normalize(out, target: level);
    return out;
  }
}

const int _sr = SoundBank.sampleRate;

Float32List _buf(double seconds) => silence(seconds, sampleRate: _sr);

/// Bright harmonic chime (coins, UI sparkles).
void _chime(
  Float32List out,
  double freq, {
  double at = 0,
  double gain = 0.5,
  double decay = 0.18,
}) {
  renderPartials(
    out,
    sampleRate: _sr,
    frequency: freq,
    start: at,
    gain: gain,
    attack: 0.001,
    partials: [
      Partial(1, 1, decay),
      Partial(2, 0.45, decay * 0.55),
      Partial(3, 0.22, decay * 0.35),
      Partial(4.16, 0.12, decay * 0.25),
    ],
  );
}

/// Glassy inharmonic sparkle (gems, stars, magic).
void _sparkle(
  Float32List out,
  double freq, {
  double at = 0,
  double gain = 0.4,
  double decay = 0.25,
}) {
  renderPartials(
    out,
    sampleRate: _sr,
    frequency: freq,
    start: at,
    gain: gain,
    attack: 0.002,
    partials: [
      Partial(1, 1, decay),
      Partial(2.76, 0.35, decay * 0.5),
      Partial(5.40, 0.15, decay * 0.3),
      Partial(1.003, 0.6, decay * 0.9), // Slow beating shimmer.
    ],
  );
}

/// Simple brass-like note: saw through an opening low pass.
void _brass(
  Float32List out,
  num midi, {
  required double at,
  required double length,
  double gain = 0.3,
  double vibrato = 0,
}) {
  for (final detune in const [-6.0, 6.0]) {
    renderNote(
      out,
      sampleRate: _sr,
      midi: midi,
      detuneCents: detune,
      start: at,
      duration: length,
      waveform: Waveform.saw,
      envelope: const Adsr(
        attack: 0.015,
        decay: 0.12,
        sustain: 0.7,
        release: 0.12,
      ),
      gain: gain,
      lowPass: 900,
      lowPassEnd: 3200,
      lowPassQ: 1.1,
      vibratoDepth: vibrato,
      vibratoRate: 5.5,
      vibratoDelay: 0.15,
    );
  }
}

/// Short percussive blip.
void _blip(
  Float32List out,
  double freq, {
  double at = 0,
  double length = 0.06,
  double gain = 0.4,
  Waveform wave = Waveform.square,
  double? endFreq,
  double cutoff = 3500,
}) {
  renderTone(
    out,
    sampleRate: _sr,
    frequency: freq,
    endFrequency: endFreq,
    start: at,
    duration: length * 0.5,
    waveform: wave,
    envelope: Adsr(
      attack: 0.002,
      decay: length * 0.5,
      sustain: 0.4,
      release: length * 0.5,
    ),
    gain: gain,
    lowPass: cutoff,
  );
}

/// Low sine "thump" with a falling pitch.
void _thump(
  Float32List out, {
  double at = 0,
  double from = 140,
  double to = 45,
  double length = 0.22,
  double gain = 0.8,
}) {
  renderTone(
    out,
    sampleRate: _sr,
    frequency: from,
    endFrequency: to,
    sweepTime: length * 0.5,
    start: at,
    duration: 0.005,
    envelope: Adsr(attack: 0.001, decay: 0, sustain: 1, release: length),
    gain: gain,
  );
}

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------

Float32List _uiTap() {
  final out = _buf(0.08);
  _blip(out, 1400, endFreq: 1000, length: 0.045, wave: Waveform.triangle);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.01,
    decay: 0.002,
    gain: 0.25,
    filter: BiquadType.highPass,
    cutoff: 4000,
  );
  return out;
}

Float32List _uiBack() {
  final out = _buf(0.16);
  _blip(out, 820, length: 0.05, wave: Waveform.triangle, gain: 0.5);
  _blip(out, 560, at: 0.06, length: 0.07, wave: Waveform.triangle, gain: 0.5);
  return out;
}

Float32List _uiPurchase() {
  final out = _buf(0.75);
  // "Ka" - register drawer click.
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.04,
    decay: 0.008,
    gain: 0.5,
    filter: BiquadType.bandPass,
    cutoff: 2500,
    q: 2,
  );
  // "Ching" - two bright chimes and a sparkle.
  _chime(out, midiToHz(84), at: 0.04, gain: 0.45, decay: 0.12);
  _chime(out, midiToHz(91), at: 0.11, gain: 0.5, decay: 0.28);
  _sparkle(out, midiToHz(100), at: 0.13, gain: 0.15, decay: 0.15);
  return out;
}

Float32List _uiUpgrade() {
  final out = _buf(0.75);
  const notes = [72, 76, 79, 84, 88];
  for (var i = 0; i < notes.length; i++) {
    _blip(
      out,
      midiToHz(notes[i]),
      at: i * 0.055,
      length: 0.09,
      gain: 0.3,
      wave: Waveform.square,
      cutoff: 4000,
    );
  }
  _chime(out, midiToHz(96), at: 0.27, gain: 0.35, decay: 0.2);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.3,
    start: 0.0,
    envelope: const Adsr(attack: 0.25, decay: 0.0, sustain: 1, release: 0.15),
    gain: 0.08,
    filter: BiquadType.bandPass,
    cutoff: 2000,
    cutoffEnd: 7000,
    q: 1.5,
  );
  return out;
}

Float32List _uiError() {
  final out = _buf(0.32);
  for (final (i, f) in const [233.0, 196.0].indexed) {
    renderTone(
      out,
      sampleRate: _sr,
      frequency: f,
      start: i * 0.13,
      duration: 0.1,
      waveform: Waveform.square,
      envelope: const Adsr(
        attack: 0.003,
        decay: 0.05,
        sustain: 0.6,
        release: 0.04,
      ),
      gain: 0.35,
      lowPass: 1400,
    );
    renderTone(
      out,
      sampleRate: _sr,
      frequency: f * 1.012,
      start: i * 0.13,
      duration: 0.1,
      waveform: Waveform.saw,
      envelope: const Adsr(
        attack: 0.003,
        decay: 0.05,
        sustain: 0.6,
        release: 0.04,
      ),
      gain: 0.2,
      lowPass: 1200,
    );
  }
  return out;
}

Float32List _uiReward() {
  final out = _buf(1.0);
  const notes = [79, 83, 86, 91];
  for (var i = 0; i < notes.length; i++) {
    _chime(out, midiToHz(notes[i]), at: i * 0.07, gain: 0.35, decay: 0.2);
  }
  _sparkle(out, midiToHz(98), at: 0.3, gain: 0.25, decay: 0.3);
  _sparkle(out, midiToHz(103), at: 0.38, gain: 0.18, decay: 0.25);
  applyEcho(out, sampleRate: _sr, time: 0.11, feedback: 0.3, mix: 0.25);
  return out;
}

// ---------------------------------------------------------------------------
// Pickups
// ---------------------------------------------------------------------------

Float32List _coin() {
  final out = _buf(0.42);
  // Classic two-note chime: B5 then E6 (a perfect fourth up).
  _blip(
    out,
    midiToHz(83),
    length: 0.06,
    gain: 0.3,
    wave: Waveform.square,
    cutoff: 5000,
  );
  _chime(out, midiToHz(83), gain: 0.35, decay: 0.05);
  _blip(
    out,
    midiToHz(88),
    at: 0.055,
    length: 0.1,
    gain: 0.25,
    wave: Waveform.square,
    cutoff: 6000,
  );
  _chime(out, midiToHz(88), at: 0.055, gain: 0.5, decay: 0.16);
  return out;
}

Float32List _gem() {
  final out = _buf(0.9);
  const notes = [88, 92, 95, 100, 104];
  for (var i = 0; i < notes.length; i++) {
    _sparkle(
      out,
      midiToHz(notes[i]),
      at: i * 0.045,
      gain: 0.3 + i * 0.03,
      decay: 0.12 + i * 0.03,
    );
  }
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.35,
    envelope: const Adsr(attack: 0.05, decay: 0.1, sustain: 0.5, release: 0.2),
    gain: 0.05,
    filter: BiquadType.highPass,
    cutoff: 6000,
  );
  applyEcho(out, sampleRate: _sr, time: 0.09, feedback: 0.35, mix: 0.3);
  return out;
}

// ---------------------------------------------------------------------------
// Movement
// ---------------------------------------------------------------------------

Float32List _jump() {
  final out = _buf(0.34);
  // Springy "boing": rising square with a fast, fading wobble.
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 220,
    endFrequency: 760,
    sweepTime: 0.2,
    duration: 0.14,
    waveform: Waveform.square,
    pulseWidth: 0.35,
    envelope: const Adsr(
      attack: 0.004,
      decay: 0.12,
      sustain: 0.5,
      release: 0.14,
    ),
    gain: 0.35,
    vibratoDepth: 0.8,
    vibratoRate: 22,
    vibratoDelay: 0,
    lowPass: 1500,
    lowPassEnd: 4000,
  );
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 330,
    endFrequency: 1140,
    sweepTime: 0.2,
    duration: 0.12,
    waveform: Waveform.triangle,
    envelope: const Adsr(
      attack: 0.004,
      decay: 0.1,
      sustain: 0.4,
      release: 0.12,
    ),
    gain: 0.3,
  );
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.16,
    decay: 0.05,
    gain: 0.1,
    filter: BiquadType.bandPass,
    cutoff: 1500,
    cutoffEnd: 4500,
    q: 1.2,
  );
  return out;
}

Float32List _land() {
  final out = _buf(0.3);
  _thump(out, from: 130, to: 48, length: 0.18, gain: 0.8);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.14,
    decay: 0.035,
    gain: 0.5,
    filter: BiquadType.lowPass,
    cutoff: 700,
  );
  // Tyre squish.
  renderNoise(
    out,
    sampleRate: _sr,
    start: 0.01,
    duration: 0.08,
    decay: 0.02,
    gain: 0.12,
    filter: BiquadType.bandPass,
    cutoff: 2200,
    q: 2,
  );
  return out;
}

Float32List _duck() {
  final out = _buf(0.26);
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 640,
    endFrequency: 240,
    duration: 0.1,
    waveform: Waveform.triangle,
    envelope: const Adsr(
      attack: 0.003,
      decay: 0.08,
      sustain: 0.4,
      release: 0.08,
    ),
    gain: 0.45,
  );
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.2,
    envelope: const Adsr(
      attack: 0.03,
      decay: 0.08,
      sustain: 0.3,
      release: 0.07,
    ),
    gain: 0.25,
    filter: BiquadType.bandPass,
    cutoff: 3000,
    cutoffEnd: 900,
    q: 1.3,
  );
  return out;
}

Float32List _laneSwitch() {
  final out = _buf(0.18);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.13,
    envelope: const Adsr(
      attack: 0.03,
      decay: 0.05,
      sustain: 0.4,
      release: 0.04,
    ),
    gain: 0.5,
    filter: BiquadType.bandPass,
    cutoff: 1200,
    cutoffEnd: 3800,
    q: 1.6,
  );
  _blip(out, 900, endFreq: 1300, length: 0.04, gain: 0.12, wave: Waveform.sine);
  return out;
}

Float32List _nearMiss() {
  final out = _buf(0.5);
  // Doppler-ish fly-by: noise + whistle sweeping down.
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.38,
    envelope: const Adsr(attack: 0.08, decay: 0.1, sustain: 0.5, release: 0.08),
    gain: 0.5,
    filter: BiquadType.bandPass,
    cutoff: 4200,
    cutoffEnd: 700,
    q: 2.2,
  );
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 1900,
    endFrequency: 950,
    duration: 0.25,
    waveform: Waveform.sine,
    envelope: const Adsr(attack: 0.06, decay: 0.1, sustain: 0.5, release: 0.1),
    gain: 0.18,
  );
  // Reward "zing".
  _chime(out, midiToHz(93), at: 0.12, gain: 0.18, decay: 0.12);
  return out;
}

// ---------------------------------------------------------------------------
// Impacts
// ---------------------------------------------------------------------------

/// Metallic clank via inharmonic partials.
void _clank(Float32List out, double freq, {double at = 0, double gain = 0.4}) {
  renderPartials(
    out,
    sampleRate: _sr,
    frequency: freq,
    start: at,
    gain: gain,
    attack: 0.0005,
    partials: const [
      Partial(1, 1, 0.12),
      Partial(2.76, 0.7, 0.09),
      Partial(4.07, 0.5, 0.07),
      Partial(5.43, 0.35, 0.05),
      Partial(8.93, 0.2, 0.03),
    ],
  );
}

Float32List _crash() {
  final out = _buf(1.1);
  // Body impact.
  _thump(out, from: 110, to: 38, length: 0.4, gain: 1.0);
  // Broad noisy smash with closing filter.
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.6,
    decay: 0.14,
    gain: 0.9,
    filter: BiquadType.lowPass,
    cutoff: 7000,
    cutoffEnd: 400,
    q: 0.9,
    seed: 11,
  );
  // Gravel / debris.
  renderNoise(
    out,
    sampleRate: _sr,
    start: 0.05,
    duration: 0.7,
    decay: 0.25,
    gain: 0.2,
    filter: BiquadType.bandPass,
    cutoff: 2500,
    q: 0.8,
    seed: 23,
  );
  // Bike frame clanks and rattles.
  _clank(out, 410, gain: 0.45);
  _clank(out, 530, at: 0.13, gain: 0.3);
  _clank(out, 690, at: 0.24, gain: 0.18);
  _clank(out, 470, at: 0.36, gain: 0.1);
  return out;
}

Float32List _stumble() {
  final out = _buf(0.5);
  _thump(out, from: 120, to: 55, length: 0.16, gain: 0.6);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.15,
    decay: 0.04,
    gain: 0.4,
    filter: BiquadType.lowPass,
    cutoff: 1500,
  );
  _clank(out, 620, at: 0.03, gain: 0.15);
  _clank(out, 760, at: 0.11, gain: 0.08);
  // Comic "whoa" drop.
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 520,
    endFrequency: 300,
    start: 0.08,
    duration: 0.15,
    waveform: Waveform.triangle,
    envelope: const Adsr(attack: 0.01, decay: 0.1, sustain: 0.5, release: 0.12),
    gain: 0.25,
    vibratoDepth: 0.4,
    vibratoRate: 9,
  );
  return out;
}

// ---------------------------------------------------------------------------
// Power-ups
// ---------------------------------------------------------------------------

Float32List _powerUp() {
  final out = _buf(0.8);
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 260,
    endFrequency: 1040,
    sweepTime: 0.45,
    duration: 0.4,
    waveform: Waveform.saw,
    envelope: const Adsr(attack: 0.02, decay: 0.2, sustain: 0.6, release: 0.2),
    gain: 0.22,
    lowPass: 800,
    lowPassEnd: 4500,
    lowPassQ: 2,
  );
  const notes = [67, 71, 74, 79, 83, 86, 91];
  for (var i = 0; i < notes.length; i++) {
    _blip(
      out,
      midiToHz(notes[i]),
      at: i * 0.05,
      length: 0.08,
      gain: 0.2,
      cutoff: 5000,
    );
  }
  _sparkle(out, midiToHz(98), at: 0.35, gain: 0.25, decay: 0.2);
  return out;
}

Float32List _shieldHit() {
  final out = _buf(0.7);
  // Energy "bwong".
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 900,
    endFrequency: 420,
    sweepTime: 0.3,
    duration: 0.15,
    waveform: Waveform.triangle,
    envelope: const Adsr(
      attack: 0.002,
      decay: 0.15,
      sustain: 0.4,
      release: 0.3,
    ),
    gain: 0.4,
    vibratoDepth: 0.5,
    vibratoRate: 14,
    vibratoDelay: 0,
  );
  renderPartials(
    out,
    sampleRate: _sr,
    frequency: 620,
    gain: 0.35,
    partials: const [
      Partial(1, 1, 0.2),
      Partial(1.51, 0.6, 0.15),
      Partial(2.33, 0.4, 0.1),
      Partial(3.79, 0.25, 0.07),
    ],
  );
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.12,
    decay: 0.03,
    gain: 0.35,
    filter: BiquadType.bandPass,
    cutoff: 3000,
    q: 1.2,
  );
  return out;
}

Float32List _turboStart() {
  final out = _buf(1.0);
  // Engine rev: detuned saws rising with an opening filter.
  for (final ratio in const [1.0, 1.5, 2.01]) {
    renderTone(
      out,
      sampleRate: _sr,
      frequency: 70 * ratio,
      endFrequency: 300 * ratio,
      sweepTime: 0.7,
      duration: 0.6,
      waveform: Waveform.saw,
      envelope: const Adsr(
        attack: 0.05,
        decay: 0.3,
        sustain: 0.8,
        release: 0.3,
      ),
      gain: 0.25 / ratio,
      lowPass: 350,
      lowPassEnd: 3500,
      lowPassQ: 1.4,
      vibratoDepth: 0.3,
      vibratoRate: 28,
      vibratoDelay: 0,
    );
  }
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.75,
    envelope: const Adsr(attack: 0.5, decay: 0.1, sustain: 0.8, release: 0.2),
    gain: 0.3,
    filter: BiquadType.bandPass,
    cutoff: 600,
    cutoffEnd: 5000,
    q: 1.1,
  );
  return out;
}

Float32List _magnetOn() {
  final out = _buf(0.75);
  // Wobbling "wub-wub" field hum rising in pitch.
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 180,
    endFrequency: 420,
    duration: 0.45,
    waveform: Waveform.square,
    pulseWidth: 0.3,
    envelope: const Adsr(attack: 0.02, decay: 0.2, sustain: 0.7, release: 0.2),
    gain: 0.3,
    vibratoDepth: 2,
    vibratoRate: 11,
    vibratoDelay: 0,
    lowPass: 600,
    lowPassEnd: 2500,
    lowPassQ: 3,
  );
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 720,
    endFrequency: 1680,
    duration: 0.45,
    waveform: Waveform.sine,
    envelope: const Adsr(attack: 0.05, decay: 0.2, sustain: 0.6, release: 0.2),
    gain: 0.18,
    vibratoDepth: 1,
    vibratoRate: 11,
    vibratoDelay: 0,
  );
  return out;
}

// ---------------------------------------------------------------------------
// Results / progression
// ---------------------------------------------------------------------------

Float32List _levelComplete() {
  final out = _buf(2.0);
  // Triplet pickup (G4 C5 E5) into a held C major chord topped by G5/C6.
  const beat = 0.12;
  _brass(out, 67, at: 0, length: beat * 0.8, gain: 0.22);
  _brass(out, 72, at: beat, length: beat * 0.8, gain: 0.22);
  _brass(out, 76, at: beat * 2, length: beat * 0.8, gain: 0.22);
  _brass(out, 79, at: beat * 3, length: beat * 1.6, gain: 0.24);
  const chordAt = beat * 5;
  for (final m in const [60, 64, 67, 72]) {
    _brass(out, m, at: chordAt, length: 0.75, gain: 0.13, vibrato: 0.12);
  }
  _brass(out, 84, at: chordAt, length: 0.75, gain: 0.2, vibrato: 0.2);
  // Timpani-ish hits and a cymbal swell.
  _thump(out, from: 110, to: 80, length: 0.35, gain: 0.5);
  _thump(out, at: chordAt, from: 98, to: 65, length: 0.6, gain: 0.7);
  renderNoise(
    out,
    sampleRate: _sr,
    start: chordAt,
    duration: 1.2,
    decay: 0.35,
    gain: 0.12,
    filter: BiquadType.highPass,
    cutoff: 5000,
  );
  _sparkle(out, midiToHz(96), at: chordAt + 0.05, gain: 0.15, decay: 0.3);
  applyEcho(out, sampleRate: _sr, time: 0.18, feedback: 0.25, mix: 0.2);
  return out;
}

Float32List _starEarned() {
  final out = _buf(0.9);
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 1500,
    endFrequency: 3500,
    duration: 0.08,
    waveform: Waveform.triangle,
    envelope: const Adsr(
      attack: 0.005,
      decay: 0.05,
      sustain: 0.5,
      release: 0.05,
    ),
    gain: 0.2,
  );
  _sparkle(out, midiToHz(93), at: 0.06, gain: 0.5, decay: 0.32);
  _chime(out, midiToHz(100), at: 0.09, gain: 0.25, decay: 0.2);
  applyEcho(out, sampleRate: _sr, time: 0.12, feedback: 0.3, mix: 0.25);
  return out;
}

Float32List _gameOver() {
  final out = _buf(2.0);
  // Sad descending "wah wah wah waaah".
  const notes = [67, 66, 65];
  for (var i = 0; i < notes.length; i++) {
    _brass(out, notes[i] - 12, at: i * 0.34, length: 0.26, gain: 0.25);
  }
  _brass(out, 52, at: 1.02, length: 0.7, gain: 0.28, vibrato: 0.5);
  _thump(out, at: 1.02, from: 80, to: 40, length: 0.5, gain: 0.4);
  return out;
}

Float32List _countdownBeep() {
  final out = _buf(0.2);
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 880,
    duration: 0.09,
    waveform: Waveform.square,
    pulseWidth: 0.5,
    envelope: const Adsr(
      attack: 0.002,
      decay: 0.03,
      sustain: 0.7,
      release: 0.05,
    ),
    gain: 0.3,
    lowPass: 3000,
  );
  renderTone(
    out,
    sampleRate: _sr,
    frequency: 880,
    duration: 0.09,
    envelope: const Adsr(
      attack: 0.002,
      decay: 0.03,
      sustain: 0.7,
      release: 0.05,
    ),
    gain: 0.3,
  );
  return out;
}

Float32List _countdownGo() {
  final out = _buf(0.65);
  for (final (f, g) in const [(1760.0, 0.25), (880.0, 0.3), (1318.5, 0.15)]) {
    renderTone(
      out,
      sampleRate: _sr,
      frequency: f,
      duration: 0.32,
      waveform: Waveform.square,
      envelope: const Adsr(
        attack: 0.003,
        decay: 0.1,
        sustain: 0.6,
        release: 0.2,
      ),
      gain: g,
      lowPass: 4500,
      vibratoDepth: 0.1,
      vibratoRate: 7,
    );
  }
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.3,
    decay: 0.1,
    gain: 0.1,
    filter: BiquadType.highPass,
    cutoff: 6000,
  );
  return out;
}

Float32List _chestOpen() {
  final out = _buf(1.5);
  // Wooden creak: resonant noise with a slowly rising, wobbling band.
  final creak = Float32List(samplesFor(0.35, _sr));
  final noise = NoiseSource(seed: 5);
  final bp = Biquad.bandPass(500, _sr, q: 8);
  for (var i = 0; i < creak.length; i++) {
    final t = i / _sr;
    if ((i & 15) == 0) {
      bp.configure(frequency: 420 + 500 * t + 60 * math.sin(twoPi * 9 * t));
    }
    // Stick-slip pulses give the creak its texture.
    final pulse = math.pow(0.5 + 0.5 * math.sin(twoPi * 38 * t), 6).toDouble();
    creak[i] =
        bp.process(noise.next()) * pulse * 2.2 * math.sin(math.pi * t / 0.35);
  }
  mixInto(out, creak, sampleRate: _sr);
  // Latch click.
  renderNoise(
    out,
    sampleRate: _sr,
    start: 0.35,
    duration: 0.03,
    decay: 0.006,
    gain: 0.5,
    filter: BiquadType.bandPass,
    cutoff: 3000,
    q: 3,
  );
  _thump(out, at: 0.35, from: 180, to: 90, length: 0.12, gain: 0.35);
  // Magical reveal.
  const notes = [72, 76, 79, 84, 88, 91, 96];
  for (var i = 0; i < notes.length; i++) {
    _sparkle(
      out,
      midiToHz(notes[i]),
      at: 0.42 + i * 0.05,
      gain: 0.22,
      decay: 0.2,
    );
  }
  renderNoise(
    out,
    sampleRate: _sr,
    start: 0.4,
    duration: 0.7,
    envelope: const Adsr(attack: 0.3, decay: 0.2, sustain: 0.5, release: 0.3),
    gain: 0.06,
    filter: BiquadType.highPass,
    cutoff: 5000,
  );
  applyEcho(out, sampleRate: _sr, time: 0.1, feedback: 0.3, mix: 0.25);
  return out;
}

Float32List _spinTick() {
  final out = _buf(0.04);
  renderNoise(
    out,
    sampleRate: _sr,
    duration: 0.02,
    decay: 0.003,
    gain: 0.6,
    filter: BiquadType.highPass,
    cutoff: 3000,
  );
  _blip(out, 2600, length: 0.02, gain: 0.25, wave: Waveform.sine);
  return out;
}

Float32List _levelUp() {
  final out = _buf(1.3);
  const notes = [72, 76, 79, 84, 88];
  for (var i = 0; i < notes.length; i++) {
    _blip(
      out,
      midiToHz(notes[i]),
      at: i * 0.07,
      length: 0.12,
      gain: 0.25,
      cutoff: 5000,
    );
    _chime(out, midiToHz(notes[i]), at: i * 0.07, gain: 0.15, decay: 0.1);
  }
  const chordAt = 0.37;
  for (final m in const [72, 76, 79, 84]) {
    renderNote(
      out,
      sampleRate: _sr,
      midi: m,
      start: chordAt,
      duration: 0.45,
      waveform: Waveform.square,
      pulseWidth: 0.25,
      envelope: const Adsr(
        attack: 0.01,
        decay: 0.2,
        sustain: 0.6,
        release: 0.3,
      ),
      gain: 0.1,
      lowPass: 3500,
      vibratoDepth: 0.15,
      vibratoRate: 6,
    );
  }
  _sparkle(out, midiToHz(96), at: chordAt, gain: 0.25, decay: 0.3);
  applyEcho(out, sampleRate: _sr, time: 0.14, feedback: 0.3, mix: 0.2);
  return out;
}

// ---------------------------------------------------------------------------
// Ambience
// ---------------------------------------------------------------------------

Float32List _bell() {
  final out = _buf(1.2);
  // Bicycle bell: thin metal dome struck twice ("ding-ding"). Partial ratios
  // follow a clamped dome; close pairs produce the characteristic shimmer.
  const partials = [
    Partial(1.0, 1.0, 0.32),
    Partial(1.006, 0.7, 0.3),
    Partial(1.59, 0.55, 0.2),
    Partial(2.14, 0.45, 0.15),
    Partial(2.3, 0.3, 0.13),
    Partial(2.65, 0.3, 0.1),
    Partial(3.56, 0.18, 0.07),
  ];
  const base = 1950.0;
  for (final (at, gain) in const [(0.0, 0.5), (0.17, 0.45)]) {
    renderPartials(
      out,
      sampleRate: _sr,
      frequency: base,
      partials: partials,
      start: at,
      gain: gain,
      attack: 0.0008,
    );
    // Striker tick.
    renderNoise(
      out,
      sampleRate: _sr,
      start: at,
      duration: 0.012,
      decay: 0.002,
      gain: 0.3,
      filter: BiquadType.highPass,
      cutoff: 5000,
    );
  }
  return out;
}

Float32List _thunder() {
  const length = 3.2;
  final out = _buf(length);
  final n = out.length;
  final rng = math.Random(42);

  // Rolling envelope: a fast crack, then several overlapping rumble bursts.
  final bumps = <(double, double, double)>[
    (0.0, 1.0, 0.25),
    for (var i = 0; i < 6; i++)
      (
        0.15 + rng.nextDouble() * 1.6,
        0.35 + rng.nextDouble() * 0.5,
        0.25 + rng.nextDouble() * 0.5,
      ),
  ];

  final noise = NoiseSource(seed: 99);
  final lp1 = Biquad.lowPass(220, _sr, q: 0.9);
  final lp2 = Biquad.lowPass(160, _sr, q: 0.7);
  final mid = Biquad.bandPass(700, _sr, q: 0.7);
  final crack = Biquad.highPass(1800, _sr);
  for (var i = 0; i < n; i++) {
    final t = i / _sr;
    var env = 0.0;
    for (final (at, gain, tau) in bumps) {
      env += gain * attackDecay(t - at, attack: 0.05, tau: tau);
    }
    // Slow fade over the full length so the tail dies naturally.
    env *= 1 - t / length;
    final w = noise.next();
    final rumble = lp2.process(lp1.process(w)) * 3.2;
    final body = mid.process(w) * 0.6 * expDecay(t, 0.4);
    final snap =
        crack.process(w) * 0.7 * attackDecay(t, attack: 0.002, tau: 0.05);
    out[i] = (rumble + body) * env + snap;
  }
  // Very low sub-thump for weight.
  _thump(out, from: 70, to: 30, length: 1.2, gain: 0.35);
  return out;
}

Float32List _whoosh() {
  const length = 0.5;
  final out = _buf(length);
  final noise = NoiseSource(seed: 17);
  final bp = Biquad.bandPass(500, _sr, q: 1.4);
  final lp = OnePoleLowPass(cutoff: 6000, sampleRate: _sr);
  for (var i = 0; i < out.length; i++) {
    final x = i / out.length;
    // Cutoff rises then falls, amplitude swells in the middle.
    final shape = math.sin(math.pi * x);
    if ((i & 15) == 0) bp.configure(frequency: 400 + 2600 * shape * shape);
    out[i] =
        lp.process(bp.process(noise.next())) * math.pow(shape, 1.5).toDouble();
  }
  return out;
}
