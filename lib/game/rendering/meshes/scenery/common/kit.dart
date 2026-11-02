/// Low-level modelling helpers shared by every prop/obstacle builder:
/// color variation, open boxes, gable roofs, panels (windows, decals),
/// jittered rock blobs, discs and convex prisms.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../../../../engine/mesh/mesh.dart';
import '../../../../../engine/mesh/mesh_builder.dart';
import '../../../../../engine/math/vec3.dart';

/// Lightens (+) or darkens (−) [c] by [amount] in −1..1.
Color shade(Color c, double amount) => amount >= 0
    ? Color.lerp(c, const Color(0xFFFFFFFF), amount)!
    : Color.lerp(c, const Color(0xFF000000), -amount)!;

/// Random brightness wobble of ±[amount] around [c].
Color vary(Color c, math.Random r, [double amount = 0.08]) =>
    shade(c, (r.nextDouble() * 2 - 1) * amount);

/// Picks a random element.
T pick<T>(math.Random r, List<T> items) => items[r.nextInt(items.length)];

/// Uniform random double in [a, b).
double range(math.Random r, double a, double b) => a + r.nextDouble() * (b - a);

/// Short alias for [Vec3].
Vec3 v3(double x, double y, double z) => Vec3(x, y, z);

/// Box resting on [y0] without the (never visible) bottom face: 10 tris.
void ground(MeshBuilder b, double cx, double y0, double cz, double sx, double sy, double sz,
    Color color, {Color? top, Color? side, int flags = 0}) {
  final c = Vec3(cx, y0 + sy / 2, cz);
  final hx = sx / 2, hy = sy / 2, hz = sz / 2;
  Vec3 p(double x, double y, double z) => Vec3(c.x + x * hx, c.y + y * hy, c.z + z * hz);
  final s = side ?? color;
  b.quad(p(-1, 1, -1), p(1, 1, -1), p(1, 1, 1), p(-1, 1, 1), top ?? color, outwardHint: c, flags: flags);
  b.quad(p(1, -1, -1), p(1, 1, -1), p(1, 1, 1), p(1, -1, 1), s, outwardHint: c, flags: flags);
  b.quad(p(-1, -1, -1), p(-1, 1, -1), p(-1, 1, 1), p(-1, -1, 1), s, outwardHint: c, flags: flags);
  b.quad(p(-1, -1, 1), p(1, -1, 1), p(1, 1, 1), p(-1, 1, 1), color, outwardHint: c, flags: flags);
  b.quad(p(-1, -1, -1), p(1, -1, -1), p(1, 1, -1), p(-1, 1, -1), color, outwardHint: c, flags: flags);
}

/// Gable roof (triangular prism) over the rectangle [sx]×[sz] at height
/// [y0]; ridge runs along z when [ridgeAlongZ], else along x. [overhang]
/// extends eaves. Gable ends get [gableColor] (defaults to [color]).
void gableRoof(MeshBuilder b, double cx, double y0, double cz, double sx, double sz,
    double height, Color color,
    {bool ridgeAlongZ = true, double overhang = 0.15, Color? gableColor, int flags = 0}) {
  final hint = Vec3(cx, y0 + height * 0.3, cz);
  if (ridgeAlongZ) {
    final hx = sx / 2 + overhang, hz = sz / 2 + overhang;
    final l0 = Vec3(cx - hx, y0, cz - hz), l1 = Vec3(cx - hx, y0, cz + hz);
    final r0 = Vec3(cx + hx, y0, cz - hz), r1 = Vec3(cx + hx, y0, cz + hz);
    final t0 = Vec3(cx, y0 + height, cz - hz), t1 = Vec3(cx, y0 + height, cz + hz);
    b.quad(l0, l1, t1, t0, color, outwardHint: hint, flags: flags);
    b.quad(r0, r1, t1, t0, shade(color, -0.06), outwardHint: hint, flags: flags);
    b.triangle(l0, r0, t0, gableColor ?? color, outwardHint: hint, flags: flags);
    b.triangle(l1, r1, t1, gableColor ?? color, outwardHint: hint, flags: flags);
    b.quad(l0, r0, r1, l1, shade(color, -0.3), outwardHint: Vec3(cx, y0 + 1, cz), flags: flags);
  } else {
    final hx = sx / 2 + overhang, hz = sz / 2 + overhang;
    final f0 = Vec3(cx - hx, y0, cz - hz), f1 = Vec3(cx + hx, y0, cz - hz);
    final k0 = Vec3(cx - hx, y0, cz + hz), k1 = Vec3(cx + hx, y0, cz + hz);
    final t0 = Vec3(cx - hx, y0 + height, cz), t1 = Vec3(cx + hx, y0 + height, cz);
    b.quad(f0, f1, t1, t0, color, outwardHint: hint, flags: flags);
    b.quad(k0, k1, t1, t0, shade(color, -0.06), outwardHint: hint, flags: flags);
    b.triangle(f0, k0, t0, gableColor ?? color, outwardHint: hint, flags: flags);
    b.triangle(f1, k1, t1, gableColor ?? color, outwardHint: hint, flags: flags);
    b.quad(f0, f1, k1, k0, shade(color, -0.3), outwardHint: Vec3(cx, y0 + 1, cz), flags: flags);
  }
}

