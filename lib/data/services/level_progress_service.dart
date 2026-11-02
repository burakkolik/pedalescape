/// Campaign unlock rules derived from [LevelCatalog] and the player's stars.
/// A level is playable when the previous level is finished AND the player has
/// the total stars required by [LevelCatalog.starsRequiredFor].
library;

import '../../game/catalog/levels/level_catalog.dart';
import '../../game/catalog/worlds/world_catalog.dart';
import '../models/player_profile.dart';

/// Why a level is locked.
enum LevelLockReason { none, previousLevel, stars }

abstract final class LevelProgressService {
  static LevelLockReason lockReason(PlayerProfile p, int level) {
    if (level <= 1) return LevelLockReason.none;
    if (!p.isCompleted(level - 1)) return LevelLockReason.previousLevel;
    if (p.totalStars < LevelCatalog.starsRequiredFor(level)) return LevelLockReason.stars;
    return LevelLockReason.none;
  }

  static bool isUnlocked(PlayerProfile p, int level) =>
      lockReason(p, level) == LevelLockReason.none;

  /// Stars still missing for [level] (0 if enough).
  static int starsMissing(PlayerProfile p, int level) =>
      (LevelCatalog.starsRequiredFor(level) - p.totalStars).clamp(0, 1 << 30);

  /// A world is unlocked once its first level is playable.
  static bool isWorldUnlocked(PlayerProfile p, int worldIndex) =>
      isUnlocked(p, WorldCatalog.all[worldIndex.clamp(0, WorldCatalog.count - 1)].firstLevel);

  /// Highest playable level (the "current" mission).
  static int currentLevel(PlayerProfile p) {
    var n = 1;
    while (n < LevelCatalog.count && isUnlocked(p, n + 1)) {
      if (!p.isCompleted(n)) break;
      n++;
    }
    return n;
  }

  /// Highest unlocked world index.
  static int currentWorld(PlayerProfile p) => WorldCatalog.worldOfLevel(currentLevel(p));

  /// Finished levels inside a world.
  static int completedInWorld(PlayerProfile p, int worldIndex) {
    final w = WorldCatalog.all[worldIndex];
    var n = 0;
    for (var l = w.firstLevel; l <= w.lastLevel; l++) {
      if (p.isCompleted(l)) n++;
    }
    return n;
  }

  static int starsInWorld(PlayerProfile p, int worldIndex) {
    final w = WorldCatalog.all[worldIndex];
    var n = 0;
    for (var l = w.firstLevel; l <= w.lastLevel; l++) {
      n += p.starsOf(l);
    }
    return n;
  }
}
