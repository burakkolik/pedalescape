/// Small numeric helpers shared by UI and services.
library;

import 'dart:math' as math;

abstract final class NumUtils {
  /// Safe 0..1 fraction (returns 0 when [total] <= 0).
  static double fraction(num value, num total) {
    if (total <= 0) return 0;
    return (value / total).clamp(0.0, 1.0).toDouble();
  }

  /// Linear interpolation.
  static double lerp(double a, double b, double t) => a + (b - a) * t;

  /// Rounds to a "nice" multiple (e.g. 50 coins) for premium-looking prices.
  static int roundTo(num value, int step) => ((value / step).round() * step).toInt();

  /// Picks an index from [weights] using [random] (weights need not sum to 1).
  static int weightedIndex(List<num> weights, math.Random random) {
    final total = weights.fold<num>(0, (a, b) => a + b);
    var roll = random.nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll < 0) return i;
    }
    return weights.length - 1;
  }
}
