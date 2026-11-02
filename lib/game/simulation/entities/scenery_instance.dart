/// A placed decorative prop beside the road.
library;

import '../../../engine/mesh/mesh.dart';

class SceneryInstance {
  SceneryInstance(this.mesh, this.x, this.z, this.yaw, this.scale);
  final Mesh mesh;
  final double x;
  final double z;
  final double yaw;
  final double scale;
}
