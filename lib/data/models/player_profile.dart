/// The player's whole progress (currencies, bikes, levels, engagement state).
///
/// This model is deliberately *mutable*: it is owned by `ProfileRepository`,
/// which is the only place allowed to change it and which saves + notifies
/// listeners after every mutation. UI code must treat it as read-only.
///
/// JSON uses short keys and a schema version (`v`) for future migrations.
library;

import '../../game/catalog/bikes/bike_loadout.dart';
import '../../game/catalog/upgrades/upgrade_type.dart';
import 'achievement_type.dart';
import 'daily_task_type.dart';

/// Totals across all runs (drive achievements and stats).
class LifetimeStats {
  LifetimeStats({
    this.distance = 0,
    this.coins = 0,
    this.jumps = 0,
    this.ducks = 0,
    this.nearMisses = 0,
    this.powerUps = 0,
    this.levelsCompleted = 0,
    this.upgradesBought = 0,
    this.freeRideDistance = 0,
    this.runs = 0,
  });

  double distance;
  int coins;
  int jumps;
  int ducks;
  int nearMisses;
  int powerUps;
  int levelsCompleted;
  int upgradesBought;
  double freeRideDistance;
  int runs;

  Map<String, dynamic> toJson() => {
        'dist': distance,
        'coins': coins,
        'jumps': jumps,
        'ducks': ducks,
        'nm': nearMisses,
        'pu': powerUps,
        'lvl': levelsCompleted,
        'upg': upgradesBought,
        'fr': freeRideDistance,
        'runs': runs,
      };

  factory LifetimeStats.fromJson(Map<String, dynamic>? j) {
    if (j == null) return LifetimeStats();
    return LifetimeStats(
      distance: _d(j['dist']),
      coins: _i(j['coins']),
      jumps: _i(j['jumps']),
      ducks: _i(j['ducks']),
      nearMisses: _i(j['nm']),
      powerUps: _i(j['pu']),
      levelsCompleted: _i(j['lvl']),
      upgradesBought: _i(j['upg']),
      freeRideDistance: _d(j['fr']),
      runs: _i(j['runs']),
    );
  }
}

/// Daily login calendar state (7-day cycle).
class DailyLoginState {
  DailyLoginState({
    this.lastClaimDate,
    this.streak = 0,
    this.cycleDay = -1,
    this.bestStreak = 0,
  });

  /// `yyyy-MM-dd` of the last claim, null if never claimed.
  String? lastClaimDate;

  /// Consecutive days claimed up to [lastClaimDate].
  int streak;

  /// 0..6 index of the last claimed calendar day (-1 = never).
  int cycleDay;
  int bestStreak;

  Map<String, dynamic> toJson() => {
        'last': lastClaimDate,
        'streak': streak,
        'cycle': cycleDay,
        'best': bestStreak,
      };

  factory DailyLoginState.fromJson(Map<String, dynamic>? j) {
    if (j == null) return DailyLoginState();
    return DailyLoginState(
      lastClaimDate: j['last'] as String?,
      streak: _i(j['streak']),
      cycleDay: _i(j['cycle'], -1),
      bestStreak: _i(j['best']),
    );
  }
}

/// Progress on today's daily tasks. Task *definitions* are regenerated from
/// [dateKey] by `DailyTasksService`; only progress/claims are stored.
class DailyTasksState {
  DailyTasksState({
    this.dateKey,
    Map<DailyTaskType, int>? progress,
    Set<DailyTaskType>? claimed,
    this.bonusClaimed = false,
  })  : progress = progress ?? {},
        claimed = claimed ?? {};

  String? dateKey;
  final Map<DailyTaskType, int> progress;
  final Set<DailyTaskType> claimed;
  bool bonusClaimed;

