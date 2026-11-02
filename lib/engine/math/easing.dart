/// Easing & interpolation helpers shared by animations and simulation.
library;

import 'dart:math' as math;

abstract final class Easing {
  static double clamp01(double t) => t < 0 ? 0 : (t > 1 ? 1 : t);
  static double lerp(double a, double b, double t) => a + (b - a) * t;
  static double smoothstep(double t) {
    final x = clamp01(t);
    return x * x * (3 - 2 * x);
  }

  static double easeOutCubic(double t) => 1 - math.pow(1 - clamp01(t), 3).toDouble();
  static double easeInOutSine(double t) => -(math.cos(math.pi * clamp01(t)) - 1) / 2;
  static double easeOutBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    final x = clamp01(t) - 1;
    return 1 + c3 * x * x * x + c1 * x * x;
  }

  /// Frame-rate independent exponential approach of [current] to [target].
  static double approach(double current, double target, double rate, double dt) =>
      target + (current - target) * math.exp(-rate * dt);
}