/// Four-sided pyramid roof (hip) — used for towers, huts, pagodas.
void pyramidRoof(MeshBuilder b, double cx, double y0, double cz, double sx, double sz,
    double height, Color color, {int flags = 0}) {
  final hx = sx / 2, hz = sz / 2;
  final tip = Vec3(cx, y0 + height, cz);
  final hint = Vec3(cx, y0 + height * 0.3, cz);
  final c = [
    Vec3(cx - hx, y0, cz - hz),
    Vec3(cx + hx, y0, cz - hz),
    Vec3(cx + hx, y0, cz + hz),
    Vec3(cx - hx, y0, cz + hz),
  ];
  for (var i = 0; i < 4; i++) {
    b.triangle(c[i], c[(i + 1) % 4], tip, i.isEven ? color : shade(color, -0.07),
        outwardHint: hint, flags: flags);
  }
  b.quad(c[0], c[1], c[2], c[3], shade(color, -0.3), outwardHint: Vec3(cx, y0 + 1, cz), flags: flags);
}

/// Which axis-aligned face a [tiledFace] lies on: front = −z (toward the
/// camera), back = +z, left = −x, right = +x.
enum Face { front, back, left, right }

/// Rectangular cell drawn inside a [tiledFace] (window, door, stripe…).
/// A null [color] leaves a hole (e.g. a wheel arch).
class Hole {
  const Hole(this.u0, this.u1, this.y0, this.y1, this.color, {this.flags = 0});
  final double u0, u1, y0, y1;
  final Color? color;
  final int flags;
}

/// Builds the face rectangle [u0]..[u1] × [y0]..[y1] on [plane] as a grid of
/// coplanar, NON-overlapping cells so details such as windows never fight
/// the wall in the painter's sort. [u] is x on front/back faces and z on
/// left/right faces. Later [holes] win where they overlap earlier ones.
void tiledFace(MeshBuilder b, Face face, double plane, double u0, double u1, double y0,
    double y1, Color base, List<Hole> holes, {int flags = 0}) {
  final us = <double>{u0, u1}, ys = <double>{y0, y1};
  for (final h in holes) {
    us..add(h.u0.clamp(u0, u1))..add(h.u1.clamp(u0, u1));
    ys..add(h.y0.clamp(y0, y1))..add(h.y1.clamp(y0, y1));
  }
  final su = us.toList()..sort(), sy = ys.toList()..sort();
  for (var i = 0; i < sy.length - 1; i++) {
    final ya = sy[i], yb = sy[i + 1];
    if (yb - ya < 1e-5) continue;
    final ym = (ya + yb) / 2;
    Color? runColor;
    var runFlags = 0;
    var runStart = 0.0;
    var open = false;
    void flush(double end) {
      if (open && runColor != null && end - runStart > 1e-5) {
        _faceQuad(b, face, plane, runStart, end, ya, yb, runColor!, runFlags);
      }
    }

    for (var j = 0; j < su.length - 1; j++) {
      final ua = su[j], ub = su[j + 1];
      if (ub - ua < 1e-5) continue;
      final um = (ua + ub) / 2;
      Color? c = base;
      var f = flags;
      for (final h in holes) {
        if (um > h.u0 && um < h.u1 && ym > h.y0 && ym < h.y1) {
          c = h.color;
          f = h.flags;
        }
      }
      if (!open || c != runColor || f != runFlags) {
        flush(ua);
        runColor = c;
        runFlags = f;
        runStart = ua;
        open = true;
      }
    }
    flush(su.last);
  }
}

void _faceQuad(MeshBuilder b, Face face, double plane, double ua, double ub, double ya,
    double yb, Color c, int flags) {
  final um = (ua + ub) / 2, ym = (ya + yb) / 2;
  switch (face) {
    case Face.front:
    case Face.back:
      final hint = Vec3(um, ym, plane + (face == Face.front ? 1 : -1));
      b.quad(Vec3(ua, ya, plane), Vec3(ub, ya, plane), Vec3(ub, yb, plane), Vec3(ua, yb, plane), c,
          outwardHint: hint, flags: flags);
    case Face.left:
    case Face.right:
      final hint = Vec3(plane + (face == Face.left ? 1 : -1), ym, um);
      b.quad(Vec3(plane, ya, ua), Vec3(plane, ya, ub), Vec3(plane, yb, ub), Vec3(plane, yb, ua), c,
          outwardHint: hint, flags: flags);
  }
}

