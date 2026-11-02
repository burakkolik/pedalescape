/// Lucky wheel: 8 weighted segments, one free spin per
/// [EconomyRules.freeSpinCooldown], extra spins cost gems.
library;

import 'dart:math' as math;

import '../../core/utils/num_utils.dart';
import '../../game/economy/economy_rules.dart';
import '../models/reward.dart';

/// One slice of the wheel.
class WheelSegment {
  const WheelSegment({required this.reward, required this.weight, this.isJackpot = false});

  final Reward reward;

  /// Relative chance.
  final int weight;
  final bool isJackpot;
}

abstract final class LuckyWheelService {
  /// Clockwise order as drawn, starting at the top pointer.
  static const List<WheelSegment> segments = [
    WheelSegment(reward: Reward(coins: 100), weight: 24),
    WheelSegment(reward: Reward(gems: 1), weight: 14),
    WheelSegment(reward: Reward(coins: 250), weight: 20),
    WheelSegment(reward: Reward(chests: 1), weight: 10),
    WheelSegment(reward: Reward(coins: 500), weight: 14),
    WheelSegment(reward: Reward(gems: 3), weight: 6),
    WheelSegment(reward: Reward(coins: 1000), weight: 8),
    WheelSegment(reward: Reward(gems: 10), weight: 4, isJackpot: true),
  ];

  /// Gem price of an extra spin while the free spin is on cooldown.
  static const int paidSpinGems = 5;

  static bool canSpinFree(DateTime? lastFreeSpin, DateTime now) =>
      untilFreeSpin(lastFreeSpin, now) == Duration.zero;

  static Duration untilFreeSpin(DateTime? lastFreeSpin, DateTime now) {
    if (lastFreeSpin == null) return Duration.zero;
    // A clock moved backwards does not grant extra spins, but also never
    // locks the wheel for longer than one cooldown.
    final elapsed = now.difference(lastFreeSpin);
    if (elapsed.isNegative) return EconomyRules.freeSpinCooldown;
    final left = EconomyRules.freeSpinCooldown - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  static int pickSegment(math.Random random) =>
      NumUtils.weightedIndex([for (final s in segments) s.weight], random);
}
