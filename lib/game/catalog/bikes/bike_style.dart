/// Visual archetype of a bike. The mesh factory
/// (`lib/game/rendering/meshes/bike_mesh_factory.dart`) reads these values to
/// build a unique 3D model for every bike.
library;

import 'dart:ui';

/// Handlebar shapes supported by the bike mesh factory.
enum HandlebarType { riser, drop, bullhorn, cruiser, bmx }

/// Frame silhouettes supported by the bike mesh factory.
enum FrameType { diamond, stepThrough, bmx, fullSuspension, track, futuristic }

/// Pure data describing how a bike looks.
class BikeStyle {
  const BikeStyle({
    required this.frame,
    required this.handlebar,
    required this.frameColor,
    required this.accentColor,
    this.wheelRadius = 0.34,
    this.tireWidth = 0.05,
    this.rimDepth = 0.03,
    this.spokes = 16,
    this.discWheels = false,
    this.hasMotor = false,
    this.hasSuspensionFork = false,
    this.hasRearShock = false,
    this.hasBasket = false,
    this.hasFenders = false,
    this.glowColor,
    this.trailColor,
  });

  final FrameType frame;
  final HandlebarType handlebar;
  final Color frameColor;
  final Color accentColor;

  /// Wheel radius in meters (BMX ~0.25, road ~0.34, fat ~0.38).
  final double wheelRadius;
  final double tireWidth;
  final double rimDepth;
  final int spokes;
  final bool discWheels;
  final bool hasMotor;
  final bool hasSuspensionFork;
  final bool hasRearShock;
  final bool hasBasket;
  final bool hasFenders;

  /// Optional emissive glow for premium bikes (rims, frame lines).
  final Color? glowColor;

  /// Optional particle trail color emitted while riding.
  final Color? trailColor;
}
