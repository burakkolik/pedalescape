/// Software 3D rasterisation front-end.
///
/// Each frame: [begin] → add meshes / world triangles → [flush] onto a Canvas.
/// Triangles are transformed, bent along the track curve, lit (flat shading
/// with per-vertex fog), culled, depth-sorted per layer (bucket sort, painter's
/// algorithm) and drawn with a single `Canvas.drawVertices` call.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../mesh/mesh.dart';
import 'camera.dart';
import 'light_rig.dart';

/// Draw layers, drawn in ascending order. Inside a layer triangles are depth
/// sorted far → near.
abstract final class RenderLayer {
  static const int terrain = 0; // ground, road surface
  static const int decal = 1; // road markings, shadows
  static const int world = 2; // all solid objects
  static const int overlay = 3; // particles, glows, always on top
  static const int count = 4;
}

class RenderQueue {
  RenderQueue({int capacity = 12000}) {
    _ensure(capacity);
  }

  static const int _buckets = 2048;

  late Float32List _pos; // 6 floats / triangle (screen xy * 3)
  late Int32List _col; // 3 colors / triangle
  late Float32List _depth;
  late Uint8List _layer;
  int _count = 0;
  int _cap = 0;

  late Float32List _outPos;
  late Int32List _outCol;
  Int32List _bucketCounts = Int32List(_buckets * RenderLayer.count + 1);
  Int32List _order = Int32List(0);

  late Camera _cam;
  late LightRig _light;
  double _cp = 1, _sp = 0, _logNear = 0, _logRange = 1;

  // Track bend lookup (lateral & vertical offset as a function of distance
  // ahead of the camera).
  Float32List? _bendX;
  Float32List? _bendY;
  double _bendStep = 1;

  /// Number of triangles submitted this frame (debug / quality scaling).
  int get triangleCount => _count;

  void _ensure(int cap) {
    if (cap <= _cap) return;
    final old = _cap;
    final np = Float32List(cap * 6), nc = Int32List(cap * 3);
    final nd = Float32List(cap), nl = Uint8List(cap);
    if (old > 0) {
      np.setRange(0, old * 6, _pos);
      nc.setRange(0, old * 3, _col);
      nd.setRange(0, old, _depth);
      nl.setRange(0, old, _layer);
    }
    _pos = np;
    _col = nc;
    _depth = nd;
    _layer = nl;
    _outPos = Float32List(cap * 6);
    _outCol = Int32List(cap * 3);
    _order = Int32List(cap);
    _cap = cap;
  }

  void begin(Camera camera, LightRig light) {
    _cam = camera;
    _light = light;
    _cp = math.cos(camera.pitch);
    _sp = math.sin(camera.pitch);
    _logNear = math.log(camera.near);
    _logRange = math.log(camera.far * 1.5) - _logNear;
    _count = 0;
  }

  /// Sets the curve/hill offsets: [bx]/[by] sampled every [step] metres ahead
  /// of the camera. Pass null to disable bending.
  void setBend(Float32List? bx, Float32List? by, double step) {
    _bendX = bx;
    _bendY = by;
    _bendStep = step;
  }

  /// Lateral bend at [dz] metres ahead of the camera.
  double bendXAt(double dz) => _sample(_bendX, dz);
  double bendYAt(double dz) => _sample(_bendY, dz);

  double _sample(Float32List? t, double dz) {
    if (t == null || dz <= 0) return 0;
    final f = dz / _bendStep;
    final i = f.floor();
    if (i >= t.length - 1) return t[t.length - 1];
    final a = t[i];
    return a + (t[i + 1] - a) * (f - i);
  }

  /// Projects a world point (with bend) to screen. Returns null if behind.
  Offset? project(double x, double y, double z) {
    final dzw = z - _cam.z;
    final dx = x + _sample(_bendX, dzw) - _cam.x;
    final dy = y + _sample(_bendY, dzw) - _cam.y;
    final zc = -dy * _sp + dzw * _cp;
    if (zc < _cam.near) return null;
    final yc = dy * _cp + dzw * _sp;
    return Offset(_cam.cx + _cam.focal * dx / zc, _cam.cy - _cam.focal * yc / zc);
  }