  void resetFor(String key) {
    dateKey = key;
    progress.clear();
    claimed.clear();
    bonusClaimed = false;
  }

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'prog': {for (final e in progress.entries) e.key.name: e.value},
        'claimed': [for (final t in claimed) t.name],
        'bonus': bonusClaimed,
      };

  factory DailyTasksState.fromJson(Map<String, dynamic>? j) {
    if (j == null) return DailyTasksState();
    final prog = <DailyTaskType, int>{};
    final rawProg = j['prog'];
    if (rawProg is Map) {
      for (final t in DailyTaskType.values) {
        final v = rawProg[t.name];
        if (v != null) prog[t] = _i(v);
      }
    }
    final rawClaimed = j['claimed'];
    return DailyTasksState(
      dateKey: j['date'] as String?,
      progress: prog,
      claimed: {
        if (rawClaimed is List)
          for (final t in DailyTaskType.values)
            if (rawClaimed.contains(t.name)) t,
      },
      bonusClaimed: j['bonus'] as bool? ?? false,
    );
  }
}

class PlayerProfile {
  PlayerProfile({
    this.coins = 0,
    this.gems = 0,
    this.xp = 0,
    this.level = 1,
    Set<int>? ownedBikes,
    this.selectedBike = 1,
    Map<int, Map<UpgradeType, int>>? upgrades,
    Map<int, Set<int>>? ownedPaints,
    Map<int, int>? selectedPaint,
    Map<int, int>? levelStars,
    this.bestEndlessMeters = 0,
    LifetimeStats? stats,
    this.chests = 0,
    DailyLoginState? daily,
    this.lastFreeSpin,
    DailyTasksState? tasks,
    Map<AchievementType, int>? achievementTiers,
  })  : ownedBikes = ownedBikes ?? {1},
        upgrades = upgrades ?? {},
        ownedPaints = ownedPaints ?? {},
        selectedPaint = selectedPaint ?? {},
        levelStars = levelStars ?? {},
        stats = stats ?? LifetimeStats(),
        daily = daily ?? DailyLoginState(),
        tasks = tasks ?? DailyTasksState(),
        achievementTiers = achievementTiers ?? {};

  /// Starting balance for new players.
  factory PlayerProfile.newPlayer() => PlayerProfile(coins: 500, gems: 5);

  static const int schemaVersion = 1;

  int coins;
  int gems;

  /// XP collected inside the current [level].
  int xp;
  int level;

  final Set<int> ownedBikes;
  int selectedBike;

  /// bikeId → upgrade levels.
  final Map<int, Map<UpgradeType, int>> upgrades;

  /// bikeId → owned paint indices (index 0 is always owned).
  final Map<int, Set<int>> ownedPaints;

  /// bikeId → selected paint index.
  final Map<int, int> selectedPaint;

  /// Level number → best stars (1..3). Absent = never finished.
  final Map<int, int> levelStars;

  double bestEndlessMeters;
  final LifetimeStats stats;

  /// Unopened mystery chests.
  int chests;
  final DailyLoginState daily;

  /// Time of the last free lucky-wheel spin.
  DateTime? lastFreeSpin;
  final DailyTasksState tasks;

  /// Achievement → number of tiers already claimed (0..5).
  final Map<AchievementType, int> achievementTiers;

  // ---- Derived -----------------------------------------------------------

  int get totalStars => levelStars.values.fold(0, (a, b) => a + b);
  int get completedLevels => levelStars.values.where((s) => s > 0).length;
  int starsOf(int level) => levelStars[level] ?? 0;
  bool isCompleted(int level) => starsOf(level) > 0;

  int upgradeLevel(int bikeId, UpgradeType type) => upgrades[bikeId]?[type] ?? 0;

  int totalUpgradeLevels(int bikeId) =>
      upgrades[bikeId]?.values.fold<int>(0, (a, b) => a + b) ?? 0;

  bool ownsPaint(int bikeId, int paint) =>
      paint == 0 || (ownedPaints[bikeId]?.contains(paint) ?? false);

  int paintOf(int bikeId) => selectedPaint[bikeId] ?? 0;

  BikeLoadout loadoutFor(int bikeId) => BikeLoadout(
        bikeId: bikeId,
        paintIndex: paintOf(bikeId),
        upgradeLevels: Map.unmodifiable(upgrades[bikeId] ?? const {}),
      );

