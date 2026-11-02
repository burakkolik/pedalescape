/// Central economy tuning. Every reward / price formula that is not specific to
/// a catalog item lives here so balancing happens in one file.
/// See docs/ECONOMY.md for the reasoning behind the numbers.
library;

import 'dart:math' as math;

import '../catalog/levels/level_spec.dart';

abstract final class EconomyRules {
  // ---- Player XP ---------------------------------------------------------
  static const int maxPlayerLevel = 100;

  /// XP needed to go from [level] to [level] + 1.
  static int xpForNextLevel(int level) =>
      (120 * math.pow(level, 1.55) + 200).round();

  /// Rank title index (1..10) for a player level.
  static int rankForLevel(int level) => (1 + (level - 1) ~/ 10).clamp(1, 10);

  /// XP from a run.
  static int xpForRun({required double distanceMeters, required int coins, required int stars}) =>
      (distanceMeters / 20 + coins * 0.5 + stars * 40).round();

  // ---- Mission rewards ---------------------------------------------------
  /// Coins for finishing a level the first time for each new star.
  static int levelCompletionCoins(LevelSpec level) =>
      (60 + level.number * 9 + level.lengthMeters / 40).round();

  static int newStarBonusCoins(LevelSpec level) => 40 + level.number * 3;

  /// Gems are rare: 1 gem for every new 3-star, 5 for boss levels.
  static int gemsForThreeStars(LevelSpec level) => level.isBoss ? 5 : 1;

  // ---- Endless / free ride ------------------------------------------------
  /// Free ride pays only a part of coin value (it has no risk).
  static const double freeRideCoinFactor = 0.35;

  // ---- Revive ------------------------------------------------------------
  /// Gem cost of the n-th revive in the same run (1, 2, 4, 8 ...).
  static int reviveCost(int reviveIndex) => math.pow(2, reviveIndex).toInt();

  // ---- Daily login (7-day cycle, streak scaling) -------------------------
  static const List<int> dailyCoins = [200, 350, 500, 750, 1000, 1500, 2500];
  static const List<int> dailyGems = [0, 0, 1, 0, 2, 0, 5];

  /// Streak multiplier: every full week adds +10% (max +100%).
  static double streakMultiplier(int streakDays) =>
      1 + math.min(1.0, (streakDays ~/ 7) * 0.1);

  // ---- Lucky wheel (one free spin per 8 hours) ---------------------------
  static const Duration freeSpinCooldown = Duration(hours: 8);

  // ---- Daily tasks -------------------------------------------------------
  static const int dailyTaskCount = 3;
  static int taskRewardCoins(int playerLevel) => 150 + playerLevel * 25;
  static const int allTasksBonusGems = 2;
}
