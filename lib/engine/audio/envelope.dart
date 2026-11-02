/// Amplitude envelopes: ADSR and exponential decay helpers.
///
/// All times are expressed in seconds. Envelopes are evaluated as pure
/// functions of time so they can be sampled at any position of a render.
library;

import 'dart:math' as math;

/// Classic attack / decay / sustain / release envelope.
///
/// The gate is held for `gate` seconds (see [valueAt]); the release phase
/// starts from whatever level the envelope had reached at gate-off, so short
/// notes never click.
class Adsr {
  /// Creates an ADSR envelope. [sustain] is a level in 0..1.
  const Adsr({
    this.attack = 0.005,
    this.decay = 0.1,
    this.sustain = 0.7,
    this.release = 0.1,
    this.curve = 3.0,
  });

  /// Short percussive envelope (no sustain).
  const Adsr.pluck({double decay = 0.25, double attack = 0.002})
    : this(attack: attack, decay: decay, sustain: 0, release: 0.02);

  /// Slow pad-like envelope.
  const Adsr.pad({
    double attack = 0.4,
    double release = 0.6,
    double sustain = 0.85,
  }) : this(attack: attack, decay: 0.3, sustain: sustain, release: release);

  /// Attack time in seconds.
  final double attack;

  /// Decay time in seconds (to the sustain level).
  final double decay;

  /// Sustain level (0..1).
  final double sustain;

  /// Release time in seconds after the gate closes.
  final double release;

  /// Steepness of the exponential decay/release segments (0 = linear).
  final double curve;

  /// Total audible length for a note gated for [gate] seconds.
  double totalLength(double gate) => gate + release;

  /// Envelope level at time [t] for a note gated for [gate] seconds.
  double valueAt(double t, double gate) {
    if (t < 0) return 0;
    if (t < gate) return _held(t);
    final rt = t - gate;
    if (rt >= release) return 0;
    final start = _held(gate);
    return start * _shape(1 - rt / release);
  }

  double _held(double t) {
    if (t < attack) return attack <= 0 ? 1 : t / attack;
    final dt = t - attack;
    if (dt < decay) {
      return sustain + (1 - sustain) * _shape(1 - dt / decay);
    }
    return sustain;
  }

  /// Maps a linear 1→0 ramp to an exponential-feeling curve.
  double _shape(double x) {
    if (curve <= 0) return x;
    return (math.exp(curve * x) - 1) / (math.exp(curve) - 1);
  }
}

/// Exponential decay `exp(-t / tau)`; returns 0 for negative [t].
double expDecay(double t, double tau) {
  if (t < 0) return 0;
  if (tau <= 0) return 0;
  return math.exp(-t / tau);
}

/// Exponential decay that reaches -60 dB after [time60] seconds.
double decay60(double t, double time60) => expDecay(t, time60 / 6.907755);

/// Attack ramp followed by exponential decay; a common percussive shape.
double attackDecay(double t, {double attack = 0.002, required double tau}) {
  if (t < 0) return 0;
  if (t < attack) return t / attack;
  return expDecay(t - attack, tau);
}

/// Linear interpolation between [a] and [b].
double lerp(double a, double b, double t) => a + (b - a) * t;

/// Exponential interpolation between positive values [a] and [b].
double expLerp(double a, double b, double t) =>
    a * math.pow(b / a, t.clamp(0.0, 1.0)).toDouble();
