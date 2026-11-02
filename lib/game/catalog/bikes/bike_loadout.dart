/// A specific bike with its upgrades and paint: the input to gameplay and the
/// garage stat bars. All derived stats are computed here so UI and physics
/// always agree.
library;

import 'dart:ui';

import '../paints/paint_catalog.dart';
import '../upgrades/upgrade_catalog.dart';
import '../upgrades/upgrade_type.dart';
import 'bike_catalog.dart';
import 'bike_definition.dart';

class BikeLoadout {
  const BikeLoadout({
    required this.bikeId,
    this.paintIndex = 0,
    this.upgradeLevels = const {},
  });

  final int bikeId;
  final int paintIndex;
  final Map<UpgradeType, int> upgradeLevels;

  BikeDefinition get bike => BikeCatalog.byId(bikeId);

  int level(UpgradeType t) =>
      (upgradeLevels[t] ?? 0).clamp(0, UpgradeCatalog.maxLevel);

  /// Upgrade fraction 0..1.
  double _f(UpgradeType t) => level(t) / UpgradeCatalog.maxLevel;

  // ---- Effective ratings (base 1..13 + up to +5 from upgrades) -----------
  double get speedRating => bike.speed + 5 * _f(UpgradeType.gearRatio);
  double get accelerationRating => bike.acceleration + 5 * _f(UpgradeType.chain);
  double get handlingRating => bike.handling + 5 * _f(UpgradeType.steering);
  double get jumpRating => bike.jump + 5 * _f(UpgradeType.suspension);
  double get durabilityRating =>
      bike.durability + 3 * _f(UpgradeType.frame) + 2 * _f(UpgradeType.tires);
  double get luckRating => bike.luck + 5 * _f(UpgradeType.luck);

  /// Max rating used to normalize stat bars.
  static const double maxRating = 18;

  // ---- Physics-facing values --------------------------------------------
  /// Multiplier on the level's speed curve (0.9 .. 1.35).
  double get speedMultiplier => 0.9 + speedRating / maxRating * 0.45;

  /// m/s² of acceleration toward the target speed.
  double get accelerationPerSecond => 2.5 + accelerationRating * 0.55;

  /// Seconds needed to switch one lane (0.34 .. 0.14).
  double get laneSwitchSeconds => 0.34 - handlingRating / maxRating * 0.2;

  /// Jump apex height in meters (1.25 .. 2.4).
  double get jumpHeight => 1.25 + jumpRating / maxRating * 1.15;

  /// Extra hits absorbed before a stumble counts (0..3).
  int get armorPoints => (durabilityRating / 5).floor().clamp(0, 3);

  /// Fraction of speed lost on a stumble (0.45 .. 0.2).
  double get stumbleSlowdown => 0.45 - 0.25 * _f(UpgradeType.tires);

  double get magnetSeconds => 8 + 0.9 * level(UpgradeType.magnet);
  double get shieldSeconds => 8 + 0.9 * level(UpgradeType.shield);
  double get turboSeconds => 4 + 0.5 * level(UpgradeType.turbo);
  double get doubleCoinsSeconds => 10 + 0.5 * level(UpgradeType.coinPouch);

  /// Coin value multiplier (1.0 .. 2.0).
  double get coinMultiplier => 1 + 0.1 * level(UpgradeType.coinPouch);

  /// Spawn chance multiplier for power-ups/gems (1.0 .. ~2.2).
  double get luckMultiplier => 0.8 + luckRating / maxRating * 1.4;

  /// Fog/visibility bonus at night (0..1).
  double get headlightStrength => 0.25 + 0.075 * level(UpgradeType.headlight);

  /// Single number shown to players and compared with level recommendations.
  int get power {
    final r = speedRating * 1.4 +
        accelerationRating +
        handlingRating * 1.1 +
        jumpRating * 0.8 +
        durabilityRating * 1.2 +
        luckRating * 0.5;
    var upg = 0;
    for (final t in UpgradeType.values) {
      upg += level(t);
    }
    return (r * 9 + upg * 2.2).round();
  }

  Color get frameColor =>
      PaintCatalog.all[paintIndex.clamp(0, PaintCatalog.all.length - 1)].frameColor ??
      bike.style.frameColor;

  Color get accentColor =>
      PaintCatalog.all[paintIndex.clamp(0, PaintCatalog.all.length - 1)].accentColor ??
      bike.style.accentColor;
}
