/// Pre-baked animated bike + rider: body keyframes (per crank angle and pose)
/// and wheel spin keyframes. All meshes share the same origin (ground contact
/// point under the bottom bracket), so the same transform is used for all.
library;

import 'dart:math' as math;

import '../../../../engine/mesh/mesh.dart';

enum RiderPose { ride, duck, none }

class BikeModel {
  BikeModel({
    required this.rideFrames,
    required this.duckFrames,
    required this.bikeOnlyFrames,
    required this.frontWheelFrames,
    required this.rearWheelFrames,
    required this.wheelPeriod,
    required this.wheelRadius,
  });

  /// Bike + pedalling rider, index = crank angle / (2π) * length.
  final List<Mesh> rideFrames;
  final List<Mesh> duckFrames;

  /// Bike without rider (garage showcase).
  final List<Mesh> bikeOnlyFrames;
  final List<Mesh> frontWheelFrames;
  final List<Mesh> rearWheelFrames;

  /// Wheel rotation (radians) covered by the wheel keyframes.
  final double wheelPeriod;
  final double wheelRadius;

  Mesh body(RiderPose pose, double crankAngle) {
    final frames = switch (pose) {
      RiderPose.ride => rideFrames,
      RiderPose.duck => duckFrames,
      RiderPose.none => bikeOnlyFrames,
    };
    return frames[_index(crankAngle, 2 * math.pi, frames.length)];
  }

  Mesh frontWheel(double angle) =>
      frontWheelFrames[_index(angle, wheelPeriod, frontWheelFrames.length)];
  Mesh rearWheel(double angle) =>
      rearWheelFrames[_index(angle, wheelPeriod, rearWheelFrames.length)];

  static int _index(double angle, double period, int n) {
    final f = (angle % period) / period;
    return (f * n).floor().clamp(0, n - 1);
  }
}