/// Box on the ground ([y0]) whose side faces are [tiledFace]s: [faces] maps
/// a face to its cells (u/y in the face's own coordinates, i.e. absolute x
/// or z and absolute y). Faces not listed are plain. No bottom face.
void detailedBlock(MeshBuilder b, double cx, double y0, double cz, double sx, double sy,
    double sz, Color wall, Map<Face, List<Hole>> faces, {Color? top, int flags = 0}) {
  final x0 = cx - sx / 2, x1 = cx + sx / 2, z0 = cz - sz / 2, z1 = cz + sz / 2, y1 = y0 + sy;
  final side = shade(wall, -0.05);
  tiledFace(b, Face.front, z0, x0, x1, y0, y1, wall, faces[Face.front] ?? const [], flags: flags);
  tiledFace(b, Face.back, z1, x0, x1, y0, y1, wall, faces[Face.back] ?? const [], flags: flags);
  tiledFace(b, Face.left, x0, z0, z1, y0, y1, side, faces[Face.left] ?? const [], flags: flags);
  tiledFace(b, Face.right, x1, z0, z1, y0, y1, side, faces[Face.right] ?? const [], flags: flags);
  final c = Vec3(cx, y0 + sy / 2, cz);
  b.quad(Vec3(x0, y1, z0), Vec3(x1, y1, z0), Vec3(x1, y1, z1), Vec3(x0, y1, z1), top ?? wall,
      outwardHint: c, flags: flags);
}

/// Evenly spaced window cells along a face: [count] windows of [w]×[h]
/// centred between [u0] and [u1] at vertical centre [y].
List<Hole> windowRow(double u0, double u1, double y, double w, double h, int count,
    Color Function(int i) color, {int Function(int i)? flags}) {
  final step = (u1 - u0) / count;
  return [
    for (var i = 0; i < count; i++)
      Hole(u0 + step * (i + 0.5) - w / 2, u0 + step * (i + 0.5) + w / 2, y - h / 2, y + h / 2,
          color(i), flags: flags?.call(i) ?? 0),
  ];
}

/// Window with a frame: two nested cells (frame first, glass on top).
List<Hole> framed(double u, double y, double w, double h, Color glass, Color frame,
        {double border = 0.08, int glassFlags = 0}) =>
    [
      Hole(u - w / 2 - border, u + w / 2 + border, y - h / 2 - border, y + h / 2 + border, frame),
      Hole(u - w / 2, u + w / 2, y - h / 2, y + h / 2, glass, flags: glassFlags),
    ];

/// Single-sided disc facing along [normal] (wheels hubs, coin faces).
void disc(MeshBuilder b, Vec3 centre, Vec3 normal, double radius, Color color,
    {int segments = 8, int flags = 0, double phase = 0}) {
  final n = normal.normalized();
  final u = n.anyPerpendicular();
  final w = n.cross(u).normalized();
  final hint = centre - n;
  Vec3 at(int i) {
    final a = phase + i / segments * math.pi * 2;
    return centre + u * (math.cos(a) * radius) + w * (math.sin(a) * radius);
  }

  for (var i = 0; i < segments; i++) {
    b.triangle(centre, at(i), at(i + 1), color, outwardHint: hint, flags: flags);
  }
}

/// Irregular faceted blob (rocks, bushes, foliage). Each vertex is pushed
/// randomly by up to [jitter] of the radius and every face gets a slight
/// color variation for a premium faceted look. rings=3/segments=6 → 24 tris.
void lumpy(MeshBuilder b, Vec3 c, double radius, Color color, math.Random r,
    {Vec3 scale = const Vec3(1, 1, 1),
    double jitter = 0.18,
    int rings = 3,
    int segments = 6,
    double flatBottom = -1,
    double colorVar = 0.06,
    int flags = 0}) {
  final grid = <List<Vec3>>[];
  for (var i = 0; i <= rings; i++) {
    final row = <Vec3>[];
    final phi = i / rings * math.pi;
    for (var j = 0; j < segments; j++) {
      final th = (j + (i.isOdd ? 0.5 : 0)) / segments * math.pi * 2;
      final k = (i == 0 || i == rings) ? 1.0 : 1 + (r.nextDouble() * 2 - 1) * jitter;
      var y = math.cos(phi);
      if (y < flatBottom) y = flatBottom;
      row.add(Vec3(
        c.x + radius * scale.x * math.sin(phi) * math.cos(th) * k,
        c.y + radius * scale.y * y * k,
        c.z + radius * scale.z * math.sin(phi) * math.sin(th) * k,
      ));
    }
    grid.add(row);
  }
  Color col() => colorVar > 0 ? vary(color, r, colorVar) : color;
  for (var i = 0; i < rings; i++) {
    for (var j = 0; j < segments; j++) {
      final j1 = (j + 1) % segments;
      final p00 = grid[i][j], p01 = grid[i][j1], p10 = grid[i + 1][j], p11 = grid[i + 1][j1];
      if (i == 0) {
        b.triangle(p00, p11, p10, col(), outwardHint: c, flags: flags);
      } else if (i == rings - 1) {
        b.triangle(p00, p01, p10, col(), outwardHint: c, flags: flags);
      } else {
        b.triangle(p00, p01, p11, col(), outwardHint: c, flags: flags);
        b.triangle(p00, p11, p10, col(), outwardHint: c, flags: flags);
      }
    }
  }
}