  /// Camera-space depth of a world point (for sizing 2D sprites).
  double depthOf(double y, double z) => -(y - _cam.y) * _sp + (z - _cam.z) * _cp;

  // ------------------------------------------------------------ meshes --
  /// Submits [mesh] at world position (x, y, z).
  ///
  /// [tint] multiplies colors (0xFFRRGGBB), [alpha] fades the whole mesh.
  /// [bendPerVertex] bends every vertex (use for long objects); otherwise the
  /// bend at the object's origin is applied (cheaper, keeps shape rigid).
  void addMesh(
    Mesh mesh, {
    required double x,
    required double y,
    required double z,
    double yaw = 0,
    double pitch = 0,
    double roll = 0,
    double scale = 1,
    double scaleY = 1,
    int layer = RenderLayer.world,
    double alpha = 1,
    int? colorOverride,
    double brightness = 1,
    bool bendPerVertex = false,
    bool cull = true,
  }) {
    final cam = _cam;
    final dz0 = z - cam.z;
    final r = mesh.radius * scale * (scaleY > 1 ? scaleY : 1);
    if (dz0 + r < cam.near || dz0 - r > cam.far) return;
    final ox = bendPerVertex ? 0.0 : _sample(_bendX, dz0);
    final oy = bendPerVertex ? 0.0 : _sample(_bendY, dz0);
    // frustum side cull (approximate, generous)
    final zc0 = -(y + oy - cam.y) * _sp + dz0 * _cp;
    final lim = (zc0 + r) * cam.tanHalfX * 1.3 + r;
    if ((x + ox - cam.x).abs() > lim + 30 && !bendPerVertex) return;

    _ensure(_count + mesh.triangleCount + 16);

    // rotation
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cpp = math.cos(pitch), spp = math.sin(pitch);
    final cr = math.cos(roll), sr = math.sin(roll);
    final a00 = cy, a01 = sy * spp, a02 = sy * cpp;
    final a11 = cpp, a12 = -spp;
    final a20 = -sy, a21 = cy * spp, a22 = cy * cpp;
    final m00 = a00 * cr + a01 * sr, m01 = -a00 * sr + a01 * cr, m02 = a02;
    final m10 = a11 * sr, m11 = a11 * cr, m12 = a12;
    final m20 = a20 * cr + a21 * sr, m21 = -a20 * sr + a21 * cr, m22 = a22;

    final p = mesh.positions, n = mesh.normals, cols = mesh.colors, fl = mesh.flags;
    final light = _light;
    final focal = cam.focal, ccx = cam.cx, ccy = cam.cy, near = cam.near;
    final camX = cam.x, camY = cam.y, camZ = cam.z;
    final cp = _cp, sp = _sp;
    final sxs = scale, sys = scale * scaleY;
    final aMul = alpha.clamp(0.0, 1.0);
    final hasBend = bendPerVertex && _bendX != null;

    final vx = _mx, vy = _my, vz = _mz, zc = _mzc;

    for (var t = 0; t < cols.length; t++) {
      final b9 = t * 9;
      var ok = true;
      for (var k = 0; k < 3; k++) {
        final lx = p[b9 + k * 3] * sxs, ly = p[b9 + k * 3 + 1] * sys, lz = p[b9 + k * 3 + 2] * sxs;
        var wx = m00 * lx + m01 * ly + m02 * lz + x + ox;
        var wy = m10 * lx + m11 * ly + m12 * lz + y + oy;
        final wz = m20 * lx + m21 * ly + m22 * lz + z;
        if (hasBend) {
          final d = wz - camZ;
          wx += _sample(_bendX, d);
          wy += _sample(_bendY, d);
        }
        final dx = wx - camX, dy = wy - camY, dz = wz - camZ;
        final z2 = -dy * sp + dz * cp;
        if (z2 < near) {
          ok = false;
          break;
        }
        vx[k] = dx;
        vy[k] = dy;
        vz[k] = dz;
        zc[k] = z2;
      }
      if (!ok) continue;

      // world normal
      final nx0 = n[t * 3], ny0 = n[t * 3 + 1], nz0 = n[t * 3 + 2];
      final nx = m00 * nx0 + m01 * ny0 + m02 * nz0;
      final ny = m10 * nx0 + m11 * ny0 + m12 * nz0;
      final nz = m20 * nx0 + m21 * ny0 + m22 * nz0;
      final f = fl[t];
      if (cull && (f & MeshFlags.doubleSided) == 0) {
        if (nx * vx[0] + ny * vy[0] + nz * vz[0] > 0) continue;
      }

      _emit(vx, vy, vz, zc, cols[t], f, nx, ny, nz, light, focal, ccx, ccy, cp, sp, layer,
          aMul, colorOverride, brightness);
    }
  }

