/// Procedural modelling toolkit: builds [Mesh]es from primitives
/// (boxes, cylinders, cones, spheres, tori, extrusions) with a transform stack.
///
/// Every closed primitive automatically orients its faces outward (checked
/// against the primitive centre), so back-face culling is always correct.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../math/mat3.dart';
import '../math/vec3.dart';
import 'mesh.dart';

class _Xf {
  _Xf(this.rot, this.offset, this.scale);
  final Mat3 rot;
  final Vec3 offset;
  final Vec3 scale;

  Vec3 apply(Vec3 v) =>
      rot.transform(Vec3(v.x * scale.x, v.y * scale.y, v.z * scale.z)) + offset;
}

class MeshBuilder {
  final List<double> _pos = [];
  final List<double> _nrm = [];
  final List<int> _col = [];
  final List<int> _flg = [];
  final List<_Xf> _stack = [];

  int get triangleCount => _col.length;

  // ---------------------------------------------------------------- stack --
  /// Applies a translate/rotate/scale to all primitives added inside [body].
  void withTransform({
    Vec3 translate = Vec3.zero,
    double yaw = 0,
    double pitch = 0,
    double roll = 0,
    Vec3 scale = const Vec3(1, 1, 1),
    required void Function() body,
  }) {
    _stack.add(_Xf(Mat3.rotation(yaw: yaw, pitch: pitch, roll: roll), translate, scale));
    body();
    _stack.removeLast();
  }

  Vec3 _apply(Vec3 v) {
    var p = v;
    for (var i = _stack.length - 1; i >= 0; i--) {
      p = _stack[i].apply(p);
    }
    return p;
  }

  // ------------------------------------------------------------ triangles --
  /// Adds a triangle; [outwardHint] (in local space) flips winding so the
  /// normal points away from it.
  void triangle(Vec3 a, Vec3 b, Vec3 c, Color color,
      {Vec3? outwardHint, int flags = 0}) {
    var wa = _apply(a), wb = _apply(b), wc = _apply(c);
    var n = (wb - wa).cross(wc - wa);
    if (n.length < 1e-12) return; // degenerate
    if (outwardHint != null) {
      final h = _apply(outwardHint);
      final centre = (wa + wb + wc) * (1 / 3);
      if (n.dot(centre - h) < 0) {
        final t = wb;
        wb = wc;
        wc = t;
        n = -n;
      }
    }
    n = n.normalized();
    _pos..addAll([wa.x, wa.y, wa.z])..addAll([wb.x, wb.y, wb.z])..addAll([wc.x, wc.y, wc.z]);
    _nrm.addAll([n.x, n.y, n.z]);
    _col.add(color.toARGB32());
    _flg.add(flags);
  }

  void quad(Vec3 a, Vec3 b, Vec3 c, Vec3 d, Color color,
      {Vec3? outwardHint, int flags = 0}) {
    triangle(a, b, c, color, outwardHint: outwardHint, flags: flags);
    triangle(a, c, d, color, outwardHint: outwardHint, flags: flags);
  }

  // ----------------------------------------------------------- primitives --
  /// Axis-aligned box centred at [c] with full size [s] (then transformed).
  /// [topColor] optionally colours the +y face differently.
  void box(Vec3 c, Vec3 s, Color color, {Color? topColor, Color? sideColor, int flags = 0}) {
    final hx = s.x / 2, hy = s.y / 2, hz = s.z / 2;
    Vec3 p(double x, double y, double z) => Vec3(c.x + x * hx, c.y + y * hy, c.z + z * hz);
    final side = sideColor ?? color;
    // +y / -y
    quad(p(-1, 1, -1), p(1, 1, -1), p(1, 1, 1), p(-1, 1, 1), topColor ?? color, outwardHint: c, flags: flags);
    quad(p(-1, -1, -1), p(1, -1, -1), p(1, -1, 1), p(-1, -1, 1), color, outwardHint: c, flags: flags);
    // +x / -x
    quad(p(1, -1, -1), p(1, 1, -1), p(1, 1, 1), p(1, -1, 1), side, outwardHint: c, flags: flags);
    quad(p(-1, -1, -1), p(-1, 1, -1), p(-1, 1, 1), p(-1, -1, 1), side, outwardHint: c, flags: flags);
    // +z / -z
    quad(p(-1, -1, 1), p(1, -1, 1), p(1, 1, 1), p(-1, 1, 1), color, outwardHint: c, flags: flags);
    quad(p(-1, -1, -1), p(1, -1, -1), p(1, 1, -1), p(-1, 1, -1), color, outwardHint: c, flags: flags);
  }

