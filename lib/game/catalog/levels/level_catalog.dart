/// Deterministic generator for all 300 mission levels.
///
/// Levels are not stored: they are rebuilt from their number, so tweaking a
/// formula here re-balances the whole campaign. See docs/LEVEL_DESIGN.md.
library;

import 'dart:math' as math;

import '../worlds/world_catalog.dart';
import 'level_spec.dart';

abstract final class LevelCatalog {
  static int get count => WorldCatalog.totalLevels;

  static final Map<int, LevelSpec> _cache = {};

  static LevelSpec byNumber(int number) {
    final n = number.clamp(1, count);
    return _cache.putIfAbsent(n, () => _build(n));
  }

  /// Total stars required before [number] can be started. The first level of
  /// each world needs ~2 stars per previous level; inside a world the only
  /// requirement is finishing the previous level.
  static int starsRequiredFor(int number) {
    final world = WorldCatalog.worldOfLevel(number);
    final isFirstOfWorld = (number - 1) % WorldCatalog.levelsPerWorld == 0;
    if (!isFirstOfWorld || world == 0) return 0;
    return (world * WorldCatalog.levelsPerWorld * 2.1).round();
  }

  static LevelSpec _build(int n) {
    final t = (n - 1) / (count - 1); // 0..1 campaign progress
    final world = WorldCatalog.worldOfLevel(n);
    final inWorld = (n - 1) % WorldCatalog.levelsPerWorld; // 0..24
    final rnd = math.Random(n * 7919 + 17);
    final isBoss = inWorld == WorldCatalog.levelsPerWorld - 1;

    // Length: 1.6 km at level 1 → ~32 km at level 300, with a saw-tooth
    // inside each world so difficulty "breathes" (easy → hard → boss).
    final sawTooth = 0.75 + 0.5 * (inWorld / (WorldCatalog.levelsPerWorld - 1));
    var length = (1600 + 100 * (n - 1)) * sawTooth;
    if (isBoss) length *= 1.35;
    length = (length / 100).roundToDouble() * 100;

    final startSpeed = 11 + 7 * t + rnd.nextDouble();
    final maxSpeed = startSpeed + 7 + 9 * t;
    final density = (0.22 + 0.6 * t + 0.12 * (inWorld / 24) + (isBoss ? 0.08 : 0))
        .clamp(0.2, 0.95);

    // Coin target ~ 45% of coins a perfect run would collect.
    final coinTarget = ((length / 1000) * 70 * (0.75 + 0.35 * t)).round();
    final avgSpeed = (startSpeed + maxSpeed) / 2;
    final timeLimit = (length / avgSpeed * 1.08).ceil() + 5;

    final power = (100 + 900 * math.pow(t, 0.85) + inWorld * 3).round();

    final tod = TimeOfDay.values[(n + world) % TimeOfDay.values.length];
    final weather = _weatherFor(world, rnd);

    return LevelSpec(
      number: n,
      worldIndex: world,
      seed: n * 104729 + 3,
      lengthMeters: length,
      startSpeed: startSpeed,
      maxSpeed: maxSpeed,
      obstacleDensity: density.toDouble(),
      coinTarget: coinTarget,
      timeLimitSeconds: timeLimit,
      thirdStar: n % 3 == 0 ? ThirdStarObjective.timeLimit : ThirdStarObjective.noCrash,
      recommendedPower: power,
      curviness: 0.3 + 0.7 * rnd.nextDouble(),
      hilliness: 0.2 + 0.8 * rnd.nextDouble(),
      timeOfDay: world == 4 || world == 11 ? TimeOfDay.night : tod,
      weather: weather,
      unlockedObstacleTier: math.min(5, (n / 20).floor()),
      isBoss: isBoss,
    );
  }

  static Weather _weatherFor(int world, math.Random rnd) {
    final roll = rnd.nextDouble();
    switch (world) {
      case 1:
        return roll < 0.6 ? Weather.leaves : Weather.clear;
      case 5:
        return roll < 0.7 ? Weather.snow : Weather.fog;
      case 6:
        return roll < 0.45 ? Weather.rain : Weather.clear;
      case 7:
        return roll < 0.6 ? Weather.leaves : Weather.clear;
      case 8:
        return roll < 0.35 ? Weather.rain : (roll < 0.55 ? Weather.fog : Weather.clear);
      default:
        return roll < 0.15 ? Weather.rain : (roll < 0.25 ? Weather.fog : Weather.clear);
    }
  }
}
