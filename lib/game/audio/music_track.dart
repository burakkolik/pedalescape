/// Identifiers for the procedurally composed music loops.
///
/// Each value maps to a style definition in `music_composer.dart`.
library;

/// Background music loops, one per game context.
enum MusicTrack {
  /// Chill, upbeat loop for menus and shops.
  menu,

  /// Energetic, driving loop for mission levels.
  mission,

  /// Tense, faster loop for endless runs.
  endless,

  /// Relaxed lo-fi loop for free ride.
  freeRide,
}