  void _emit(Float64List vx, Float64List vy, Float64List vz, Float64List zc, int base, int f, double nx,
      double ny, double nz, LightRig light, double focal, double ccx, double ccy, double cp,
      double sp, int layer, double aMul, int? colorOverride, double brightness) {
    final c = colorOverride ?? base;
    final emissive = (f & MeshFlags.emissive) != 0;
    var r = ((c >> 16) & 0xFF).toDouble();
    var g = ((c >> 8) & 0xFF).toDouble();
    var b = (c & 0xFF).toDouble();
    final a = ((c >> 24) & 0xFF) * aMul;
    if (!emissive) {
      // two-sided lighting for double sided faces
      var ndl = nx * light.sunX + ny * light.sunY + nz * light.sunZ;
      if ((f & MeshFlags.doubleSided) != 0 && ndl < 0) ndl = -ndl * 0.6;
      if (ndl < 0) ndl = 0;
      final hemi = 0.72 + 0.28 * ny;
      r *= (light.ambR * hemi + light.sunR * ndl) * brightness;
      g *= (light.ambG * hemi + light.sunG * ndl) * brightness;
      b *= (light.ambB * hemi + light.sunB * ndl) * brightness;
    } else {
      r *= brightness;
      g *= brightness;
      b *= brightness;
    }
    final fc = light.fogColor;
    final fr = ((fc >> 16) & 0xFF).toDouble(), fg = ((fc >> 8) & 0xFF).toDouble(), fb = (fc & 0xFF).toDouble();
    final fogS = light.fogStart, fogR = 1 / (light.fogEnd - light.fogStart);
    final res = emissive ? light.emissiveFogResistance : 0.0;

    final i = _count;
    final pb = i * 6, cb = i * 3;
    for (var k = 0; k < 3; k++) {
      final z2 = zc[k];
      final yc = vy[k] * cp + vz[k] * sp;
      _pos[pb + k * 2] = ccx + focal * vx[k] / z2;
      _pos[pb + k * 2 + 1] = ccy - focal * yc / z2;
      var ft = (z2 - fogS) * fogR;
      ft = ft < 0 ? 0 : (ft > 1 ? 1 : ft);
      ft *= (1 - res);
      final rr = r + (fr - r) * ft, gg = g + (fg - g) * ft, bb = b + (fb - b) * ft;
      _col[cb + k] = ((a.round() & 0xFF) << 24) |
          ((rr > 255 ? 255 : rr.round()) << 16) |
          ((gg > 255 ? 255 : gg.round()) << 8) |
          (bb > 255 ? 255 : bb.round());
    }
    _depth[i] = (zc[0] + zc[1] + zc[2]) / 3;
    _layer[i] = layer;
    _count++;
  }

  final Float64List _vzScratch = Float64List(3);
  final Float64List _mx = Float64List(3), _my = Float64List(3), _mz = Float64List(3), _mzc = Float64List(3);

