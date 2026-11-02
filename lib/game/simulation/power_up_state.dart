/// Active power-up timers.
library;

import '../rendering/meshes/pickups/power_up_kind.dart';

class PowerUpState {
  final Map<PowerUpKind, double> remaining = {};
  final Map<PowerUpKind, double> duration = {};

  bool isActive(PowerUpKind k) => (remaining[k] ?? 0) > 0;

  void activate(PowerUpKind k, double seconds) {
    remaining[k] = seconds;
    duration[k] = seconds;
  }

  void tick(double dt) {
    for (final k in remaining.keys.toList()) {
      remaining[k] = (remaining[k]! - dt).clamp(0.0, 999.0);
    }
  }

  double fraction(PowerUpKind k) {
    final d = duration[k] ?? 0;
    return d <= 0 ? 0 : ((remaining[k] ?? 0) / d).clamp(0.0, 1.0);
  }

  Iterable<PowerUpKind> get active => remaining.keys.where(isActive);
}
