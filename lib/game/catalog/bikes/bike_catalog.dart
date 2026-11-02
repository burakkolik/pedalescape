/// The 15 bikes of the game, ordered from starter to legendary.
///
/// Balancing notes (see docs/ECONOMY.md):
/// * Prices grow roughly x1.6 per tier so the top bikes take months.
/// * Every bike has a clear identity (e.g. BMX = jump, Fat Yeti = durability,
///   Carbon Arrow = speed, Shadow Stealth = luck).
library;

import 'dart:ui';

import 'bike_definition.dart';
import 'bike_style.dart';

abstract final class BikeCatalog {
  static const List<BikeDefinition> all = [
    BikeDefinition(
      id: 1, priceCoins: 0, priceGems: 0, requiredPlayerLevel: 1,
      speed: 3, acceleration: 3, handling: 3, jump: 3, durability: 4, luck: 2,
      upgradeCostMultiplier: 1.0,
      style: BikeStyle(
        frame: FrameType.stepThrough, handlebar: HandlebarType.cruiser,
        frameColor: Color(0xFF2E86DE), accentColor: Color(0xFFF5F6FA),
        wheelRadius: 0.35, tireWidth: 0.055, hasBasket: true, hasFenders: true,
      ),
    ),
    BikeDefinition(
      id: 2, priceCoins: 3500, priceGems: 0, requiredPlayerLevel: 3,
      speed: 4, acceleration: 4, handling: 6, jump: 3, durability: 3, luck: 3,
      upgradeCostMultiplier: 1.15,
      style: BikeStyle(
        frame: FrameType.track, handlebar: HandlebarType.bullhorn,
        frameColor: Color(0xFFFF6B81), accentColor: Color(0xFF2F3542),
        wheelRadius: 0.34, tireWidth: 0.035, spokes: 24,
      ),
    ),
    BikeDefinition(
      id: 3, priceCoins: 9000, priceGems: 0, requiredPlayerLevel: 6,
      speed: 4, acceleration: 6, handling: 6, jump: 8, durability: 3, luck: 3,
      upgradeCostMultiplier: 1.3,
      style: BikeStyle(
        frame: FrameType.bmx, handlebar: HandlebarType.bmx,
        frameColor: Color(0xFFFFD23F), accentColor: Color(0xFF1E272E),
        wheelRadius: 0.26, tireWidth: 0.06, spokes: 36,
      ),
    ),
    BikeDefinition(
      id: 4, priceCoins: 18000, priceGems: 0, requiredPlayerLevel: 9,
      speed: 5, acceleration: 5, handling: 5, jump: 5, durability: 7, luck: 3,
      upgradeCostMultiplier: 1.5,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.riser,
        frameColor: Color(0xFF20BF6B), accentColor: Color(0xFF2D3436),
        wheelRadius: 0.36, tireWidth: 0.065, hasSuspensionFork: true,
      ),
    ),
    BikeDefinition(
      id: 5, priceCoins: 32000, priceGems: 0, requiredPlayerLevel: 12,
      speed: 6, acceleration: 6, handling: 6, jump: 5, durability: 5, luck: 5,
      upgradeCostMultiplier: 1.75,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.drop,
        frameColor: Color(0xFFB8860B), accentColor: Color(0xFF6D4C41),
        wheelRadius: 0.35, tireWidth: 0.045, hasFenders: true,
      ),
    ),
    BikeDefinition(
      id: 6, priceCoins: 55000, priceGems: 0, requiredPlayerLevel: 16,
      speed: 5, acceleration: 5, handling: 4, jump: 6, durability: 10, luck: 4,
      upgradeCostMultiplier: 2.0,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.riser,
        frameColor: Color(0xFFECF0F1), accentColor: Color(0xFF00A8FF),
        wheelRadius: 0.38, tireWidth: 0.12, spokes: 12,
      ),
    ),
    BikeDefinition(
      id: 7, priceCoins: 90000, priceGems: 0, requiredPlayerLevel: 20,
      speed: 7, acceleration: 10, handling: 6, jump: 5, durability: 6, luck: 5,
      upgradeCostMultiplier: 2.4,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.riser,
        frameColor: Color(0xFF0FB9B1), accentColor: Color(0xFFFFF200),
        wheelRadius: 0.35, tireWidth: 0.055, hasMotor: true, hasFenders: true,
        glowColor: Color(0xFF7DF9FF),
      ),
    ),
    BikeDefinition(
      id: 8, priceCoins: 140000, priceGems: 0, requiredPlayerLevel: 25,
      speed: 9, acceleration: 7, handling: 7, jump: 5, durability: 4, luck: 5,
      upgradeCostMultiplier: 2.9,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.drop,
        frameColor: Color(0xFF2D3436), accentColor: Color(0xFFFF3F34),
        wheelRadius: 0.34, tireWidth: 0.03, rimDepth: 0.06, spokes: 20,
      ),
    ),
    BikeDefinition(
      id: 9, priceCoins: 210000, priceGems: 0, requiredPlayerLevel: 30,
      speed: 7, acceleration: 7, handling: 7, jump: 8, durability: 9, luck: 5,
      upgradeCostMultiplier: 3.5,
      style: BikeStyle(
        frame: FrameType.fullSuspension, handlebar: HandlebarType.riser,
        frameColor: Color(0xFFFF7A1A), accentColor: Color(0xFF222222),
        wheelRadius: 0.37, tireWidth: 0.075, hasSuspensionFork: true,
        hasRearShock: true,
      ),
    ),
    BikeDefinition(
      id: 10, priceCoins: 320000, priceGems: 0, requiredPlayerLevel: 36,
      speed: 10, acceleration: 9, handling: 8, jump: 5, durability: 5, luck: 6,
      upgradeCostMultiplier: 4.2,
      style: BikeStyle(
        frame: FrameType.track, handlebar: HandlebarType.drop,
        frameColor: Color(0xFFF5F6FA), accentColor: Color(0xFF3742FA),
        wheelRadius: 0.34, tireWidth: 0.028, discWheels: true,
      ),
    ),
    BikeDefinition(
      id: 11, priceCoins: 460000, priceGems: 40, requiredPlayerLevel: 42,
      speed: 8, acceleration: 8, handling: 9, jump: 7, durability: 7, luck: 10,
      upgradeCostMultiplier: 5.0,
      style: BikeStyle(
        frame: FrameType.diamond, handlebar: HandlebarType.bullhorn,
        frameColor: Color(0xFF111111), accentColor: Color(0xFF8E44AD),
        wheelRadius: 0.35, tireWidth: 0.04, rimDepth: 0.05,
        glowColor: Color(0xFFB388FF),
      ),
    ),
    BikeDefinition(
      id: 12, priceCoins: 650000, priceGems: 80, requiredPlayerLevel: 48,
      speed: 9, acceleration: 8, handling: 8, jump: 7, durability: 12, luck: 7,
      upgradeCostMultiplier: 6.0,
      style: BikeStyle(
        frame: FrameType.fullSuspension, handlebar: HandlebarType.riser,
        frameColor: Color(0xFF95A5A6), accentColor: Color(0xFFE1B12C),
        wheelRadius: 0.37, tireWidth: 0.07, hasSuspensionFork: true,
        hasRearShock: true,
      ),
    ),
    BikeDefinition(
      id: 13, priceCoins: 900000, priceGems: 150, requiredPlayerLevel: 55,
      speed: 11, acceleration: 10, handling: 10, jump: 8, durability: 8, luck: 8,
      upgradeCostMultiplier: 7.2,
      style: BikeStyle(
        frame: FrameType.futuristic, handlebar: HandlebarType.drop,
        frameColor: Color(0xFFDFE6E9), accentColor: Color(0xFF00D2D3),
        wheelRadius: 0.35, tireWidth: 0.04, discWheels: true,
        glowColor: Color(0xFF48DBFB), trailColor: Color(0xFF48DBFB),
      ),
    ),
    BikeDefinition(
      id: 14, priceCoins: 1300000, priceGems: 250, requiredPlayerLevel: 63,
      speed: 12, acceleration: 11, handling: 10, jump: 9, durability: 10, luck: 9,
      upgradeCostMultiplier: 8.5,
      style: BikeStyle(
        frame: FrameType.futuristic, handlebar: HandlebarType.bullhorn,
        frameColor: Color(0xFFE84118), accentColor: Color(0xFFFBC531),
        wheelRadius: 0.36, tireWidth: 0.05, rimDepth: 0.06,
        glowColor: Color(0xFFFF9F43), trailColor: Color(0xFFFF6B1A),
      ),
    ),
    BikeDefinition(
      id: 15, priceCoins: 2000000, priceGems: 400, requiredPlayerLevel: 72,
      speed: 13, acceleration: 12, handling: 12, jump: 10, durability: 12, luck: 12,
      upgradeCostMultiplier: 10.0,
      style: BikeStyle(
        frame: FrameType.futuristic, handlebar: HandlebarType.drop,
        frameColor: Color(0xFF1B1464), accentColor: Color(0xFFFFD700),
        wheelRadius: 0.36, tireWidth: 0.045, discWheels: true,
        glowColor: Color(0xFFFFE066), trailColor: Color(0xFFC56CF0),
      ),
    ),
  ];

  static int get count => all.length;

  /// Returns the bike with [id] (1-based). Falls back to the starter bike.
  static BikeDefinition byId(int id) =>
      all.firstWhere((b) => b.id == id, orElse: () => all.first);
}
