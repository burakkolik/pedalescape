/// World constants. Units are meters / seconds.
class K {
  K._();

  /// Length of one road segment.
  static const double segLen = 2.0;

  /// Distance between lane centers. Lanes are -1, 0, 1.
  static const double laneW = 2.0;

  /// Half width of the asphalt.
  static const double roadHalf = 3.2;

  /// Width of the red/white kerb on both sides.
  static const double rumbleW = 0.55;

  /// Camera height above the ground under the player.
  static const double camHeight = 4.4;

  /// Distance from camera to player along the track.
  static const double playerDist = 4.4;

  /// Ring buffer size for generated segments (power of two).
  static const int ring = 1024;
  static const int ringMask = ring - 1;

  /// Max number of pooled world objects alive at once.
  static const int maxObjects = 96;

  /// Max number of screen particles.
  static const int maxParticles = 220;

  /// Distance ahead of the player at which new rows are spawned.
  static const double spawnAhead = 170.0;

  // Player physics.
  static const double jumpVel = 7.6;
  static const double gravity = 21.0;
  static const double duckTime = 0.75;

  // Speeds (m/s).
  static const double startSpeed = 15.0;
  static const double maxSpeed = 31.0;

  /// Meters to reach full difficulty.
  static const double difficultyDistance = 5000.0;

  /// Length of a full day/night cycle in meters.
  static const double dayCycle = 3200.0;
}
