/// Single source of truth for the [PlayerProfile].
///
/// Every mutation goes through a method here, which updates the model,
/// notifies listeners (UI rebuilds via `ListenableBuilder`) and persists the
/// JSON. Pure rules live in `lib/data/services/`; this class glues them to the
/// stored state.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/utils/clock.dart';
import '../../game/catalog/bikes/bike_catalog.dart';
import '../../game/catalog/levels/level_spec.dart';
import '../../game/catalog/paints/paint_catalog.dart';
import '../../game/catalog/upgrades/upgrade_catalog.dart';
import '../../game/catalog/upgrades/upgrade_type.dart';
import '../../game/economy/economy_rules.dart';
import '../../game/session/game_mode.dart';
import '../../game/session/run_result.dart';
import '../models/achievement_type.dart';
import '../models/daily_task_type.dart';
import '../models/player_profile.dart';
import '../models/reward.dart';
import '../services/achievement_service.dart';
import '../services/chest_service.dart';
import '../services/daily_reward_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/lucky_wheel_service.dart';
import '../storage/local_storage.dart';

/// Outcome of a shop action.
enum PurchaseResult {
  success,
  notEnoughCoins,
  notEnoughGems,
  levelTooLow,
  alreadyOwned,
  notOwned,
  maxed,
}

class ProfileRepository extends ChangeNotifier {
  ProfileRepository(this._storage, {math.Random? random})
      : _random = random ?? math.Random();

  /// App-wide instance, assigned in `bootstrap()` (and in tests).
  static late ProfileRepository instance;

  static const String storageKey = 'profile.v1';

  /// Level-up bonus gems per gained player level.
  static const int levelUpGems = 2;

  /// Free ride grants a chest every this many meters cruised (lifetime).
  static const double freeRideChestEvery = 5000;

  final LocalStorage _storage;
  final math.Random _random;
  PlayerProfile _profile = PlayerProfile.newPlayer();
  Future<void> _pendingSave = Future.value();

  PlayerProfile get profile => _profile;

  Future<void> load() async {
    final json = _storage.readJson(storageKey);
    _profile = json == null ? PlayerProfile.newPlayer() : PlayerProfile.fromJson(json);
    notifyListeners();
  }

  /// Waits for queued writes (tests / before app exit).
  Future<void> flush() => _pendingSave;

  void _commit() {
    notifyListeners();
    final snapshot = _profile.toJson();
    _pendingSave = _pendingSave.then((_) => _storage.writeJson(storageKey, snapshot));
  }

  // ---- Currency ------------------------------------------------------------

  bool canAfford({int coins = 0, int gems = 0}) =>
      _profile.coins >= coins && _profile.gems >= gems;

  /// Spends currency if affordable. Returns false (and changes nothing) if not.
  bool spend({int coins = 0, int gems = 0}) {
    if (!canAfford(coins: coins, gems: gems)) return false;
    _profile
      ..coins -= coins
      ..gems -= gems;
    _commit();
    return true;
  }

  /// Revive handler for `RunConfig.onReviveRequested`.
  Future<bool> spendGemsForRevive(int gemCost) async => spend(gems: gemCost);

  void grant(Reward r) {
    if (r.isEmpty) return;
    _addReward(r);
    _commit();
  }

  void _addReward(Reward r) {
    _profile
      ..coins += r.coins
      ..gems += r.gems
      ..chests += r.chests;
  }

  // ---- Garage --------------------------------------------------------------

  PurchaseResult buyBike(int bikeId) {
    final bike = BikeCatalog.byId(bikeId);
    if (_profile.ownedBikes.contains(bike.id)) return PurchaseResult.alreadyOwned;
    if (_profile.level < bike.requiredPlayerLevel) return PurchaseResult.levelTooLow;
    if (_profile.coins < bike.priceCoins) return PurchaseResult.notEnoughCoins;
    if (_profile.gems < bike.priceGems) return PurchaseResult.notEnoughGems;
    _profile
      ..coins -= bike.priceCoins
      ..gems -= bike.priceGems
      ..ownedBikes.add(bike.id)
      ..selectedBike = bike.id;
    _commit();
    return PurchaseResult.success;
  }

