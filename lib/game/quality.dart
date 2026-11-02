/// Graphics presets. The renderer never allocates per frame, but the amount of
/// geometry and effects still matters a lot on old GPUs, so everything heavy
/// is scaled here.
class Quality {
  const Quality({
    required this.name,
    required this.segments,
    required this.sceneryStep,
    required this.glows,
    required this.particles,
    required this.rain,
    required this.clouds,
    required this.shadows,
    required this.mountainColumns,
    required this.atlasScale,
    required this.textures,
    required this.detail,
  });

  final String name;

  /// Road segments drawn (each is 2 m).
  final int segments;

  /// Roadside decoration on every Nth segment.
  final int sceneryStep;

  /// Additive light glows (tail lights, lamps, power-up halos).
  final bool glows;

  /// Max live particles per system.
  final int particles;

  /// Max rain streaks.
  final int rain;

  final bool clouds;

  /// Small blob shadows under pickups.
  final bool shadows;

  final int mountainColumns;

  /// Texture resolution multiplier of the sprite atlas.
  final double atlasScale;

  /// Moving grain texture on the asphalt and grass (one tiny tiled image).
  final bool textures;

  /// Extra eye candy: road wear profile, grass tufts, fireflies, lens flare,
  /// god rays, wet reflections.
  final bool detail;

  static const low = Quality(
    name: 'Düşük',
    segments: 95,
    sceneryStep: 4,
    glows: false,
    particles: 40,
    rain: 40,
    clouds: false,
    shadows: false,
    mountainColumns: 32,
    atlasScale: 0.5,
    textures: false,
    detail: false,
  );

  static const medium = Quality(
    name: 'Orta',
    segments: 140,
    sceneryStep: 3,
    glows: true,
    particles: 90,
    rain: 80,
    clouds: true,
    shadows: false,
    mountainColumns: 48,
    atlasScale: 0.7,
    textures: true,
    detail: true,
  );

  static const high = Quality(
    name: 'Yüksek',
    segments: 200,
    sceneryStep: 2,
    glows: true,
    particles: 150,
    rain: 140,
    clouds: true,
    shadows: true,
    mountainColumns: 72,
    atlasScale: 0.9,
    textures: true,
    detail: true,
  );

  static const List<Quality> levels = [low, medium, high];
}
