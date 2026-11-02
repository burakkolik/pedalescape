/// Static definition of one purchasable bike.
library;

import 'bike_style.dart';

/// Base stat ratings use a 1..10 scale. Upgrades add on top of these
/// (see `BikeLoadout`). The gameplay translates ratings into physics values in
/// `lib/game/simulation/physics/bike_physics_tuning.dart`.
class BikeDefinition {
  const BikeDefinition({
    required this.id,
    required this.priceCoins,
    required this.priceGems,
    required this.requiredPlayerLevel,
    required this.speed,
    required this.acceleration,
    required this.handling,
    required this.jump,
    required this.durability,
    required this.luck,
    required this.style,
    required this.upgradeCostMultiplier,
  });

  /// 1-based id. Also selects localized texts `bike{id}Name` / `bike{id}Desc`.
  final int id;
  final int priceCoins;

  /// Optional extra gem price (0 = coins only).
  final int priceGems;
  final int requiredPlayerLevel;

  final double speed;
  final double acceleration;
  final double handling;
  final double jump;
  final double durability;
  final double luck;

  final BikeStyle style;

  /// Scales the coin cost of every upgrade for this bike.
  final double upgradeCostMultiplier;

  bool get isStarter => priceCoins == 0 && priceGems == 0;
}