  void selectBike(int bikeId) {
    if (!_profile.ownedBikes.contains(bikeId) || _profile.selectedBike == bikeId) return;
    _profile.selectedBike = bikeId;
    _commit();
  }

  PurchaseResult buyUpgrade(int bikeId, UpgradeType type) {
    if (!_profile.ownedBikes.contains(bikeId)) return PurchaseResult.notOwned;
    final current = _profile.upgradeLevel(bikeId, type);
    if (current >= UpgradeCatalog.maxLevel) return PurchaseResult.maxed;
    final coins = UpgradeCatalog.costFor(type, current, BikeCatalog.byId(bikeId));
    final gems = UpgradeCatalog.gemCostFor(current);
    if (_profile.coins < coins) return PurchaseResult.notEnoughCoins;
    if (_profile.gems < gems) return PurchaseResult.notEnoughGems;
    _profile
      ..coins -= coins
      ..gems -= gems;
    (_profile.upgrades[bikeId] ??= {})[type] = current + 1;
    _profile.stats.upgradesBought++;
    _commit();
    return PurchaseResult.success;
  }

  PurchaseResult buyPaint(int bikeId, int paintIndex) {
    if (!_profile.ownedBikes.contains(bikeId)) return PurchaseResult.notOwned;
    if (_profile.ownsPaint(bikeId, paintIndex)) return PurchaseResult.alreadyOwned;
    final price = PaintCatalog.all[paintIndex].priceCoins;
    if (_profile.coins < price) return PurchaseResult.notEnoughCoins;
    _profile.coins -= price;
    (_profile.ownedPaints[bikeId] ??= {}).add(paintIndex);
    _profile.selectedPaint[bikeId] = paintIndex;
    _commit();
    return PurchaseResult.success;
  }

  void selectPaint(int bikeId, int paintIndex) {
    if (!_profile.ownsPaint(bikeId, paintIndex)) return;
    _profile.selectedPaint[bikeId] = paintIndex;
    _commit();
  }

  // ---- Runs ----------------------------------------------------------------

  /// Credits a finished run and returns what was earned.
  /// [level] is required for missions (stars / completion bonus).
  RewardSummary applyRunResult(RunResult r, LevelSpec? level) {
    final p = _profile;
    final now = AppClock.now();

    var runCoins = r.coins;
    if (r.mode == GameMode.freeRide) {
      runCoins = (r.coins * EconomyRules.freeRideCoinFactor).round();
    }
    var completionCoins = 0;
    var starCoins = 0;
    var gems = r.gems;
    var newStars = 0;
    var chest = false;
    var newRecord = false;
    var firstCompletion = false;
    var levelStars = 0;
    final previousBest = p.bestEndlessMeters;

    if (r.mode == GameMode.mission && level != null) {
      final prev = p.starsOf(level.number);
      final earned = r.completed ? math.max(1, r.stars) : 0;
      levelStars = math.max(prev, earned);
      if (r.completed) {
        newStars = math.max(0, earned - prev);
        firstCompletion = prev == 0;
        if (firstCompletion) completionCoins = EconomyRules.levelCompletionCoins(level);
        starCoins = newStars * EconomyRules.newStarBonusCoins(level);
        if (earned >= 3 && prev < 3) gems += EconomyRules.gemsForThreeStars(level);
        if (firstCompletion && level.number % 5 == 0) chest = true;
        p.levelStars[level.number] = levelStars;
        p.stats.levelsCompleted++;
      }
    } else if (r.mode == GameMode.endless) {
      if (r.distanceMeters > p.bestEndlessMeters) {
        newRecord = true;
        if (r.distanceMeters >= 1000) chest = true;
        p.bestEndlessMeters = r.distanceMeters;
      }
    } else if (r.mode == GameMode.freeRide) {
      final before = (p.stats.freeRideDistance / freeRideChestEvery).floor();
      final after = ((p.stats.freeRideDistance + r.distanceMeters) / freeRideChestEvery).floor();
      chest = after > before;
      p.stats.freeRideDistance += r.distanceMeters;
    }

    // Lifetime stats.
    p.stats
      ..runs += 1
      ..distance += r.distanceMeters
      ..coins += runCoins
      ..jumps += r.jumps
      ..ducks += r.ducks
      ..nearMisses += r.nearMisses
      ..powerUps += r.powerUpsUsed;
    DailyTasksService.recordRun(p.tasks, r, now);

    // XP & level ups.
    final xp = EconomyRules.xpForRun(
      distanceMeters: r.distanceMeters,
      coins: r.coins,
      stars: r.mode == GameMode.mission ? r.stars : 0,
    );
    final levelUps = _addXp(xp);
    gems += levelUps * levelUpGems;

    final total = runCoins + completionCoins + starCoins;
    _addReward(Reward(coins: total, gems: gems, chests: chest ? 1 : 0));
    _commit();

    return RewardSummary(
      runCoins: runCoins,
      completionCoins: completionCoins,
      starCoins: starCoins,
      gems: gems,
      xp: xp,
      levelUps: levelUps,
      newPlayerLevel: p.level,
      newStars: newStars,
      totalStarsForLevel: levelStars,
      chestEarned: chest,
      newRecord: newRecord,
      previousBest: previousBest,
      firstCompletion: firstCompletion,
    );
  }

