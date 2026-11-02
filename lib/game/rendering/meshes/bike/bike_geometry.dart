/// Key points of a bike frame (side profile) derived from its [BikeStyle].
/// Shared by the bike body builder, the wheel builder and the rider IK.
library;

import '../../../../engine/math/vec3.dart';
import '../../../catalog/bikes/bike_style.dart';

class BikeGeometry {
  BikeGeometry(this.style) {
    final r = style.wheelRadius;
    final isBmx = style.frame == FrameType.bmx;
    wheelbase = isBmx ? 0.92 : (style.frame == FrameType.track ? 0.98 : 1.06);
    rearAxle = Vec3(0, r, -wheelbase / 2);
    frontAxle = Vec3(0, r, wheelbase / 2);
    bottomBracket = Vec3(0, isBmx ? 0.30 : 0.29 + (r - 0.34) * 0.4, -0.06);
    final seatH = isBmx ? 0.42 : 0.55;
    seatCluster = Vec3(0, bottomBracket.y + seatH, bottomBracket.z - 0.17);
    headTop = Vec3(0, isBmx ? 0.78 : 0.93, wheelbase / 2 - 0.17);
    headBottom = Vec3(0, isBmx ? 0.62 : 0.78, wheelbase / 2 - 0.11);
    saddle = seatCluster + Vec3(0, isBmx ? 0.05 : 0.14, -0.03);
    stemTop = headTop + const Vec3(0, 0.1, 0.06);
    grips = switch (style.handlebar) {
      HandlebarType.drop => stemTop + const Vec3(0, -0.12, 0.1),
      HandlebarType.bullhorn => stemTop + const Vec3(0, 0.02, 0.17),
      HandlebarType.cruiser => stemTop + const Vec3(0, 0.12, -0.1),
      HandlebarType.bmx => stemTop + const Vec3(0, 0.22, -0.02),
      HandlebarType.riser => stemTop + const Vec3(0, 0.05, 0.0),
    };
    gripHalfWidth = switch (style.handlebar) {
      HandlebarType.riser => 0.33,
      HandlebarType.bmx => 0.3,
      HandlebarType.cruiser => 0.3,
      _ => 0.21,
    };
  }

  final BikeStyle style;
  late final double wheelbase;
  late final Vec3 rearAxle;
  late final Vec3 frontAxle;
  late final Vec3 bottomBracket;
  late final Vec3 seatCluster;
  late final Vec3 headTop;
  late final Vec3 headBottom;
  late final Vec3 saddle;
  late final Vec3 stemTop;
  late final Vec3 grips;
  late final double gripHalfWidth;

  double get crankLength => style.frame == FrameType.bmx ? 0.16 : 0.17;

  /// Leaning-forward factor of the rider (road/track bikes are more aero).
  double get riderLean => switch (style.handlebar) {
        HandlebarType.drop => 0.85,
        HandlebarType.bullhorn => 0.75,
        HandlebarType.cruiser => 0.15,
        HandlebarType.bmx => 0.35,
        HandlebarType.riser => 0.45,
      };
}