  BikeLoadout get selectedLoadout => loadoutFor(selectedBike);

  // ---- JSON --------------------------------------------------------------

  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        'coins': coins,
        'gems': gems,
        'xp': xp,
        'level': level,
        'bikes': ownedBikes.toList()..sort(),
        'sel': selectedBike,
        'upg': {
          for (final e in upgrades.entries)
            '${e.key}': {for (final u in e.value.entries) '${u.key.index}': u.value},
        },
        'paints': {
          for (final e in ownedPaints.entries) '${e.key}': e.value.toList()..sort(),
        },
        'selPaint': {for (final e in selectedPaint.entries) '${e.key}': e.value},
        'stars': {for (final e in levelStars.entries) '${e.key}': e.value},
        'bestEndless': bestEndlessMeters,
        'stats': stats.toJson(),
        'chests': chests,
        'daily': daily.toJson(),
        'spin': lastFreeSpin?.millisecondsSinceEpoch,
        'tasks': tasks.toJson(),
        'ach': {for (final e in achievementTiers.entries) e.key.name: e.value},
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> j) {
    final upgrades = <int, Map<UpgradeType, int>>{};
    final rawUpg = j['upg'];
    if (rawUpg is Map) {
      rawUpg.forEach((bike, levels) {
        final id = int.tryParse('$bike');
        if (id == null || levels is! Map) return;
        final m = <UpgradeType, int>{};
        levels.forEach((idx, lvl) {
          final i = int.tryParse('$idx');
          if (i != null && i >= 0 && i < UpgradeType.values.length) {
            m[UpgradeType.values[i]] = _i(lvl);
          }
        });
        upgrades[id] = m;
      });
    }
    final paints = <int, Set<int>>{};
    final rawPaints = j['paints'];
    if (rawPaints is Map) {
      rawPaints.forEach((bike, list) {
        final id = int.tryParse('$bike');
        if (id != null && list is List) paints[id] = {for (final p in list) _i(p)};
      });
    }
    final ach = <AchievementType, int>{};
    final rawAch = j['ach'];
    if (rawAch is Map) {
      for (final t in AchievementType.values) {
        if (rawAch[t.name] != null) ach[t] = _i(rawAch[t.name]);
      }
    }
    final bikes = <int>{
      1,
      if (j['bikes'] is List) for (final b in j['bikes'] as List) _i(b),
    };
    final spin = j['spin'];
    return PlayerProfile(
      coins: _i(j['coins']),
      gems: _i(j['gems']),
      xp: _i(j['xp']),
      level: _i(j['level'], 1).clamp(1, 1000),
      ownedBikes: bikes,
      selectedBike: bikes.contains(_i(j['sel'], 1)) ? _i(j['sel'], 1) : 1,
      upgrades: upgrades,
      ownedPaints: paints,
      selectedPaint: _intMap(j['selPaint']),
      levelStars: _intMap(j['stars']),
      bestEndlessMeters: _d(j['bestEndless']),
      stats: LifetimeStats.fromJson(_map(j['stats'])),
      chests: _i(j['chests']),
      daily: DailyLoginState.fromJson(_map(j['daily'])),
      lastFreeSpin: spin is num ? DateTime.fromMillisecondsSinceEpoch(spin.toInt()) : null,
      tasks: DailyTasksState.fromJson(_map(j['tasks'])),
      achievementTiers: ach,
    );
  }
}

// ---- JSON helpers (tolerant to missing / wrong types) ----------------------

int _i(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
double _d(Object? v) => v is num ? v.toDouble() : 0;
Map<String, dynamic>? _map(Object? v) =>
    v is Map ? v.map((k, val) => MapEntry('$k', val)) : null;
Map<int, int> _intMap(Object? v) {
  final out = <int, int>{};
  if (v is Map) {
    v.forEach((k, val) {
      final key = int.tryParse('$k');
      if (key != null) out[key] = _i(val);
    });
  }
  return out;
}
