/// Upgrade tuning: max level, costs and per-level effect sizes.
library;

import 'dart:math' as math;

import '../bikes/bike_definition.dart';
import 'upgrade_type.dart';

abstract final class UpgradeCatalog {
  /// Every upgrade has the same number of levels.
  static const int maxLevel = 10;

  /// Base coin cost of the first level per upgrade (before bike multiplier).
  static const Map<UpgradeType, int> _baseCost = {
    UpgradeType.gearRatio: 400,
    UpgradeType.chain: 350,
    UpgradeType.steering: 300,
    UpgradeType.suspension: 300,
    UpgradeType.frame: 500,
    UpgradeType.tires: 300,
    UpgradeType.magnet: 250,
    UpgradeType.shield: 250,
    UpgradeType.turbo: 250,
    UpgradeType.coinPouch: 600,
    UpgradeType.luck: 450,
    UpgradeType.headlight: 200,
  };

  /// Cost growth per level. 1.55^9 ≈ 52x between first and last level.
  static const double growth = 1.55;

  /// Coin cost to go from [currentLevel] to [currentLevel] + 1.
  static int costFor(UpgradeType type, int currentLevel, BikeDefinition bike) {
    final base = _baseCost[type]! * bike.upgradeCostMultiplier;
    final raw = base * math.pow(growth, currentLevel);
    // Round to "nice" numbers (multiples of 50) for a premium feel.
    return (raw / 50).round() * 50;
  }

  /// Gem cost (only the last two levels also need gems → long-term sink).
  static int gemCostFor(int currentLevel) =>
      currentLevel >= maxLevel - 2 ? 5 + (currentLevel - (maxLevel - 2)) * 5 : 0;

  /// Total coins needed to max every upgrade of [bike].
  static int totalCostToMax(BikeDefinition bike) {
    var sum = 0;
    for (final t in UpgradeType.values) {
      for (var l = 0; l < maxLevel; l++) {
        sum += costFor(t, l, bike);
      }
    }
    return sum;
  }
}
