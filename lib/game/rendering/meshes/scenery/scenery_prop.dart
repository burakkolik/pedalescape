/// One placeable roadside scenery model plus its spawn rules.
///
/// Meshes sit on y = 0 with the origin at their footprint centre and are
/// modelled with their "front" facing −z (toward the approaching camera);
/// they read well from both ±x sides, so placers may mirror or yaw them.
library;

import '../../../../engine/mesh/mesh.dart';

class SceneryProp {
  const SceneryProp({
    required this.mesh,
    this.weight = 1.0,
    this.minOffset = 1.0,
    this.maxOffset = 12.0,
    this.large = false,
    this.bothSides = true,
  });

  final Mesh mesh;

  /// Relative spawn probability within its world.
  final double weight;

  /// Distance range (meters) from the road edge outward to the prop centre.
  final double minOffset;
  final double maxOffset;

  /// Big landmark (windmill, lighthouse, skyscraper) — placed far and rarely.
  final bool large;

  /// May appear on both sides; false = left side only (e.g. worlds with the
  /// sea on the right).
  final bool bothSides;
}
