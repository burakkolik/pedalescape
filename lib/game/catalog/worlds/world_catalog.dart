/// The 12 worlds (biomes). Visual themes live in
/// `lib/game/world/biome/biome_theme.dart`; this file only holds progression
/// data. Localized names: `world{index + 1}`.
library;

class WorldDefinition {
  const WorldDefinition({required this.index, required this.firstLevel});

  /// 0-based world index.
  final int index;

  /// 1-based number of the first level in this world.
  final int firstLevel;

  int get lastLevel => firstLevel + WorldCatalog.levelsPerWorld - 1;
}

abstract final class WorldCatalog {
  static const int count = 12;
  static const int levelsPerWorld = 25;
  static const int totalLevels = count * levelsPerWorld; // 300

  static final List<WorldDefinition> all = List.unmodifiable([
    for (var i = 0; i < count; i++)
      WorldDefinition(index: i, firstLevel: i * levelsPerWorld + 1),
  ]);

  /// 0-based world index for a 1-based level number.
  static int worldOfLevel(int levelNumber) =>
      ((levelNumber - 1) ~/ levelsPerWorld).clamp(0, count - 1);
}
