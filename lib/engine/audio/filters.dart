/// Simple IIR filters: one-pole low/high pass and an RBJ-cookbook biquad.
///
/// Every filter is stateful and processes one sample at a time via
/// `process`. Cutoffs can be changed between samples for sweeps.
library;

import 'dart:math' as math;

/// Common interface of the sample-by-sample filters in this file.
abstract interface class AudioFilter {
  /// Filters one input sample and returns the output.
  double process(double x);

  /// Clears the internal state.
  void reset();
}

/// One-pole (6 dB/oct) low pass filter.
class OnePoleLowPass implements AudioFilter {
  /// Creates a low pass with [cutoff] Hz at [sampleRate] Hz.
  OnePoleLowPass({required double cutoff, required this.sampleRate}) {
    this.cutoff = cutoff;
  }

  /// Sample rate in Hz.
  final int sampleRate;
  double _a = 0;
  double _cutoff = 0;
  double _y = 0;

  /// Cutoff frequency in Hz.
  double get cutoff => _cutoff;
  set cutoff(double hz) {
    _cutoff = hz.clamp(1.0, sampleRate * 0.49);
    _a = 1 - math.exp(-twoPiOver(sampleRate) * _cutoff);
  }

  @override
  double process(double x) => _y += _a * (x - _y);

  @override
  void reset() => _y = 0;
}

/// One-pole (6 dB/oct) high pass filter.
class OnePoleHighPass implements AudioFilter {
  /// Creates a high pass with [cutoff] Hz at [sampleRate] Hz.
  OnePoleHighPass({required double cutoff, required int sampleRate})
    : _lp = OnePoleLowPass(cutoff: cutoff, sampleRate: sampleRate);

  final OnePoleLowPass _lp;

  /// Cutoff frequency in Hz.
  double get cutoff => _lp.cutoff;
  set cutoff(double hz) => _lp.cutoff = hz;

  @override
  double process(double x) => x - _lp.process(x);

  @override
  void reset() => _lp.reset();
}

/// Response types supported by [Biquad].
enum BiquadType { lowPass, highPass, bandPass, notch, peak }

/// Second-order (12 dB/oct) filter using the RBJ Audio EQ Cookbook formulas.
class Biquad implements AudioFilter {
  /// Creates a biquad of [type] at [frequency] Hz with resonance [q].
  ///
  /// [gainDb] is only used by [BiquadType.peak].
  Biquad({
    required this.type,
    required double frequency,
    required this.sampleRate,
    double q = 0.7071,
    double gainDb = 0,
  }) {
    configure(frequency: frequency, q: q, gainDb: gainDb);
  }

  /// Convenience low pass constructor.
  factory Biquad.lowPass(
    double frequency,
    int sampleRate, {
    double q = 0.7071,
  }) => Biquad(
    type: BiquadType.lowPass,
    frequency: frequency,
    sampleRate: sampleRate,
    q: q,
  );

  /// Convenience high pass constructor.
  factory Biquad.highPass(
    double frequency,
    int sampleRate, {
    double q = 0.7071,
  }) => Biquad(
    type: BiquadType.highPass,
    frequency: frequency,
    sampleRate: sampleRate,
    q: q,
  );

  /// Convenience band pass constructor (constant 0 dB peak gain).
  factory Biquad.bandPass(double frequency, int sampleRate, {double q = 1}) =>
      Biquad(
        type: BiquadType.bandPass,
        frequency: frequency,
        sampleRate: sampleRate,
        q: q,
      );

  /// Filter response type.
  final BiquadType type;

  /// Sample rate in Hz.
  final int sampleRate;

  double _b0 = 1, _b1 = 0, _b2 = 0, _a1 = 0, _a2 = 0;
  double _x1 = 0, _x2 = 0, _y1 = 0, _y2 = 0;
  double _q = 0.7071, _gainDb = 0;

  /// Recomputes coefficients. Omitted values keep their previous setting.
  void configure({required double frequency, double? q, double? gainDb}) {
    _q = math.max(0.05, q ?? _q);
    _gainDb = gainDb ?? _gainDb;
    final f = frequency.clamp(10.0, sampleRate * 0.48);
    final w0 = twoPiOver(sampleRate) * f;
    final cosW = math.cos(w0);
    final alpha = math.sin(w0) / (2 * _q);
    double b0, b1, b2, a0, a1, a2;
    switch (type) {
      case BiquadType.lowPass:
        b1 = 1 - cosW;
        b0 = b1 / 2;
        b2 = b0;
        a0 = 1 + alpha;
        a1 = -2 * cosW;
        a2 = 1 - alpha;
      case BiquadType.highPass:
        b1 = -(1 + cosW);
        b0 = (1 + cosW) / 2;
        b2 = b0;
        a0 = 1 + alpha;
        a1 = -2 * cosW;
        a2 = 1 - alpha;
      case BiquadType.bandPass:
        b0 = alpha;
        b1 = 0;
        b2 = -alpha;
        a0 = 1 + alpha;
        a1 = -2 * cosW;
        a2 = 1 - alpha;
      case BiquadType.notch:
        b0 = 1;
        b1 = -2 * cosW;
        b2 = 1;
        a0 = 1 + alpha;
        a1 = -2 * cosW;
        a2 = 1 - alpha;
      case BiquadType.peak:
        final a = math.pow(10, _gainDb / 40).toDouble();
        b0 = 1 + alpha * a;
        b1 = -2 * cosW;
        b2 = 1 - alpha * a;
        a0 = 1 + alpha / a;
        a1 = -2 * cosW;
        a2 = 1 - alpha / a;
    }
    _b0 = b0 / a0;
    _b1 = b1 / a0;
    _b2 = b2 / a0;
    _a1 = a1 / a0;
    _a2 = a2 / a0;
  }

  @override
  double process(double x) {
    final y = _b0 * x + _b1 * _x1 + _b2 * _x2 - _a1 * _y1 - _a2 * _y2;
    _x2 = _x1;
    _x1 = x;
    _y2 = _y1;
    // Flush denormals / guard against blow-ups from extreme settings.
    _y1 = y.isFinite ? (y.abs() < 1e-20 ? 0 : y) : 0;
    return _y1;
  }

  @override
  void reset() => _x1 = _x2 = _y1 = _y2 = 0;
}

/// `2π / sampleRate`, the radians-per-sample factor for 1 Hz.
double twoPiOver(int sampleRate) => 2 * math.pi / sampleRate;
