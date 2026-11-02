/// Small reward value objects shared by services and UI.
library;

/// A bundle of currencies / chests granted at once.
class Reward {
  const Reward({this.coins = 0, this.gems = 0, this.chests = 0});

  final int coins;
  final int gems;
  final int chests;

  bool get isEmpty => coins == 0 && gems == 0 && chests == 0;

  Reward operator +(Reward o) =>
      Reward(coins: coins + o.coins, gems: gems + o.gems, chests: chests + o.chests);

  @override
  String toString() => 'Reward(coins: $coins, gems: $gems, chests: $chests)';
}

/// Everything a finished run gave the player (shown on the results screen).
class RewardSummary {
  const RewardSummary({
    this.runCoins = 0,
    this.completionCoins = 0,
    this.starCoins = 0,
    this.gems = 0,
    this.xp = 0,
    this.levelUps = 0,
    this.newPlayerLevel = 1,
    this.newStars = 0,
    this.totalStarsForLevel = 0,
    this.chestEarned = false,
    this.newRecord = false,
    this.previousBest = 0,
    this.firstCompletion = false,
  });

  /// Coins picked up during the run (after mode factor).
  final int runCoins;

  /// First-completion bonus (missions).
  final int completionCoins;

  /// Bonus for newly earned stars.
  final int starCoins;
  final int gems;
  final int xp;
  final int levelUps;
  final int newPlayerLevel;
  final int newStars;
  final int totalStarsForLevel;
  final bool chestEarned;

  /// Endless: new personal best.
  final bool newRecord;
  final double previousBest;
  final bool firstCompletion;

  int get totalCoins => runCoins + completionCoins + starCoins;
}