  /// Adds XP and returns the number of levels gained.
  int _addXp(int amount) {
    final p = _profile;
    var ups = 0;
    p.xp += amount;
    while (p.level < EconomyRules.maxPlayerLevel &&
        p.xp >= EconomyRules.xpForNextLevel(p.level)) {
      p.xp -= EconomyRules.xpForNextLevel(p.level);
      p.level++;
      ups++;
    }
    if (p.level >= EconomyRules.maxPlayerLevel) p.xp = 0;
    return ups;
  }

  // ---- Engagement ----------------------------------------------------------

  DailyRewardStatus get dailyStatus => DailyRewardService.status(_profile.daily, AppClock.now());

  Reward? claimDailyReward() {
    final r = DailyRewardService.claim(_profile.daily, AppClock.now());
    if (r == null) return null;
    _addReward(r);
    _commit();
    return r;
  }

  List<DailyTask> get dailyTasks => DailyTasksService.tasksFor(_profile, AppClock.now());

  Reward? claimTask(DailyTaskType type) {
    final now = AppClock.now();
    final task = DailyTasksService.tasksFor(_profile, now)
        .where((t) => t.type == type)
        .firstOrNull;
    if (task == null || !task.canClaim) return null;
    DailyTasksService.ensureToday(_profile.tasks, now);
    _profile.tasks.claimed.add(type);
    _addReward(task.reward);
    _commit();
    return task.reward;
  }

  Reward? claimTaskBonus() {
    final now = AppClock.now();
    if (!DailyTasksService.canClaimBonus(_profile, now)) return null;
    DailyTasksService.ensureToday(_profile.tasks, now);
    _profile.tasks.bonusClaimed = true;
    _addReward(DailyTasksService.bonusReward);
    _commit();
    return DailyTasksService.bonusReward;
  }

  Reward? claimAchievement(AchievementType type) {
    final r = AchievementService.claim(_profile, type);
    if (r == null) return null;
    _addReward(r);
    _commit();
    return r;
  }

  bool get canSpinFree => LuckyWheelService.canSpinFree(_profile.lastFreeSpin, AppClock.now());

  /// Spins the wheel (free if available, otherwise for gems). Returns the
  /// winning segment index (reward already credited) or null if unaffordable.
  int? spinWheel() {
    final free = canSpinFree;
    if (!free && _profile.gems < LuckyWheelService.paidSpinGems) return null;
    if (free) {
      _profile.lastFreeSpin = AppClock.now();
    } else {
      _profile.gems -= LuckyWheelService.paidSpinGems;
    }
    final index = LuckyWheelService.pickSegment(_random);
    _addReward(LuckyWheelService.segments[index].reward);
    _commit();
    return index;
  }

  /// Opens one mystery chest. Returns its contents or null if none left.
  Reward? openChest() {
    if (_profile.chests <= 0) return null;
    _profile.chests--;
    final r = ChestService.roll(_profile.level, _random);
    _addReward(r);
    _commit();
    return r;
  }

  /// Wipes all progress (settings are kept).
  Future<void> resetProgress() async {
    _profile = PlayerProfile.newPlayer();
    _commit();
    await flush();
  }
}
