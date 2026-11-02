/// Immutable description of one mission level (generated deterministically).
library;

/// Which objective grants the third star.
enum ThirdStarObjective { noCrash, timeLimit }

/// Time of day used to light a level.
enum TimeOfDay { morning, noon, sunset, night }

/// Weather effect of a level / free ride.
enum Weather { clear, rain, snow, fog, leaves }

class LevelSpec {
  const LevelSpec({
    required this.number,
    required this.worldIndex,
    required this.seed,
    required this.lengthMeters,
    required this.startSpeed,
    required this.maxSpeed,
    required this.obstacleDensity,
    required this.coinTarget,
    required this.timeLimitSeconds,
    required this.thirdStar,
    required this.recommendedPower,
    required this.curviness,
    required this.hilliness,
    required this.timeOfDay,
    required this.weather,
    required this.unlockedObstacleTier,
    required this.isBoss,
  });

  /// 1-based level number (1..300).
  final int number;
  final int worldIndex;
  final int seed;
  final double lengthMeters;

  /// Speeds in m/s *before* bike stats are applied.
  final double startSpeed;
  final double maxSpeed;

  /// 0..1 — how packed the obstacle patterns are.
  final double obstacleDensity;

  /// Coins needed for the 2nd star.
  final int coinTarget;
  final int timeLimitSeconds;
  final ThirdStarObjective thirdStar;
  final int recommendedPower;
  final double curviness;
  final double hilliness;
  final TimeOfDay timeOfDay;
  final Weather weather;

  /// 0..5: higher tiers enable trickier obstacle patterns.
  final int unlockedObstacleTier;

  /// Every 25th level is a long "storm boss" level with extra danger.
  final bool isBoss;

  /// Checkpoints every 2 km (restart from checkpoint is free).
  static const double checkpointSpacing = 2000;
}