  // ------------------------------------------------------ world triangles --
  /// Submits one world-space triangle (bent per vertex). Used for dynamic
  /// geometry like the road and terrain strips.
  void addWorldTriangle(
    double ax, double ay, double az,
    double bx, double by, double bz,
    double cx, double cy, double cz,
    int color, {
    int layer = RenderLayer.terrain,
    int flags = 0,
    double alpha = 1,
    bool cull = false,
    bool bend = true,
  }) {
    _ensure(_count + 4);
    final cam = _cam;
    final vx = _tx, vy = _ty, zc = _tz;
    final xs = [ax, bx, cx], ys = [ay, by, cy], zs = [az, bz, cz];
    final wx = _wx, wy = _wy, wz = _wz;
    for (var k = 0; k < 3; k++) {
      final dzw = zs[k] - cam.z;
      final bxv = bend ? _sample(_bendX, dzw) : 0.0;
      final byv = bend ? _sample(_bendY, dzw) : 0.0;
      wx[k] = xs[k] + bxv;
      wy[k] = ys[k] + byv;
      wz[k] = zs[k];
      final dx = wx[k] - cam.x, dy = wy[k] - cam.y;
      final z2 = -dy * _sp + dzw * _cp;
      if (z2 < cam.near) return;
      vx[k] = dx;
      vy[k] = dy;
      _vzScratch[k] = dzw;
      zc[k] = z2;
    }
    // normal from bent world points
    final ux = wx[1] - wx[0], uy = wy[1] - wy[0], uz = wz[1] - wz[0];
    final qx = wx[2] - wx[0], qy = wy[2] - wy[0], qz = wz[2] - wz[0];
    var nx = uy * qz - uz * qy, ny = uz * qx - ux * qz, nz = ux * qy - uy * qx;
    final l = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (l < 1e-12) return;
    nx /= l;
    ny /= l;
    nz /= l;
    if (ny < 0 && !cull) {
      nx = -nx;
      ny = -ny;
      nz = -nz;
    }
    if (cull && nx * vx[0] + ny * vy[0] + nz * _vzScratch[0] > 0) return;
    _emit(vx, vy, _vzScratch, zc, color, flags, nx, ny, nz, _light, cam.focal, cam.cx, cam.cy, _cp, _sp,
        layer, alpha, null, 1);
  }

  final Float64List _tx = Float64List(3), _ty = Float64List(3), _tz = Float64List(3);
  final Float64List _wx = Float64List(3), _wy = Float64List(3), _wz = Float64List(3);

  void addWorldQuad(
    double ax, double ay, double az,
    double bx, double by, double bz,
    double cx, double cy, double cz,
    double dx, double dy, double dz,
    int color, {
    int layer = RenderLayer.terrain,
    int flags = 0,
    double alpha = 1,
  }) {
    addWorldTriangle(ax, ay, az, bx, by, bz, cx, cy, cz, color, layer: layer, flags: flags, alpha: alpha);
    addWorldTriangle(ax, ay, az, cx, cy, cz, dx, dy, dz, color, layer: layer, flags: flags, alpha: alpha);
  }

  // ----------------------------------------------------------------- flush --
  final Paint _paint = Paint()..isAntiAlias = true;

  /// Sorts and draws everything submitted since [begin].
  void flush(Canvas canvas) {
    final n = _count;
    if (n == 0) return;
    // counting sort on (layer, far→near bucket)
    final total = _buckets * RenderLayer.count;
    if (_bucketCounts.length < total + 1) _bucketCounts = Int32List(total + 1);
    final counts = _bucketCounts..fillRange(0, total + 1, 0);
    final keys = Int32List(n);
    for (var i = 0; i < n; i++) {
      final d = _depth[i];
      var k = ((math.log(d < 0.01 ? 0.01 : d) - _logNear) / _logRange * (_buckets - 1)).floor();
      if (k < 0) k = 0;
      if (k >= _buckets) k = _buckets - 1;
      final key = _layer[i] * _buckets + (_buckets - 1 - k);
      keys[i] = key;
      counts[key + 1]++;
    }
    for (var i = 1; i <= total; i++) {
      counts[i] += counts[i - 1];
    }
    final order = _order;
    for (var i = 0; i < n; i++) {
      order[counts[keys[i]]++] = i;
    }
    final op = _outPos, oc = _outCol;
    for (var j = 0; j < n; j++) {
      final i = order[j];
      op.setRange(j * 6, j * 6 + 6, _pos, i * 6);
      oc.setRange(j * 3, j * 3 + 3, _col, i * 3);
    }
    final vertices = Vertices.raw(
      VertexMode.triangles,
      Float32List.sublistView(op, 0, n * 6),
      colors: Int32List.sublistView(oc, 0, n * 3),
    );
    canvas.drawVertices(vertices, BlendMode.dst, _paint);
    vertices.dispose();
    _count = 0;
  }
}
