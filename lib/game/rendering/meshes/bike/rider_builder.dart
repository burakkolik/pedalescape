/// Builds the rider (helmet, face, jersey, courier bag, arms, legs with
/// 2-bone IK onto the pedals) into a [MeshBuilder].
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../../../engine/math/vec3.dart';
import '../../../../engine/mesh/mesh.dart';
import '../../../../engine/mesh/mesh_builder.dart';
import 'bike_geometry.dart';

class RiderColors {
  const RiderColors({
    this.jersey = const Color(0xFFFF7A1A),
    this.jerseyAccent = const Color(0xFF2A1B5E),
    this.shorts = const Color(0xFF1E1E2E),
    this.skin = const Color(0xFFE0AC69),
    this.helmet = const Color(0xFFFFD23F),
    this.visor = const Color(0xFF1B2A49),
    this.shoes = const Color(0xFFF5F6FA),
    this.bag = const Color(0xFF16C2B0),
  });

  final Color jersey, jerseyAccent, shorts, skin, helmet, visor, shoes, bag;
}

abstract final class RiderBuilder {
  /// [crank] = crank angle in radians, [duck] = 0 (upright) .. 1 (tucked).
  static void build(MeshBuilder b, BikeGeometry g, double crank, double duck,
      {RiderColors colors = const RiderColors()}) {
    final hip = g.saddle + Vec3(0, 0.09 - duck * 0.03, -0.02 + duck * 0.04);
    final lean = (g.riderLean + duck * 0.9).clamp(0.0, 1.25);
    final torsoLen = 0.56;
    // torso angle from vertical
    final ang = 0.35 + lean * 0.75;
    final shoulder = hip + Vec3(0, math.cos(ang) * torsoLen, math.sin(ang) * torsoLen);

    // ---- legs (IK) -----------------------------------------------------
    for (final side in [-1.0, 1.0]) {
      final a = crank + (side > 0 ? 0 : math.pi);
      final pedal = g.bottomBracket +
          Vec3(side * 0.13, -math.cos(a) * g.crankLength, math.sin(a) * g.crankLength);
      final h = hip + Vec3(side * 0.1, 0, 0);
      final knee = _knee(h, pedal, 0.44, 0.45);
      b.cylinder(h, knee, 0.075, colors.shorts, radiusB: 0.058, segments: 6);
      b.cylinder(knee, pedal + const Vec3(0, 0.05, -0.02), 0.052, colors.skin,
          radiusB: 0.04, segments: 6);
      b.sphere(knee, 0.06, colors.skin, rings: 3, segments: 5);
      // shoe
      b.box(pedal + const Vec3(0, 0.035, 0.03), const Vec3(0.085, 0.07, 0.22), colors.shoes,
          topColor: colors.jerseyAccent);
    }

    // ---- torso ----------------------------------------------------------
    b.cylinder(hip, shoulder, 0.16, colors.jersey, radiusB: 0.19, segments: 8,
        capColor: colors.jerseyAccent);
    // jersey side stripes
    b.tube(hip + const Vec3(0.165, 0.02, 0), shoulder + const Vec3(0.19, -0.03, 0), 0.02,
        colors.jerseyAccent, segments: 4);
    b.tube(hip + const Vec3(-0.165, 0.02, 0), shoulder + const Vec3(-0.19, -0.03, 0), 0.02,
        colors.jerseyAccent, segments: 4);
    // courier bag on the back
    final back = hip.lerp(shoulder, 0.55) + Vec3(0, math.sin(ang) * 0.17, -math.cos(ang) * 0.17);
    b.withTransform(
      translate: back,
      pitch: ang,
      body: () {
        b.box(Vec3.zero, const Vec3(0.34, 0.36, 0.14), colors.bag, topColor: colors.bag);
        b.box(const Vec3(0, 0.08, -0.075), const Vec3(0.3, 0.12, 0.02), colors.jerseyAccent);
        b.box(const Vec3(0, -0.05, -0.078), const Vec3(0.06, 0.06, 0.01), const Color(0xFFFFD23F),
            flags: MeshFlags.emissive);
      },
    );

    // ---- arms -------------------------------------------------------------
    for (final side in [-1.0, 1.0]) {
      final sh = shoulder + Vec3(side * 0.2, -0.03, 0);
      final grip = g.grips + Vec3(side * (g.gripHalfWidth - 0.03), 0.02, 0);
      final elbow = sh.lerp(grip, 0.5) + Vec3(side * 0.07, 0.04 - duck * 0.05, -0.02);
      b.sphere(sh, 0.085, colors.jersey, rings: 3, segments: 6);
      b.cylinder(sh, elbow, 0.06, colors.jersey, radiusB: 0.05, segments: 6);
      b.cylinder(elbow, grip, 0.045, colors.skin, radiusB: 0.038, segments: 5);
      b.sphere(grip, 0.05, colors.jerseyAccent, rings: 3, segments: 5); // gloves
    }

    // ---- head & helmet ------------------------------------------------------
    final neck = shoulder + Vec3(0, 0.07, 0.05);
    final head = neck + Vec3(0, 0.13 - duck * 0.03, 0.06 + lean * 0.04);
    b.cylinder(shoulder, neck, 0.06, colors.skin, segments: 6, caps: false);
    b.sphere(head, 0.12, colors.skin, rings: 4, segments: 8);
    b.sphere(head + const Vec3(0, 0.045, -0.01), 0.145, colors.helmet,
        rings: 4, segments: 10, scale: const Vec3(1, 0.78, 1.18), bottomColor: colors.helmet);
    // helmet vents / stripe
    b.box(head + const Vec3(0, 0.155, -0.01), const Vec3(0.05, 0.02, 0.26), colors.jerseyAccent);
    // visor / sunglasses
    b.box(head + const Vec3(0, 0.01, 0.105), const Vec3(0.2, 0.05, 0.03), colors.visor,
        flags: MeshFlags.emissive);
  }

  static Vec3 _knee(Vec3 hip, Vec3 foot, double a, double c) {
    final d = foot - hip;
    var len = d.length;
    final maxL = (a + c) * 0.995;
    if (len > maxL) len = maxL;
    final u = d.normalized();
    final cosA = ((a * a + len * len - c * c) / (2 * a * len)).clamp(-1.0, 1.0);
    final sinA = math.sqrt(1 - cosA * cosA);
    // knee bends forward (+z) in the y-z plane
    var n = Vec3(0, -u.z, u.y);
    if (n.z < 0) n = -n;
    return hip + u * (a * cosA) + n * (a * sinA);
  }
}
