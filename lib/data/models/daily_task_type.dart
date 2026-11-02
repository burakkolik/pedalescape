/// The 8 kinds of daily task (texts: `task*` keys in the ARB files).
/// Persisted by [name] — renaming a value breaks saves.
library;

enum DailyTaskType {
  collectCoins,
  rideDistance,
  jump,
  duck,
  nearMiss,
  powerUps,
  levels,
  freeRide,
}
