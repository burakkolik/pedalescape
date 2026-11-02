/// Three daily tasks generated deterministically from the local date (every
/// player gets the same tasks on the same day; no storage of definitions).
/// Progress is tracked in [DailyTasksState] and reset at local midnight.
library;

import 'dart:math' as math;

import '../../core/utils/date_keys.dart';
import '../../game/economy/economy_rules.dart';
import '../../game/session/game_mode.dart';
import '../../game/session/run_result.dart';
import '../models/daily_task_type.dart';
import '../models/player_profile.dart';
import '../models/reward.dart';

/// One of today's tasks with its live progress.
class DailyTask {
  const DailyTask({
    required this.type,
    required this.target,
    required this.progress,
    required this.claimed,
    required this.reward,
  });

  final DailyTaskType type;

  /// Count, or meters for distance tasks.
  final int target;
  final int progress;
  final bool claimed;
  final Reward reward;

  bool get isDone => progress >= target;
  bool get canClaim => isDone && !claimed;
  double get fraction => target <= 0 ? 1 : (progress / target).clamp(0.0, 1.0);

  /// Distance tasks store meters.
  bool get isDistance =>
      type == DailyTaskType.rideDistance || type == DailyTaskType.freeRide;
}

abstract final class DailyTasksService {
  /// Possible targets per task type (meters for distance tasks).
  static const Map<DailyTaskType, List<int>> targetOptions = {
    DailyTaskType.collectCoins: [150, 250, 400, 600],
    DailyTaskType.rideDistance: [2000, 3000, 5000, 8000],
    DailyTaskType.jump: [10, 20, 30, 40],
    DailyTaskType.duck: [10, 15, 25, 35],
    DailyTaskType.nearMiss: [5, 10, 15, 25],
    DailyTaskType.powerUps: [3, 5, 8, 10],
    DailyTaskType.levels: [1, 2, 3, 5],
    DailyTaskType.freeRide: [1000, 2000, 3000, 5000],
  };

  /// Deterministic (type, target) pairs for [dateKey].
  static List<(DailyTaskType, int)> definitionsFor(String dateKey) {
    final rnd = math.Random(DateKeys.seedOf(dateKey));
    final types = [...DailyTaskType.values]..shuffle(rnd);
    return [
      for (final t in types.take(EconomyRules.dailyTaskCount))
        (t, targetOptions[t]![rnd.nextInt(targetOptions[t]!.length)]),
    ];
  }

  /// Resets [s] when the stored day is not today.
  static void ensureToday(DailyTasksState s, DateTime now) {
    final key = DateKeys.of(now);
    if (s.dateKey != key) s.resetFor(key);
  }

  static List<DailyTask> tasksFor(PlayerProfile p, DateTime now) {
    final key = DateKeys.of(now);
    final sameDay = p.tasks.dateKey == key;
    final reward = Reward(coins: EconomyRules.taskRewardCoins(p.level));
    return [
      for (final (type, target) in definitionsFor(key))
        DailyTask(
          type: type,
          target: target,
          progress: sameDay ? (p.tasks.progress[type] ?? 0) : 0,
          claimed: sameDay && p.tasks.claimed.contains(type),
          reward: reward,
        ),
    ];
  }

  /// Adds a finished run's numbers to today's progress.
  static void recordRun(DailyTasksState s, RunResult r, DateTime now) {
    ensureToday(s, now);
    void add(DailyTaskType t, num v) {
      if (v <= 0) return;
      s.progress[t] = (s.progress[t] ?? 0) + v.round();
    }

    add(DailyTaskType.collectCoins, r.coins);
    add(DailyTaskType.rideDistance, r.distanceMeters);
    add(DailyTaskType.jump, r.jumps);
    add(DailyTaskType.duck, r.ducks);
    add(DailyTaskType.nearMiss, r.nearMisses);
    add(DailyTaskType.powerUps, r.powerUpsUsed);
    if (r.mode == GameMode.mission && r.completed) add(DailyTaskType.levels, 1);
    if (r.mode == GameMode.freeRide) add(DailyTaskType.freeRide, r.distanceMeters);
  }

  /// Number of tasks ready to claim (+1 if the all-done bonus is ready).
  static int claimableCount(PlayerProfile p, DateTime now) {
    final tasks = tasksFor(p, now);
    var n = tasks.where((t) => t.canClaim).length;
    if (canClaimBonus(p, now)) n++;
    return n;
  }

  static bool canClaimBonus(PlayerProfile p, DateTime now) {
    final tasks = tasksFor(p, now);
    final sameDay = p.tasks.dateKey == DateKeys.of(now);
    return tasks.every((t) => t.claimed) && !(sameDay && p.tasks.bonusClaimed);
  }

  static const Reward bonusReward = Reward(gems: EconomyRules.allTasksBonusGems);
}
