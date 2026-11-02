/// A runtime obstacle placed on the road (road-space coordinates).
library;

import '../../../engine/mesh/mesh.dart';
import '../../rendering/meshes/obstacles/obstacle_kind.dart';

class Obstacle {
  Obstacle({
    required this.kind,
    required this.lane,
    required this.z,
    required this.mesh,
    this.velocity = 0,
    this.yaw = 0,
  }) : x = laneX(lane);

  final ObstacleKind kind;
  final int lane; // -1, 0, 1
  double x;
  double z;
  final Mesh mesh;

  /// m/s along z (negative = oncoming).
  final double velocity;
  final double yaw;

  bool resolved = false; // passed / hit already
  bool smashed = false;
  double smashT = 0;

  static const double laneWidth = 2.2;
  static double laneX(int lane) => lane * laneWidth;

  /// Half length along z used for collisions.
  double get halfDepth => switch (kind) {
        ObstacleKind.hurdle => 0.3,
        ObstacleKind.lowBeam => 0.25,
        ObstacleKind.block => 0.8,
        ObstacleKind.vehicle => 2.1,
        ObstacleKind.ramp => 1.5,
      };
}
