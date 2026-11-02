/// Deterministic smooth 1D value noise (for track curves, hills, terrain).
library;

import 'dart:math' as math;

class ValueNoise1D {
  ValueNoise1D(int seed, {int size = 512}) : _values = List<double>.generate(
          size, (i) => math.Random(seed * 31 + i * 7).nextDouble() * 2 - 1);

  final List<double> _values;

  /// Smooth noise in -1..1.
  double sample(double x) {
    final n = _values.length;
    final xf = x.floorToDouble();
    final i = xf.toInt();
    final t = x - xf;
    final a = _values[i % n];
    final b = _values[(i + 1) % n];
    final s = t * t * (3 - 2 * t);
    return a + (b - a) * s;
  }

  /// Sum of octaves (fractal), still roughly in -1..1.
  double fractal(double x, {int octaves = 3}) {
    var sum = 0.0, amp = 1.0, freq = 1.0, norm = 0.0;
    for (var o = 0; o < octaves; o++) {
      sum += sample(x * freq + o * 13.7) * amp;
      norm += amp;
      amp *= 0.5;
      freq *= 2.03;
    }
    return sum / norm;
  }
}
