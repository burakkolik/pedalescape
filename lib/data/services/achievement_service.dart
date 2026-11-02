/// Achievements: 10 families x 5 tiers. Tiers are claimed in order; each
/// claim grants coins + gems that grow with the tier.
library;

import '../../game/catalog/bikes/bike_catalog.dart';
import '../models/achievement_type.dart';
import '../models/player_profile.dart';
import '../models/reward.dart';

/// Progress snapshot of one achievement family.
class AchievementStatus {
  const AchievementStatus({
    required this.type,
    required this.claimedTiers,
    required this.progress,
  });

  final AchievementType type;

  /// 0..[AchievementService.tierCount].
  final int claimedTiers;
  final int progress;

  bool get isMaxed => claimedTiers >= AchievementService.tierCount;

  /// Threshold of the next tier to claim (last threshold when maxed).
  int get target => AchievementService.threshold(
      type, isMaxed ? AchievementService.tierCount - 1 : claimedTiers);

  bool get canClaim => !isMaxed && progress >= target;

  /// Progress toward [target] (previous tiers already subtracted visually).
  double get fraction => isMaxed ? 1 : (progress / target).clamp(0.0, 1.0);

  /// 1-based tier shown to the player.
  int get displayTier => isMaxed ? AchievementService.tierCount : claimedTiers + 1;

  Reward get nextReward => AchievementService.rewardForTier(
      isMaxed ? AchievementService.tierCount - 1 : claimedTiers);
}

abstract final class AchievementService {
  static const int tierCount = 5;

  /// Thresholds per tier (distances in meters).
  static const Map<AchievementType, List<int>> thresholds = {
    AchievementType.distance: [5000, 25000, 100000, 500000, 2000000],
    AchievementType.coins: [1000, 10000, 50000, 250000, 1000000],
    AchievementType.jumps: [50, 250, 1000, 5000, 20000],
    AchievementType.levels: [5, 25, 75, 150, 300],
    AchievementType.stars: [10, 60, 200, 500, 900],
    AchievementType.bikes: [2, 4, 7, 11, 15],
    AchievementType.upgrades: [5, 25, 60, 120, 240],
    AchievementType.nearMiss: [25, 150, 600, 2500, 10000],
    AchievementType.streak: [3, 7, 14, 30, 60],
    AchievementType.endless: [1000, 3000, 7500, 15000, 30000],
  };

  static const List<int> _tierCoins = [500, 1500, 4000, 10000, 25000];
  static const List<int> _tierGems = [1, 2, 5, 10, 20];

  static int threshold(AchievementType t, int tierIndex) =>
      thresholds[t]![tierIndex.clamp(0, tierCount - 1)];

  static Reward rewardForTier(int tierIndex) {
    final i = tierIndex.clamp(0, tierCount - 1);
    return Reward(coins: _tierCoins[i], gems: _tierGems[i]);
  }

  /// Distance-like achievements (formatted as meters/km in UI).
  static bool isDistance(AchievementType t) =>
      t == AchievementType.distance || t == AchievementType.endless;

  static int progressOf(PlayerProfile p, AchievementType t) => switch (t) {
        AchievementType.distance => p.stats.distance.floor(),
        AchievementType.coins => p.stats.coins,
        AchievementType.jumps => p.stats.jumps,
        AchievementType.levels => p.completedLevels,
        AchievementType.stars => p.totalStars,
        AchievementType.bikes =>
          p.ownedBikes.where((id) => id >= 1 && id <= BikeCatalog.count).length,
        AchievementType.upgrades => p.stats.upgradesBought,
        AchievementType.nearMiss => p.stats.nearMisses,
        AchievementType.streak => p.daily.bestStreak,
        AchievementType.endless => p.bestEndlessMeters.floor(),
      };

  static AchievementStatus statusOf(PlayerProfile p, AchievementType t) =>
      AchievementStatus(
        type: t,
        claimedTiers: (p.achievementTiers[t] ?? 0).clamp(0, tierCount),
        progress: progressOf(p, t),
      );

  static List<AchievementStatus> all(PlayerProfile p) =>
      [for (final t in AchievementType.values) statusOf(p, t)];

  static int claimableCount(PlayerProfile p) => all(p).where((s) => s.canClaim).length;

  /// Marks the next tier claimed. Returns the reward or null if not ready.
  static Reward? claim(PlayerProfile p, AchievementType t) {
    final s = statusOf(p, t);
    if (!s.canClaim) return null;
    p.achievementTiers[t] = s.claimedTiers + 1;
    return rewardForTier(s.claimedTiers);
  }
}