  /// Cylinder (prism) from [a] to [b]. Radii may differ (frustum / cone).
  void cylinder(Vec3 a, Vec3 b, double radiusA, Color color,
      {double? radiusB, int segments = 8, bool caps = true, Color? capColor, int flags = 0}) {
    final rb = radiusB ?? radiusA;
    final axis = (b - a);
    if (axis.length < 1e-9) return;
    final dir = axis.normalized();
    final u = dir.anyPerpendicular();
    final v = dir.cross(u).normalized();
    final mid = (a + b) * 0.5;
    Vec3 ring(Vec3 centre, double r, int i) {
      final ang = i / segments * math.pi * 2;
      return centre + u * (math.cos(ang) * r) + v * (math.sin(ang) * r);
    }

    for (var i = 0; i < segments; i++) {
      final a0 = ring(a, radiusA, i), a1 = ring(a, radiusA, i + 1);
      final b0 = ring(b, rb, i), b1 = ring(b, rb, i + 1);
      // outward hint: point on the axis at this segment's height
      if (rb > 1e-6) {
        quad(a0, a1, b1, b0, color, outwardHint: mid, flags: flags);
      } else {
        triangle(a0, a1, b, color, outwardHint: mid, flags: flags);
      }
      if (caps) {
        triangle(a, a0, a1, capColor ?? color, outwardHint: b, flags: flags);
        if (rb > 1e-6) triangle(b, b0, b1, capColor ?? color, outwardHint: a, flags: flags);
      }
    }
  }

  void cone(Vec3 base, Vec3 tip, double radius, Color color, {int segments = 8, int flags = 0}) =>
      cylinder(base, tip, radius, color, radiusB: 0, segments: segments, flags: flags);

  /// Low-poly UV sphere. [squash] scales y (ellipsoids for bushes, heads).
  void sphere(Vec3 c, double r, Color color,
      {int rings = 5, int segments = 8, Vec3 scale = const Vec3(1, 1, 1), Color? bottomColor, int flags = 0}) {
    Vec3 pt(int ring, int seg) {
      final phi = ring / rings * math.pi; // 0..pi
      final th = seg / segments * math.pi * 2;
      return Vec3(
        c.x + r * scale.x * math.sin(phi) * math.cos(th),
        c.y + r * scale.y * math.cos(phi),
        c.z + r * scale.z * math.sin(phi) * math.sin(th),
      );
    }

    for (var i = 0; i < rings; i++) {
      final col = (bottomColor != null && i >= rings / 2)
          ? Color.lerp(color, bottomColor, (i - rings / 2 + 1) / (rings / 2))!
          : color;
      for (var j = 0; j < segments; j++) {
        final p00 = pt(i, j), p01 = pt(i, j + 1), p10 = pt(i + 1, j), p11 = pt(i + 1, j + 1);
        if (i == 0) {
          triangle(p00, p11, p10, col, outwardHint: c, flags: flags);
        } else if (i == rings - 1) {
          triangle(p00, p01, p10, col, outwardHint: c, flags: flags);
        } else {
          quad(p00, p01, p11, p10, col, outwardHint: c, flags: flags);
        }
      }
    }
  }