/// Convex outline (x, y) extruded along z by [depth], centred on [centre].
void prism(MeshBuilder b, Vec3 centre, List<Offset> outline, double depth, Color color,
    {Color? sideColor, int flags = 0}) {
  b.withTransform(
    translate: centre,
    body: () => b.extrude(outline, depth, color, sideColor: sideColor, flags: flags),
  );
}

/// Regular N-gon outline of [radius] (pointy top when [pointyTop]).
List<Offset> ngon(int n, double radius, {bool pointyTop = true, double sy = 1}) => [
      for (var i = 0; i < n; i++)
        Offset(
          math.cos((pointyTop ? math.pi / 2 : math.pi / 2 + math.pi / n) + i / n * math.pi * 2) *
              radius,
          math.sin((pointyTop ? math.pi / 2 : math.pi / 2 + math.pi / n) + i / n * math.pi * 2) *
              radius *
              sy,
        ),
    ];

/// Bar from [x0] to [x1], [y0] to [y1], depth [d] centred at [z], whose
/// front (−z) and back (+z) faces are diagonal hazard stripes in [a]/[c]
/// (tiled, so they never z-fight). Top and ends use [a] darkened.
void stripedBar(MeshBuilder b, double x0, double x1, double y0, double y1, double z, double d,
    Color a, Color c, {int count = 6, int flags = 0, Color? top}) {
  final w = (x1 - x0) / count, h = y1 - y0;
  final s = math.min(w * 0.6, h * 0.8);
  final ctr = Vec3((x0 + x1) / 2, (y0 + y1) / 2, z);
  for (final zf in [z - d / 2, z + d / 2]) {
    for (var i = 0; i < count; i++) {
      final xa = x0 + i * w;
      final bl = xa, br = xa + w;
      final tl = i == 0 ? xa : xa + s, tr = i == count - 1 ? xa + w : xa + w + s;
      b.quad(Vec3(bl, y0, zf), Vec3(br, y0, zf), Vec3(tr, y1, zf), Vec3(tl, y1, zf),
          i.isEven ? a : c, outwardHint: ctr, flags: flags);
    }
  }
  final t = top ?? shade(a, -0.1);
  final zf = z - d / 2, zb = z + d / 2;
  b.quad(Vec3(x0, y1, zf), Vec3(x1, y1, zf), Vec3(x1, y1, zb), Vec3(x0, y1, zb), t, outwardHint: ctr, flags: flags);
  b.quad(Vec3(x0, y0, zf), Vec3(x1, y0, zf), Vec3(x1, y0, zb), Vec3(x0, y0, zb), shade(t, -0.3), outwardHint: ctr, flags: flags);
  b.quad(Vec3(x0, y0, zf), Vec3(x0, y1, zf), Vec3(x0, y1, zb), Vec3(x0, y0, zb), t, outwardHint: ctr, flags: flags);
  b.quad(Vec3(x1, y0, zf), Vec3(x1, y1, zf), Vec3(x1, y1, zb), Vec3(x1, y0, zb), t, outwardHint: ctr, flags: flags);
}

/// Horizontal ring bands stacked along y (lighthouse stripes, banded
/// pillars): consecutive frustum segments without internal caps.
void bandedColumn(MeshBuilder b, double cx, double cz, List<double> ys, List<double> radii,
    List<Color> colors, {int segments = 8, int flags = 0, bool topCap = true}) {
  for (var i = 0; i < ys.length - 1; i++) {
    b.cylinder(Vec3(cx, ys[i], cz), Vec3(cx, ys[i + 1], cz), radii[i], colors[i % colors.length],
        radiusB: radii[i + 1], segments: segments, caps: false, flags: flags);
  }
  if (topCap) {
    disc(b, Vec3(cx, ys.last, cz), Vec3.up, radii.last, shade(colors[(ys.length - 2) % colors.length], -0.1),
        segments: segments, flags: flags);
  }
}

/// Shorthand: emissive flag.
const int kGlow = MeshFlags.emissive;

/// Shorthand: double-sided flag.
const int kTwo = MeshFlags.doubleSided;
