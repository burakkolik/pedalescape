/// Visual palette and terrain flavour of one world (biome).
///
/// Colors describe the DAY look; the lighting layer tints them for the time
/// of day. Progression data lives in `WorldCatalog`.
library;

import 'dart:ui';

/// Material look of the road surface (drives road texture details).
enum RoadSurface { asphalt, dirt, sand, snow, cobble, boardwalk, neon, stone }

/// Kind of distant silhouette drawn on the horizon.
enum Skyline {
  hills,
  forest,
  mesas,
  sea,
  city,
  peaks,
  jungle,
  blossomHills,
  harbor,
  ruins,
  volcano,
  scifi,
}

class BiomeTheme {
  const BiomeTheme({
    required this.index,
    required this.groundA,
    required this.groundB,
    required this.shoulder,
    required this.road,
    required this.roadDark,
    required this.laneMark,
    required this.edgeLine,
    required this.curb,
    required this.skyTop,
    required this.skyHorizon,
    required this.sunColor,
    required this.fogColor,
    required this.farSilhouette,
    required this.nearSilhouette,
    required this.surface,
    required this.skyline,
    this.sideWater = false,
    this.sceneryDensity = 1.0,
  });

  /// 0-based world index (matches `WorldCatalog`).
  final int index;

  /// Two alternating terrain stripe colors.
  final Color groundA;
  final Color groundB;

  /// Strip between the road edge and the terrain.
  final Color shoulder;

  /// Road base tone and the alternating darker segment tone.
  final Color road;
  final Color roadDark;

  /// Dashed lane separators.
  final Color laneMark;

  /// Solid lines along both road edges.
  final Color edgeLine;

  /// Curb / kerb blocks along the road.
  final Color curb;

  /// Sky gradient (zenith → horizon), sun disc and fog (DAY palette).
  final Color skyTop;
  final Color skyHorizon;
  final Color sunColor;
  final Color fogColor;

  /// Horizon silhouette layers (far is paler, near is stronger).
  final Color farSilhouette;
  final Color nearSilhouette;

  final RoadSurface surface;
  final Skyline skyline;

  /// True when the sea lies on the right side of the road.
  final bool sideWater;

  /// Scenery spawn multiplier (0.5 sparse … 1.5 dense).
  final double sceneryDensity;

  /// Night worlds (emissive-heavy look).
  bool get isNight => skyline == Skyline.city || skyline == Skyline.scifi;
}