  /// Torus lying in the plane perpendicular to [axis] (wheels, tyres, rings).
  void torus(Vec3 c, Vec3 axis, double ringRadius, double tubeRadius, Color color,
      {int segments = 16, int tubeSegments = 5, int flags = 0}) {
    final dir = axis.normalized();
    final u = dir.anyPerpendicular();
    final v = dir.cross(u).normalized();
    Vec3 ringCentre(int i) {
      final a = i / segments * math.pi * 2;
      return c + u * (math.cos(a) * ringRadius) + v * (math.sin(a) * ringRadius);
    }

    Vec3 pt(int i, int j) {
      final a = i / segments * math.pi * 2;
      final radial = u * math.cos(a) + v * math.sin(a);
      final b = j / tubeSegments * math.pi * 2;
      return ringCentre(i) + radial * (math.cos(b) * tubeRadius) + dir * (math.sin(b) * tubeRadius);
    }

    for (var i = 0; i < segments; i++) {
      final hint = ringCentre(i).lerp(ringCentre(i + 1), 0.5);
      for (var j = 0; j < tubeSegments; j++) {
        quad(pt(i, j), pt(i + 1, j), pt(i + 1, j + 1), pt(i, j + 1), color,
            outwardHint: hint, flags: flags);
      }
    }
  }

  /// Thin tube between two points (frame tubes, spokes, cables).
  void tube(Vec3 a, Vec3 b, double radius, Color color, {int segments = 5, int flags = 0}) =>
      cylinder(a, b, radius, color, segments: segments, caps: false, flags: flags);

  /// Flat double-sided polygon (fan) — signs, leaves, decals.
  void polygon(List<Vec3> pts, Color color, {int flags = MeshFlags.doubleSided}) {
    for (var i = 1; i < pts.length - 1; i++) {
      triangle(pts[0], pts[i], pts[i + 1], color, flags: flags);
    }
  }

  /// Extrudes a 2D outline (x,y in [outline]) along z by [depth], centred.
  void extrude(List<Offset> outline, double depth, Color color, {Color? sideColor, int flags = 0}) {
    final hz = depth / 2;
    var cx = 0.0, cy = 0.0;
    for (final o in outline) {
      cx += o.dx;
      cy += o.dy;
    }
    final centre = Vec3(cx / outline.length, cy / outline.length, 0);
    for (var i = 1; i < outline.length - 1; i++) {
      final a = outline[0], b = outline[i], c = outline[i + 1];
      triangle(Vec3(a.dx, a.dy, hz), Vec3(b.dx, b.dy, hz), Vec3(c.dx, c.dy, hz), color,
          outwardHint: centre, flags: flags);
      triangle(Vec3(a.dx, a.dy, -hz), Vec3(b.dx, b.dy, -hz), Vec3(c.dx, c.dy, -hz), color,
          outwardHint: centre, flags: flags);
    }
    for (var i = 0; i < outline.length; i++) {
      final a = outline[i], b = outline[(i + 1) % outline.length];
      quad(Vec3(a.dx, a.dy, -hz), Vec3(b.dx, b.dy, -hz), Vec3(b.dx, b.dy, hz),
          Vec3(a.dx, a.dy, hz), sideColor ?? color, outwardHint: centre, flags: flags);
    }
  }

  /// Appends another builder's triangles (already in world space of that builder).
  void merge(MeshBuilder other) {
    _pos.addAll(other._pos);
    _nrm.addAll(other._nrm);
    _col.addAll(other._col);
    _flg.addAll(other._flg);
  }

  Mesh build() {
    var r2 = 0.0;
    for (var i = 0; i < _pos.length; i += 3) {
      final d = _pos[i] * _pos[i] + _pos[i + 1] * _pos[i + 1] + _pos[i + 2] * _pos[i + 2];
      if (d > r2) r2 = d;
    }
    return Mesh(
      positions: Float32List.fromList(_pos),
      normals: Float32List.fromList(_nrm),
      colors: Int32List.fromList(_col),
      flags: Uint8List.fromList(_flg),
      radius: math.sqrt(r2),
    );
  }
}
