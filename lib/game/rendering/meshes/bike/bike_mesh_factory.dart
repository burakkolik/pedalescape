/// Builds and caches the animated 3D model of every bike (see [BikeModel]).
///
/// The frame is assembled from tubes between the key points of
/// [BikeGeometry]; each [FrameType] / [HandlebarType] adds its own parts.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../../../engine/math/vec3.dart';
import '../../../../engine/mesh/mesh.dart';
import '../../../../engine/mesh/mesh_builder.dart';
import '../../../../engine/render/color_utils.dart';
import '../../../catalog/bikes/bike_loadout.dart';
import '../../../catalog/bikes/bike_style.dart';
import 'bike_geometry.dart';
import 'bike_model.dart';
import 'rider_builder.dart';

abstract final class BikeMeshFactory {
  static const int crankFrames = 12;
  static const int wheelFrames = 6;

  static final Map<String, BikeModel> _cache = {};

  static BikeModel modelFor(BikeLoadout loadout) {
    final key = '${loadout.bikeId}:${loadout.paintIndex}';
    return _cache.putIfAbsent(key, () => _build(loadout));
  }

  static BikeModel _build(BikeLoadout loadout) {
    final style = loadout.bike.style;
    final g = BikeGeometry(style);
    final frame = loadout.frameColor;
    final accent = loadout.accentColor;
    final riderColors = RiderColors(
      jersey: ColorUtils.shade(accent, 0.05),
      jerseyAccent: ColorUtils.shade(frame, -0.15),
    );
    List<Mesh> frames(double? duck) => List.generate(crankFrames, (i) {
          final crank = i / crankFrames * math.pi * 2;
          final b = MeshBuilder();
          _bodyImpl(b, g, style, frame, accent, crank);
          if (duck != null) RiderBuilder.build(b, g, crank, duck, colors: riderColors);
          return b.build();
        });

    final spokeCount = style.discWheels ? 3 : math.min(style.spokes, 16);
    final period = math.pi * 2 / spokeCount;
    List<Mesh> wheels(Vec3 axle) => List.generate(wheelFrames, (i) {
          final b = MeshBuilder();
          _wheel(b, style, axle, i / wheelFrames * period, spokeCount, accent);
          return b.build();
        });

    return BikeModel(
      rideFrames: frames(0),
      duckFrames: frames(1),
      bikeOnlyFrames: frames(null),
      frontWheelFrames: wheels(g.frontAxle),
      rearWheelFrames: wheels(g.rearAxle),
      wheelPeriod: period,
      wheelRadius: style.wheelRadius,
    );
  }

  // ------------------------------------------------------------------ wheel --
  static void _wheel(MeshBuilder b, BikeStyle s, Vec3 axle, double rot, int spokes, Color accent) {
    const axis = Vec3(1, 0, 0);
    final r = s.wheelRadius;
    final tireR = s.tireWidth / 2;
    const tire = Color(0xFF1C1C1F);
    final rimColor = s.glowColor ?? const Color(0xFFB8BEC8);
    final rimFlags = s.glowColor != null ? MeshFlags.emissive : 0;
    b.torus(axle, axis, r - tireR, tireR, tire, segments: 18, tubeSegments: 4);
    // tread blocks for fat tyres
    if (s.tireWidth > 0.09) {
      for (var i = 0; i < 18; i++) {
        final a = rot + i / 18 * math.pi * 2;
        final p = axle + Vec3(0, math.sin(a) * r, math.cos(a) * r);
        b.box(p, Vec3(s.tireWidth * 0.9, 0.025, 0.04), const Color(0xFF26262A));
      }
    }
    b.torus(axle, axis, r - s.tireWidth - s.rimDepth / 2, s.rimDepth / 2 + 0.006, rimColor,
        segments: 18, tubeSegments: 3, flags: rimFlags);
    // hub
    b.cylinder(axle + const Vec3(-0.06, 0, 0), axle + const Vec3(0.06, 0, 0), 0.03,
        const Color(0xFF9AA0A8), segments: 8);
    final inner = r - s.tireWidth - s.rimDepth;
    if (s.discWheels) {
      for (final side in [-0.012, 0.012]) {
        final pts = <Vec3>[];
        for (var i = 0; i < 16; i++) {
          final a = i / 16 * math.pi * 2;
          pts.add(axle + Vec3(side, math.sin(a) * inner, math.cos(a) * inner));
        }
        b.polygon(pts, const Color(0xFF2B2E36));
        // three accent wedges (make rotation visible)
        for (var k = 0; k < 3; k++) {
          final a0 = rot + k * math.pi * 2 / 3, a1 = a0 + 0.35;
          b.polygon([
            axle + Vec3(side * 1.1, 0, 0),
            axle + Vec3(side * 1.1, math.sin(a0) * inner * 0.95, math.cos(a0) * inner * 0.95),
            axle + Vec3(side * 1.1, math.sin(a1) * inner * 0.95, math.cos(a1) * inner * 0.95),
          ], accent, flags: MeshFlags.doubleSided | (s.glowColor != null ? MeshFlags.emissive : 0));
        }
      }
    } else {
      for (var i = 0; i < spokes; i++) {
        final a = rot + i / spokes * math.pi * 2;
        final side = i.isEven ? 0.04 : -0.04;
        b.tube(axle + Vec3(side, 0, 0), axle + Vec3(0, math.sin(a) * inner, math.cos(a) * inner),
            0.005, const Color(0xFFD5D9E0), segments: 3);
      }
    }
  }

