/// The 10 achievement families (each has 5 tiers, see `AchievementService`).
/// Persisted by [name] — renaming a value breaks saves.
library;

enum AchievementType {
  distance,
  coins,
  jumps,
  levels,
  stars,
  bikes,
  upgrades,
  nearMiss,
  streak,
  endless,
}
