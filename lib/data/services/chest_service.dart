/// Mystery chest contents: always coins (scaled with player level), often
/// gems, rarely a gem jackpot.
library;

import 'dart:math' as math;

import '../../core/utils/num_utils.dart';
import '../models/reward.dart';

abstract final class ChestService {
  static Reward roll(int playerLevel, math.Random random) {
    final coins = NumUtils.roundTo(
      250 + playerLevel * 45 + random.nextInt(400 + playerLevel * 20),
      10,
    );
    final roll = random.nextDouble();
    final gems = roll < 0.05 ? 10 : (roll < 0.45 ? 1 + random.nextInt(3) : 0);
    return Reward(coins: coins, gems: gems);
  }
}