  // ------------------------------------------------------------------- body --
  static void _bodyImpl(MeshBuilder b, BikeGeometry g, BikeStyle s, Color frame, Color accent,
      double crank) {
    final tubeR = switch (s.frame) {
      FrameType.futuristic => 0.042,
      FrameType.fullSuspension => 0.038,
      FrameType.bmx => 0.03,
      _ => 0.027,
    };
    final dark = ColorUtils.shade(frame, -0.35);
    final glowFlags = s.glowColor != null ? MeshFlags.emissive : 0;
    void tube(Vec3 a, Vec3 c, [double? r, Color? col]) =>
        b.cylinder(a, c, r ?? tubeR, col ?? frame, segments: 6, caps: true);

    final bb = g.bottomBracket, sc = g.seatCluster, ht = g.headTop, hb = g.headBottom;
    final ra = g.rearAxle, fa = g.frontAxle;

    // ---- main triangle --------------------------------------------------
    switch (s.frame) {
      case FrameType.stepThrough:
        final mid = Vec3(0, bb.y + 0.12, bb.z + 0.28);
        tube(bb, mid, tubeR * 1.2);
        tube(mid, hb, tubeR * 1.2);
        tube(bb, sc);
      case FrameType.futuristic:
        // thick aero beam with glowing accent line
        tube(sc + const Vec3(0, -0.05, 0), ht, tubeR * 1.2);
        tube(bb, hb, tubeR * 1.3);
        tube(bb, sc, tubeR);
        b.tube(sc + const Vec3(0.045, -0.02, 0), ht + const Vec3(0.045, 0, 0), 0.008,
            s.glowColor ?? accent, segments: 3, flags: MeshFlags.emissive);
        b.tube(sc + const Vec3(-0.045, -0.02, 0), ht + const Vec3(-0.045, 0, 0), 0.008,
            s.glowColor ?? accent, segments: 3, flags: MeshFlags.emissive);
      default:
        tube(sc, ht);
        tube(bb, hb, tubeR * 1.15);
        tube(bb, sc);
    }
    // head tube
    tube(hb, ht + const Vec3(0, 0.03, 0), tubeR * 1.3, accent);

    // ---- rear triangle ----------------------------------------------------
    for (final side in [-0.055, 0.055]) {
      final rs = ra + Vec3(side, 0, 0);
      tube(bb + Vec3(side * 0.5, 0, 0), rs, tubeR * 0.7);
      if (s.frame == FrameType.fullSuspension) {
        tube(rs, sc.lerp(bb, 0.45) + Vec3(side * 0.6, 0, 0), tubeR * 0.7);
      } else {
        tube(sc + Vec3(side * 0.4, -0.02, 0), rs, tubeR * 0.6);
      }
    }
    if (s.hasRearShock || s.frame == FrameType.fullSuspension) {
      final s0 = sc.lerp(bb, 0.45), s1 = sc.lerp(ht, 0.35);
      b.cylinder(s0, s1, 0.03, const Color(0xFF30333A), segments: 6);
      b.cylinder(s0.lerp(s1, 0.2), s0.lerp(s1, 0.8), 0.045, accent, segments: 6);
    }

    // ---- fork --------------------------------------------------------------
    for (final side in [-0.05, 0.05]) {
      final top = hb + Vec3(side, 0, 0), bottom = fa + Vec3(side, 0, 0);
      if (s.hasSuspensionFork) {
        final mid = top.lerp(bottom, 0.45);
        b.cylinder(top, mid, 0.03, const Color(0xFF2E3138), segments: 6);
        b.cylinder(mid, bottom, 0.022, const Color(0xFFC9CED6), segments: 6);
      } else {
        tube(top, bottom, tubeR * 0.75);
      }
    }
    b.box(hb + const Vec3(0, 0, 0), Vec3(0.14, 0.04, 0.06), accent); // crown

    // ---- seat post & saddle ---------------------------------------------------
    b.cylinder(sc, g.saddle + const Vec3(0, -0.02, 0), 0.016, const Color(0xFF8C939D), segments: 5);
    b.withTransform(
      translate: g.saddle,
      body: () {
        b.box(const Vec3(0, 0.025, -0.02), const Vec3(0.15, 0.045, 0.2), const Color(0xFF25252B),
            topColor: const Color(0xFF34343C));
        b.box(const Vec3(0, 0.028, 0.08), const Vec3(0.06, 0.04, 0.12), const Color(0xFF25252B));
        b.box(const Vec3(0, 0.05, -0.02), const Vec3(0.02, 0.005, 0.18), accent);
      },
    );

    // ---- stem & handlebar -------------------------------------------------------
    tube(ht + const Vec3(0, 0.03, 0), g.stemTop, 0.02, const Color(0xFF3A3D44));
    final gw = g.gripHalfWidth;
    final bar = const Color(0xFF2A2C31);
    switch (s.handlebar) {
      case HandlebarType.drop:
        final c = g.stemTop;
        for (final side in [-1.0, 1.0]) {
          final p0 = c + Vec3(side * gw, 0, 0);
          final p1 = p0 + const Vec3(0, -0.02, 0.09);
          final p2 = p1 + const Vec3(0, -0.12, 0.0);
          final p3 = p2 + const Vec3(0, -0.02, -0.08);
          b.tube(c, p0, 0.014, bar);
          b.tube(p0, p1, 0.014, bar);
          b.tube(p1, p2, 0.014, accent);
          b.tube(p2, p3, 0.014, accent);
          b.box(p0 + const Vec3(0, 0.02, 0.07), const Vec3(0.025, 0.05, 0.03), const Color(0xFF111111));
        }
      case HandlebarType.bullhorn:
        final c = g.stemTop;
        for (final side in [-1.0, 1.0]) {
          final p0 = c + Vec3(side * gw, 0, 0);
          b.tube(c, p0, 0.015, bar);
          b.tube(p0, p0 + const Vec3(0, 0.03, 0.17), 0.016, accent);
        }
      case HandlebarType.cruiser:
        final c = g.stemTop;
        for (final side in [-1.0, 1.0]) {
          final p0 = c + Vec3(side * 0.12, 0.06, 0.0);
          final p1 = c + Vec3(side * gw, 0.12, -0.1);
          b.tube(c, p0, 0.014, const Color(0xFFC9CED6));
          b.tube(p0, p1, 0.014, const Color(0xFFC9CED6));
          b.cylinder(p1, p1 + Vec3(side * 0.08, 0, -0.02), 0.022, const Color(0xFF6D4C41), segments: 6);
        }
        // bell
        b.cylinder(c + const Vec3(0.09, 0.06, 0), c + const Vec3(0.09, 0.1, 0), 0.03,
            const Color(0xFFE5C15A), segments: 8);
      case HandlebarType.bmx:
        final c = g.stemTop;
        final top = c + const Vec3(0, 0.22, -0.02);
        for (final side in [-1.0, 1.0]) {
          b.tube(c + Vec3(side * 0.1, 0, 0), top + Vec3(side * gw, 0, 0), 0.015, accent);
          b.cylinder(top + Vec3(side * (gw - 0.08), 0, 0), top + Vec3(side * (gw + 0.02), 0, 0),
              0.022, const Color(0xFF111111), segments: 6);
        }
        b.tube(top + Vec3(-gw, 0, 0), top + Vec3(gw, 0, 0), 0.015, accent);
        b.tube(c + const Vec3(-0.1, 0.1, 0), c + const Vec3(0.1, 0.1, 0), 0.012, accent);
      case HandlebarType.riser:
        final c = g.stemTop;
        for (final side in [-1.0, 1.0]) {
          final p0 = c + Vec3(side * 0.08, 0.0, 0);
          final p1 = c + Vec3(side * gw, 0.05, 0);
          b.tube(p0, p1, 0.016, bar);
          b.cylinder(p1 + Vec3(-side * 0.1, 0, 0), p1 + Vec3(side * 0.015, 0, 0), 0.022,
              const Color(0xFF111111), segments: 6);
          b.tube(p1 + Vec3(-side * 0.07, 0, 0), p1 + Vec3(-side * 0.03, -0.01, 0.08), 0.007,
              const Color(0xFF9AA0A8), segments: 3); // brake lever
        }
        b.tube(c + const Vec3(-0.08, 0, 0), c + const Vec3(0.08, 0, 0), 0.018, bar);
    }

    // ---- drivetrain --------------------------------------------------------------
    final chainX = 0.075;
    final ring = bb + Vec3(chainX, 0, 0);
    b.torus(ring, const Vec3(1, 0, 0), 0.095, 0.012, const Color(0xFFB0B6BF), segments: 14, tubeSegments: 3);
    b.cylinder(ring + const Vec3(-0.005, 0, 0), ring + const Vec3(0.005, 0, 0), 0.085,
        ColorUtils.shade(accent, -0.2), segments: 10);
    final cog = ra + Vec3(chainX, 0, 0);
    b.cylinder(cog + const Vec3(-0.01, 0, 0), cog + const Vec3(0.01, 0, 0), 0.045,
        const Color(0xFF9AA0A8), segments: 8);
    b.tube(ring + const Vec3(0, 0.1, 0), cog + const Vec3(0, 0.047, 0), 0.007, const Color(0xFF4A4E56), segments: 3);
    b.tube(ring + const Vec3(0, -0.1, 0), cog + const Vec3(0, -0.047, 0), 0.007, const Color(0xFF4A4E56), segments: 3);
    b.cylinder(bb + const Vec3(-0.07, 0, 0), bb + const Vec3(0.07, 0, 0), 0.03, dark, segments: 8);
    for (final side in [-1.0, 1.0]) {
      final a = crank + (side > 0 ? 0 : math.pi);
      final arm0 = bb + Vec3(side * 0.09, 0, 0);
      final pedal = bb + Vec3(side * 0.12, -math.cos(a) * g.crankLength, math.sin(a) * g.crankLength);
      b.tube(arm0, pedal, 0.014, const Color(0xFF3A3D44), segments: 4);
      b.box(pedal + Vec3(side * 0.04, 0, 0), const Vec3(0.09, 0.02, 0.1), const Color(0xFF26262A),
          topColor: const Color(0xFF55585F));
    }

    // ---- extras -------------------------------------------------------------------
    if (s.hasMotor) {
      // battery on the down tube + hub motor housing
      final mid = bb.lerp(hb, 0.45) + const Vec3(0, 0.05, -0.02);
      b.withTransform(
        translate: mid,
        pitch: -0.75,
        body: () {
          b.box(Vec3.zero, const Vec3(0.09, 0.32, 0.08), const Color(0xFF22252B), topColor: accent);
          b.box(const Vec3(0.047, 0.05, 0), const Vec3(0.006, 0.12, 0.03), s.glowColor ?? accent,
              flags: MeshFlags.emissive);
        },
      );
      b.cylinder(ra + const Vec3(-0.045, 0, 0), ra + const Vec3(0.045, 0, 0), 0.075,
          const Color(0xFF30333A), segments: 10);
    }
    if (s.hasBasket) {
      final c = fa + Vec3(0, s.wheelRadius + 0.2, -0.02);
      b.box(c, const Vec3(0.34, 0.2, 0.26), const Color(0xFF8D6E63), topColor: const Color(0xFF5D4037));
      b.box(c + const Vec3(0, 0.03, 0), const Vec3(0.36, 0.03, 0.28), const Color(0xFFA1887F));
      b.sphere(c + const Vec3(0.05, 0.12, 0), 0.07, const Color(0xFFE74C3C), rings: 3, segments: 6);
      b.cylinder(c + const Vec3(-0.07, 0.1, 0.03), c + const Vec3(-0.07, 0.25, 0.05), 0.03,
          const Color(0xFFF5DEB3), segments: 6); // baguette
    }
    if (s.hasFenders) {
      for (final axle in [fa, ra]) {
        final r = s.wheelRadius + 0.03;
        for (var i = 0; i < 6; i++) {
          final a0 = 0.35 + i * 0.36, a1 = a0 + 0.36;
          final dirZ = axle == fa ? 1.0 : -1.0;
          final p0 = axle + Vec3(0, math.sin(a0) * r, math.cos(a0) * r * dirZ * -1 + 0);
          final p1 = axle + Vec3(0, math.sin(a1) * r, math.cos(a1) * r * dirZ * -1 + 0);
          b.box(p0.lerp(p1, 0.5), Vec3(s.tireWidth + 0.03, 0.012, 0.13), accent);
        }
      }
    }
    // headlight & rear reflector (emissive)
    b.box(g.headTop + const Vec3(0, -0.04, 0.06), const Vec3(0.06, 0.05, 0.05), const Color(0xFFFFF6D5),
        flags: MeshFlags.emissive);
    b.box(g.seatCluster + const Vec3(0, -0.05, -0.08), const Vec3(0.05, 0.04, 0.02), const Color(0xFFFF2E4D),
        flags: MeshFlags.emissive);
    // decals on the down tube
    b.box(bb.lerp(hb, 0.55) + const Vec3(0, 0, 0), Vec3(tubeR * 2.25, 0.025, 0.12), accent,
        flags: glowFlags);
    // water bottle
    if (s.frame == FrameType.diamond || s.frame == FrameType.track) {
      final p = bb.lerp(sc, 0.4) + const Vec3(0, 0, 0.06);
      b.cylinder(p, p + const Vec3(0, 0.17, 0.03), 0.032, accent, segments: 7);
    }
  }
}
