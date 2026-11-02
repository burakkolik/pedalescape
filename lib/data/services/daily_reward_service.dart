/// 7-day login calendar with streak scaling.
///
/// Rules (fair): claim once per local calendar day. Claiming on consecutive
/// days advances the calendar (day 1 → 7, then loops) and the streak; missing
/// a day restarts at day 1 with streak 1. Rewards scale with
/// [EconomyRules.streakMultiplier]; day 7 also grants a mystery chest.
/// A clock set backwards (last claim in the "future") blocks claiming.
library;

import '../../core/utils/date_keys.dart';
import '../../core/utils/num_utils.dart';
import '../../game/economy/economy_rules.dart';
import '../models/player_profile.dart';
import '../models/reward.dart';

/// Read-only view of today's daily-login state.
class DailyRewardStatus {
  const DailyRewardStatus({
    required this.canClaim,
    required this.dayIndex,
    required this.streak,
    required this.untilNext,
  });

  final bool canClaim;

  /// 0..6. If [canClaim], the day that will be claimed; otherwise the day
  /// claimed today (or -1 if never claimed).
  final int dayIndex;

  /// Streak shown to the player (what it will be after claiming, or the
  /// current streak if already claimed today).
  final int streak;

  /// Time until the next claim becomes possible (zero if claimable now).
  final Duration untilNext;
}

abstract final class DailyRewardService {
  static const int cycleLength = 7;

  static DailyRewardStatus status(DailyLoginState s, DateTime now) {
    final today = DateKeys.of(now);
    final days = DateKeys.daysBetween(s.lastClaimDate, today);
    if (s.lastClaimDate != null && days != null && days <= 0) {
      return DailyRewardStatus(
        canClaim: false,
        dayIndex: s.cycleDay,
        streak: s.streak,
        untilNext: DateKeys.untilMidnight(now),
      );
    }
    final continues = days == 1 && s.cycleDay >= 0;
    return DailyRewardStatus(
      canClaim: true,
      dayIndex: continues ? (s.cycleDay + 1) % cycleLength : 0,
      streak: continues ? s.streak + 1 : 1,
      untilNext: Duration.zero,
    );
  }

  /// Reward for calendar [dayIndex] (0..6) at a given [streak].
  static Reward rewardFor(int dayIndex, int streak) {
    final i = dayIndex.clamp(0, cycleLength - 1);
    final coins = EconomyRules.dailyCoins[i] * EconomyRules.streakMultiplier(streak);
    return Reward(
      coins: NumUtils.roundTo(coins, 10),
      gems: EconomyRules.dailyGems[i],
      chests: i == cycleLength - 1 ? 1 : 0,
    );
  }

  /// Claims today's reward, mutating [s]. Returns null if not claimable.
  /// The caller credits the returned reward.
  static Reward? claim(DailyLoginState s, DateTime now) {
    final st = status(s, now);
    if (!st.canClaim) return null;
    s
      ..lastClaimDate = DateKeys.of(now)
      ..cycleDay = st.dayIndex
      ..streak = st.streak;
    if (s.streak > s.bestStreak) s.bestStreak = s.streak;
    return rewardFor(st.dayIndex, st.streak);
  }
}
