/// Perspective camera. Looks down +z, pitched down by [pitch] radians.
library;

import 'dart:math' as math;

class Camera {
  double x = 0;
  double y = 2.6;
  double z = -4;

  /// Positive = looking down.
  double pitch = 0.18;

  /// Screen-space roll (radians) applied by the painter for lean / shake.
  double roll = 0;

  /// Vertical field of view in radians.
  double fovY = 62 * math.pi / 180;

  double near = 0.35;
  double far = 260;

  double width = 1;
  double height = 1;
  double cx = 0.5;
  double cy = 0.5;
  double focal = 1;

  /// Where the optical centre sits vertically (0..1 of screen height).
  double horizonBias = 0.5;

  void setViewport(double w, double h) {
    width = w;
    height = h;
    cx = w / 2;
    cy = h * horizonBias;
    // Use the larger dimension so tablets and phones get a similar framing.
    final ref = math.max(h, w * 1.6);
    focal = (ref / 2) / math.tan(fovY / 2);
  }

  /// Screen y of the horizon line (infinitely far ground point).
  double get horizonY => cy - focal * math.tan(pitch);

  /// Half-width of the view at depth 1 (for frustum culling).
  double get tanHalfX => (width / 2) / focal;
  double get tanHalfY => (height / 2) / focal;
}
