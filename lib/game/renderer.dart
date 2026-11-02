import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'bike_painter.dart';
import 'config.dart';
import 'entities.dart';
import 'game.dart';
import 'ground_texture.dart';
import 'palette.dart';
import 'quality.dart';
import 'skins.dart';
import 'sprites.dart';
import 'util.dart';

/// Batches sprites for a single `drawRawAtlas` call. Fixed capacity.
class _Batch {
  _Batch(this.cap) : rst = Float32List(cap * 4), rect = Float32List(cap * 4), col = Int32List(cap);

  final int cap;
  final Float32List rst;
  final Float32List rect;
  final Int32List col;
  int n = 0;

  /// Adds sprite [id] with its anchor at screen ([x],[y]). [scale] is screen
  /// pixels per atlas pixel. [cropBottom] removes atlas pixels at the bottom
  /// (used to hide the parts of a sprite that are behind a hill crest).
  void add(
    SpriteAtlas a,
    int id,
    double x,
    double y,
    double scale,
    int color, {
    double rot = 0,
    double cropBottom = 0,
  }) {
    if (n >= cap) return;
    final l = a.left[id], t = a.top[id], r = a.right[id];
    var b = a.bottom[id];
    if (cropBottom > 0) {
      b -= cropBottom;
      if (b <= t + 0.5) return;
    }
    final ax = a.anchorX[id], ay = a.anchorY[id];
    final scos = rot == 0 ? scale : scale * math.cos(rot);
    final ssin = rot == 0 ? 0.0 : scale * math.sin(rot);
    final i = n * 4;
    rst[i] = scos;
    rst[i + 1] = ssin;
    rst[i + 2] = x - (scos * ax - ssin * ay);
    rst[i + 3] = y - (ssin * ax + scos * ay);
    rect[i] = l;
    rect[i + 1] = t;
    rect[i + 2] = r;
    rect[i + 3] = b;
    col[n] = color;
    n++;
  }

  void draw(Canvas c, ui.Image img, Paint p) {
    if (n == 0) return;
    c.drawRawAtlas(
      img,
      Float32List.sublistView(rst, 0, n * 4),
      Float32List.sublistView(rect, 0, n * 4),
      Int32List.sublistView(col, 0, n),
      BlendMode.modulate,
      null,
      p,
    );
    n = 0;
  }
}

/// Growable-never vertex buffer for colored (optionally textured) triangles.
class _Mesh {
  _Mesh(int maxVerts, int maxIdx)
    : pos = Float32List(maxVerts * 2),
      uv = Float32List(maxVerts * 2),
      col = Int32List(maxVerts),
      idx = Uint16List(maxIdx);

  final Float32List pos;
  final Float32List uv;
  final Int32List col;
  final Uint16List idx;
  int v = 0;
  int i = 0;

  void reset() {
    v = 0;
    i = 0;
  }

  bool get full => v + 4 > col.length || i + 6 > idx.length;

  /// Quad with a bottom edge (y1, x1l..x1r, color c1) and top edge (y2, c2).
  void quad(double x1l, double x1r, double y1, double x2l, double x2r, double y2, int c1, int c2) =>
      quad4(x1l, x1r, y1, x2l, x2r, y2, c1, c1, c2, c2);

  /// Quad with individual colors: bottom-left, bottom-right, top-right, top-left.
  void quad4(double x1l, double x1r, double y1, double x2l, double x2r, double y2, int bl, int br, int tr, int tl) =>
      quadP(x1l, y1, x1r, y1, x2r, y2, x2l, y2, bl, br, tr, tl);

  /// Free-form quad a-b-c-d (counter or clockwise) with per-corner colors.
  void quadP(
    double ax,
    double ay,
    double bx,
    double by,
    double cx,
    double cy,
    double dx,
    double dy,
    int ca,
    int cb,
    int cc,
    int cd,
  ) {
    if (full) return;
    final b = v;
    final p = v * 2;
    pos[p] = ax;
    pos[p + 1] = ay;
    pos[p + 2] = bx;
    pos[p + 3] = by;
    pos[p + 4] = cx;
    pos[p + 5] = cy;
    pos[p + 6] = dx;
    pos[p + 7] = dy;
    uv[p] = 0;
    uv[p + 1] = 0;
    uv[p + 2] = 1;
    uv[p + 3] = 0;
    uv[p + 4] = 1;
    uv[p + 5] = 1;
    uv[p + 6] = 0;
    uv[p + 7] = 1;
    col[v] = ca;
    col[v + 1] = cb;
    col[v + 2] = cc;
    col[v + 3] = cd;
    v += 4;
    idx[i] = b;
    idx[i + 1] = b + 1;
    idx[i + 2] = b + 2;
    idx[i + 3] = b;
    idx[i + 4] = b + 2;
    idx[i + 5] = b + 3;
    i += 6;
  }

  /// Sets texture coordinates of the last quad added with [quad]/[quad4]
  /// (bottom-left, bottom-right, top-right, top-left order).
  void uvLast(double u1l, double u1r, double v1, double u2l, double u2r, double v2) {
    if (v < 4) return;
    final p = (v - 4) * 2;
    uv[p] = u1l;
    uv[p + 1] = v1;
    uv[p + 2] = u1r;
    uv[p + 3] = v1;
    uv[p + 4] = u2r;
    uv[p + 5] = v2;
    uv[p + 6] = u2l;
    uv[p + 7] = v2;
  }

  void draw(Canvas c, Paint p, {bool textured = false, BlendMode mode = BlendMode.dst}) {
    if (i == 0) return;
    final vs = ui.Vertices.raw(
      ui.VertexMode.triangles,
      Float32List.sublistView(pos, 0, v * 2),
      textureCoordinates: textured ? Float32List.sublistView(uv, 0, v * 2) : null,
      colors: Int32List.sublistView(col, 0, v),
      indices: Uint16List.sublistView(idx, 0, i),
    );
    c.drawVertices(vs, mode, p);
    vs.dispose();
  }
}

class GameRenderer {
  GameRenderer({required Skin skin, required this.quality}) : bike = BikePainter(skin) {
    _buildTables();
  }

  Quality quality;
  final BikePainter bike;

  SpriteAtlas? _atlas;
  double _atlasQ = 0;
  GroundTexture? _tex;
  final Paint _texPaint = Paint()..isAntiAlias = false;

  static final Float64List _identity = Float64List(16)
    ..[0] = 1
    ..[5] = 1
    ..[10] = 1
    ..[15] = 1;

  /// Texture texels per world meter on the ground.
  static const double _texPerM = 40;

  static const int _maxSeg = 220;

  // Per projected point.
  final Float32List _wx = Float32List(_maxSeg + 2);
  final Float32List _wy = Float32List(_maxSeg + 2);
  final Float32List _zr = Float32List(_maxSeg + 2);
  final Float32List _sx = Float32List(_maxSeg + 2);
  final Float32List _sy = Float32List(_maxSeg + 2);
  final Float32List _ss = Float32List(_maxSeg + 2);
  final Float32List _fog = Float32List(_maxSeg + 2);
  final Float32List _lit = Float32List(_maxSeg + 2);
  final Float32List _kt = Float32List(_maxSeg + 2); // texture scale per row
  final Uint8List _valid = Uint8List(_maxSeg + 2);
  // Per segment.
  final Float32List _clip = Float32List(_maxSeg + 2);
  final Uint8List _vis = Uint8List(_maxSeg + 2);

  final _Mesh _road = _Mesh(_maxSeg * 110, _maxSeg * 165);
  final _Mesh _back = _Mesh(2400, 3600);
  final _Mesh _fx = _Mesh(160, 240);

  final _Batch _far = _Batch(700);
  final _Batch _near = _Batch(160);
  final _Batch _glow = _Batch(160);
  final _Batch _sky = _Batch(24);
  final _Batch _skyGlow = _Batch(8);
  final _Batch _flare = _Batch(12);
  final _Batch _smoke = _Batch(K.maxParticles);
  final _Batch _sparks = _Batch(K.maxParticles);

  final Int32List _order = Int32List(K.maxObjects);
  int _orderN = 0;

  final Palette pal = Palette();

  final Paint _meshPaint = Paint()..isAntiAlias = false;
  final Paint _addMeshPaint = Paint()
    ..isAntiAlias = false
    ..blendMode = BlendMode.plus;
  final Paint _spritePaint = Paint()..filterQuality = FilterQuality.low;
  final Paint _additive = Paint()
    ..filterQuality = FilterQuality.low
    ..blendMode = BlendMode.plus;
  final Paint _sun = Paint();
  final Paint _stars = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2;
  final Paint _rain = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.6;
  final Paint _lines = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.2;
  final Paint _bolt = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = 3;
  final Paint _flat = Paint();
  final Paint _vignette = Paint();
  final Paint _hurt = Paint();
  final Paint _storm = Paint();
  final Path _stormPath = Path();
  final Path _boltPath = Path();

  Size _shaderSize = Size.zero;

  // Static tables.
  final Float32List _mFar = Float32List(512);
  final Float32List _mMid = Float32List(512);
  final Float32List _mNear = Float32List(512);
  final Float32List _mTrees = Float32List(1024);
  final Float32List _starXY = Float32List(160);
  final Float32List _starBuf = Float32List(160);
  final Float32List _rainBuf = Float32List(4 * 160);
  final Float32List _lineBuf = Float32List(4 * 40);

  // Frame values.
  double _w = 0, _h = 0, _f = 0, _cy = 0, _dpr = 2;
  double _stormK = 0, _wet = 0;
  double _sunX = 0, _sunY = 0, _sunVis = 0;
  int _base = 0;
  int _nSeg = 0;

  // Projection output for objects.
  double _ox = 0, _oy = 0, _os = 0, _oclip = 0, _oz = 0;

  void setSkin(Skin s) => bike.setSkin(s);

  void dispose() {
    _atlas?.dispose();
    _atlas = null;
    _tex?.dispose();
    _tex = null;
    _texPaint.shader = null;
  }

  void _buildTables() {
    final rnd = math.Random(42);
    void fill(Float32List t, List<int> freqs, double rough) {
      final phases = List<double>.generate(freqs.length, (_) => rnd.nextDouble() * math.pi * 2);
      var mx = 0.0, mn = 1e9;
      for (var i = 0; i < t.length; i++) {
        final u = i / t.length * math.pi * 2;
        var v = 0.0;
        for (var k = 0; k < freqs.length; k++) {
          v += math.sin(u * freqs[k] + phases[k]) / math.pow(freqs[k], rough);
        }
        t[i] = v;
        mx = math.max(mx, v);
        mn = math.min(mn, v);
      }
      for (var i = 0; i < t.length; i++) {
        t[i] = (t[i] - mn) / (mx - mn);
      }
    }

    fill(_mFar, [2, 3, 5, 9, 17, 31], 0.75);
    fill(_mMid, [3, 4, 7, 13, 23], 0.8);
    fill(_mNear, [5, 8, 19, 37, 61], 0.55);
    // Forest edge on the horizon: rolling base plus pointy crowns.
    for (var i = 0; i < _mTrees.length; i++) {
      final cell = i ~/ 6;
      final f = (i % 6) / 6;
      final tip = 1 - (f - 0.5).abs() * 2; // triangle 0..1..0
      final hgt = 0.45 + hash01(cell * 3 + 1) * 0.55;
      final base = 0.35 + 0.25 * math.sin(i / _mTrees.length * math.pi * 2 * 5 + 1.3);
      _mTrees[i] = base * 0.5 + tip * tip * hgt * 0.5;
    }
    for (var i = 0; i < 80; i++) {
      _starXY[i * 2] = rnd.nextDouble();
      _starXY[i * 2 + 1] = math.pow(rnd.nextDouble(), 1.4).toDouble();
    }
  }

  void _ensureAtlas(Size size, double dpr) {
    // Texture resolution adapts to the physical screen width and quality.
    final q = clampD(size.width * dpr / 1080 * quality.atlasScale, 0.4, 1.0);
    if (_atlas != null && (q - _atlasQ).abs() < 0.05) return;
    _atlas?.dispose();
    _atlas = SpriteAtlas.build(q);
    _atlasQ = q;
  }

  void _ensureTexture() {
    if (!quality.textures) return;
    if (_tex != null) return;
    final t = GroundTexture.build();
    _tex = t;
    _texPaint.shader = ImageShader(
      t.image,
      TileMode.repeated,
      TileMode.repeated,
      _identity,
      filterQuality: FilterQuality.medium,
    );
  }

  void _ensureShaders(Size size) {
    if (size == _shaderSize) return;
    _shaderSize = size;
    final c = Offset(size.width / 2, size.height * 0.55);
    final r = size.longestSide * 0.75;
    _vignette.shader = ui.Gradient.radial(
      c,
      r,
      const [Color(0x00000000), Color(0x00000000), Color(0xff000000)],
      const [0, 0.55, 1],
    );
    _hurt.shader = ui.Gradient.radial(
      c,
      r,
      const [Color(0x00ff0000), Color(0x00ff0000), Color(0xffd01020)],
      const [0, 0.5, 1],
    );
    _storm.shader = ui.Gradient.linear(
      const Offset(0, -0.1),
      const Offset(0, 1),
      const [Color(0x00140a26), Color(0xbb140a26), Color(0xf2080410)],
      const [0, 0.4, 1],
    );
  }

  // ------------------------------------------------------------------ paint

  void paint(Canvas canvas, Size size, Game g, double dpr) {
    if (size.isEmpty) return;
    _ensureAtlas(size, dpr);
    _ensureTexture();
    _ensureShaders(size);
    final atlas = _atlas!;
    _w = size.width;
    _h = size.height;
    _dpr = dpr;
    final turboAmt = clampD(g.turboT, 0, 1);
    _f = _w * 0.86 * (1 - 0.12 * turboAmt);
    final playerTargetY = _h * 0.84;
    _cy = math.max(_h * 0.22, playerTargetY - K.camHeight / K.playerDist * _w * 0.86);
    _nSeg = math.min(_maxSeg, quality.segments);
    g.smoke.limit = quality.particles;
    g.sparks.limit = quality.particles;

    final cycle = (g.playerZ + 300) / K.dayCycle;
    paletteAt(cycle, pal);
    _stormK = g.phase != Phase.menu ? clampD(1 - g.stormGap / 32, 0, 1) : 0.0;
    _wet = clampD(_stormK * 1.6, 0, 1) * 0.85 + pal.night * 0.3;

    var sx = 0.0, sy = 0.0;
    if (g.shake > 0) {
      final a = g.shake * _w * 0.018;
      sx = math.sin(g.time * 61) * a;
      sy = math.cos(g.time * 53) * a;
    }
    canvas.save();
    canvas.translate(sx, sy);

    _project(g);
    _drawSky(canvas, g, atlas, cycle);
    _drawMountains(canvas, g);
    _drawRoad(canvas, g);
    _drawHorizonHaze(canvas);
    _drawHeadlight(canvas, g);
    _collectSprites(g, atlas);
    _far.draw(canvas, atlas.image, _spritePaint);
    if (quality.glows) _glow.draw(canvas, atlas.image, _additive);
    _drawPlayer(canvas, g, atlas);
    _near.draw(canvas, atlas.image, _spritePaint);
    _drawParticles(canvas, g, atlas);
    canvas.restore();

    _drawOverlays(canvas, g, atlas);
  }

  // ------------------------------------------------------------- projection

  void _project(Game g) {
    final road = g.road;
    final camZ = g.camZ;
    _base = (camZ / K.segLen).floor();
    final pct = (camZ - _base * K.segLen) / K.segLen;
    var x = 0.0;
    var dx = -road.curveAt(_base) * pct;
    final n = _nSeg;
    final halfW = _w * 0.5;
    final fogDen = 3.2 / (n * K.segLen);
    final night = pal.night;
    for (var i = 0; i <= n + 1; i++) {
      final seg = _base + i;
      final zr = seg * K.segLen - camZ;
      _wx[i] = x;
      _wy[i] = road.yAt(seg);
      _zr[i] = zr;
      if (zr > 0.6) {
        final s = _f / zr;
        _sx[i] = halfW + (x - g.camX) * s;
        _sy[i] = _cy - (_wy[i] - g.camY) * s;
        _ss[i] = s;
        _valid[i] = 1;
        final fo = 1 - math.exp(-zr * fogDen);
        _fog[i] = fo * fo * (3 - 2 * fo);
        var lit = 1 + night * 1.25 * math.exp(-zr / 16);
        if (night > 0.25 && (seg ~/ 500) % 3 == 2) {
          // Pools of light under the boulevard lamps.
          final d = seg % 14;
          final dd = d < 7 ? d : 14 - d;
          if (dd < 4) lit += (night - 0.25) * 1.1 * (1 - dd / 4);
        }
        // Slopes facing the camera catch more light, downhill gets darker.
        final slope = (road.yAt(seg + 1) - road.yAt(seg - 1)) / (2 * K.segLen);
        lit *= 1 + clampD(slope * 0.7, -0.14, 0.14);
        _lit[i] = lit;
        // Texture scale: never sample more than ~1.5 texels per pixel.
        _kt[i] = math.min(1.0, s * _dpr / (_texPerM * 1.5));
      } else {
        _valid[i] = 0;
      }
      x += dx;
      dx += road.curveAt(seg);
    }
    var maxY = _h + 40;
    for (var i = 0; i <= n; i++) {
      _clip[i] = maxY;
      if (_valid[i] == 1 && _valid[i + 1] == 1) {
        final top = _sy[i + 1];
        _vis[i] = top < maxY ? 1 : 0;
        if (top < maxY) maxY = top;
      } else {
        _vis[i] = 0;
      }
    }
  }

  /// Projects a world point at track distance [z]. Returns false if not in view.
  bool _projectZ(double z, double xOff, double yOff, Game g) {
    final zr = z - g.camZ;
    if (zr < 0.7) return false;
    final fz = z / K.segLen;
    final seg = fz.floor();
    final i = seg - _base;
    if (i < 0 || i >= _nSeg) return false;
    final t = fz - seg;
    final wx = _wx[i] + (_wx[i + 1] - _wx[i]) * t;
    final wy = _wy[i] + (_wy[i + 1] - _wy[i]) * t;
    final s = _f / zr;
    _ox = _w * 0.5 + (wx + xOff - g.camX) * s;
    _oy = _cy - (wy + yOff - g.camY) * s;
    _os = s;
    _oclip = _clip[i];
    _oz = zr;
    return true;
  }

  // -------------------------------------------------------------------- sky

  void _drawSky(Canvas canvas, Game g, SpriteAtlas atlas, double cycle) {
    final m = _back..reset();
    // Sky gradient in three bands (bright band just above the horizon) plus
    // haze below the horizon.
    final night = pal.night;
    final mid = lerpColor(pal.skyTop, pal.skyHorizon, 0.55);
    final low = lerpColor(pal.skyHorizon, 0xffffffff, 0.18 * (1 - night));
    final skyMidY = _cy * 0.55;
    final lowY = _cy * 0.86;
    m.quad(-50, _w + 50, skyMidY, -50, _w + 50, -50, mid, pal.skyTop);
    m.quad(-50, _w + 50, lowY, -50, _w + 50, skyMidY, pal.skyHorizon, mid);
    m.quad(-50, _w + 50, _cy + 2, -50, _w + 50, lowY, low, pal.skyHorizon);
    m.quad(-50, _w + 50, _h + 50, -50, _w + 50, _cy, pal.fog, pal.fog);
    m.draw(canvas, _meshPaint);

    // Stars (twinkling).
    if (night > 0.35) {
      final a = (night - 0.35) / 0.65;
      for (var i = 0; i < 80; i++) {
        var x = (_starXY[i * 2] - g.skyOffset * 0.02) % 1.0;
        if (x < 0) x += 1;
        _starBuf[i * 2] = x * _w;
        _starBuf[i * 2 + 1] = _starXY[i * 2 + 1] * _cy * 0.92;
      }
      _stars.color = Color.fromRGBO(255, 255, 255, a * (0.75 + 0.1 * math.sin(g.time * 3)));
      _stars.strokeWidth = math.max(1.5, _w / 320);
      canvas.drawRawPoints(ui.PointMode.points, Float32List.sublistView(_starBuf, 0, 120), _stars);
      _stars.color = Color.fromRGBO(220, 230, 255, a * (0.7 + 0.25 * math.sin(g.time * 2.3 + 1)));
      _stars.strokeWidth = math.max(2.2, _w / 220);
      canvas.drawRawPoints(ui.PointMode.points, Float32List.sublistView(_starBuf, 120, 160), _stars);
    }

    // Sun or moon.
    final c = cycle - cycle.floorToDouble();
    double sunH;
    if (c < 0.42) {
      sunH = 0.72;
    } else if (c < 0.6) {
      sunH = lerpD(0.72, -0.12, (c - 0.42) / 0.18);
    } else if (c > 0.86) {
      sunH = lerpD(-0.12, 0.72, (c - 0.86) / 0.14);
    } else {
      sunH = -1;
    }
    final glowS = _w * 0.9 / atlas.width(Spr.glow);
    var bx = _w * 0.7 - g.skyOffset * _w * 0.03;
    bx = bx % (_w * 1.6);
    _sunVis = 0;
    if (sunH > -0.2) {
      final by = _cy - sunH * _cy * 0.85;
      final r = _w * 0.06;
      // Low sun: larger, warmer halo.
      final lowSun = clampD(1 - sunH / 0.5, 0, 1);
      _skyGlow.add(atlas, Spr.glow, bx, by, glowS * (1 + lowSun * 0.6), withAlpha(pal.sun, 0.55));
      _skyGlow.add(atlas, Spr.glow, bx, by, glowS * 0.35, withAlpha(pal.sun, 0.9));
      _skyGlow.draw(canvas, atlas.image, _additive);
      _sun.color = Color(pal.sun);
      canvas.drawCircle(Offset(bx, by), r, _sun);
      _sunX = bx;
      _sunY = by;
      _sunVis = clampD((sunH + 0.05) / 0.2, 0, 1) * clampD(1 - night * 1.1, 0, 1);
    }
    if (night > 0.5) {
      final mx = (_w * 0.25 - g.skyOffset * _w * 0.03) % (_w * 1.6);
      final my = _cy * 0.3;
      final a = (night - 0.5) * 2;
      _skyGlow.add(atlas, Spr.glow, mx, my, glowS * 0.5, withAlpha(0xffc8d8ff, 0.35 * a));
      _skyGlow.add(atlas, Spr.glow, mx, my, glowS * 1.4, withAlpha(0xff8090c0, 0.12 * a));
      _skyGlow.draw(canvas, atlas.image, _additive);
      _sun.color = Color.fromRGBO(236, 242, 255, a);
      canvas.drawCircle(Offset(mx, my), _w * 0.045, _sun);
      _sun.color = Color.fromRGBO(180, 190, 215, a * 0.6);
      canvas.drawCircle(Offset(mx - _w * 0.012, my - _w * 0.008), _w * 0.011, _sun);
      canvas.drawCircle(Offset(mx + _w * 0.015, my + _w * 0.012), _w * 0.008, _sun);
    }

    if (quality.detail && _sunVis > 0.02) _drawRays(canvas, g);

    // Clouds: a far, small and hazy layer near the horizon and a near layer.
    if (quality.clouds) {
      final p = _w * 2.4;
      final tint = withAlpha(pal.cloud, 0.92 - night * 0.45);
      final farTint = withAlpha(lerpColor(pal.cloud, pal.skyHorizon, 0.45), 0.8 - night * 0.4);
      final nFar = quality.detail ? 5 : 0;
      for (var i = 0; i < nFar; i++) {
        final u = hash01(i * 29 + 3);
        final id = _cloudId(i);
        final sc = _w * (0.22 + hash01(i * 3 + 7) * 0.18) / atlas.width(id);
        var x = (u * p - g.skyOffset * _w * 0.05 - g.time * _w * 0.002) % p;
        if (x < 0) x += p;
        x -= _w * 0.4;
        _sky.add(atlas, id, x, _cy * (0.74 + hash01(i * 11) * 0.12), sc, farTint);
      }
      final nNear = quality.detail ? 7 : 6;
      for (var i = 0; i < nNear; i++) {
        final u = hash01(i * 13 + 1);
        final hy = 0.12 + hash01(i * 7 + 3) * 0.5;
        final id = _cloudId(i);
        final sc = _w * (0.45 + hash01(i * 5 + 2) * 0.55) / atlas.width(id);
        var x = (u * p - g.skyOffset * _w * 0.08 - g.time * _w * 0.004) % p;
        if (x < 0) x += p;
        x -= _w * 0.4;
        _sky.add(atlas, id, x, _cy * hy, sc, tint);
      }
      _sky.draw(canvas, atlas.image, _spritePaint);
    }
  }

  static int _cloudId(int i) => switch (i % 3) {
    0 => Spr.cloud0,
    1 => Spr.cloud1,
    _ => Spr.cloud2,
  };

  /// Soft crepuscular rays fanning down from the sun (additive, very cheap).
  void _drawRays(Canvas canvas, Game g) {
    final m = _fx..reset();
    final warm = clampD(1 - (pal.night - 0.25).abs() / 0.25, 0, 1);
    final a = _sunVis * (0.045 + 0.08 * warm);
    const n = 9;
    final len = _h * 0.95;
    for (var k = 0; k < n; k++) {
      final ang = math.pi / 2 + (k - (n - 1) / 2) * 0.24 + math.sin(g.time * 0.12 + k * 1.7) * 0.04;
      final spread = 0.03 + hash01(k * 5 + 2) * 0.045;
      final aa = a * (0.45 + hash01(k * 3 + 1) * 0.55) * (0.7 + 0.3 * math.sin(g.time * 0.4 + k * 2.1));
      final c0 = withAlpha(pal.sun, aa);
      final c1 = withAlpha(pal.sun, 0);
      final xa = _sunX + math.cos(ang - spread) * len, ya = _sunY + math.sin(ang - spread) * len;
      final xb = _sunX + math.cos(ang + spread) * len, yb = _sunY + math.sin(ang + spread) * len;
      m.quadP(_sunX - 1, _sunY, _sunX + 1, _sunY, xb, yb, xa, ya, c0, c0, c1, c1);
    }
    m.draw(canvas, _addMeshPaint);
  }

  void _mountainLayer(
    _Mesh m,
    Float32List table,
    double period,
    double offset,
    double height,
    double baseY,
    double bottomY,
    int topCol,
    int botCol, {
    int snowCol = 0,
    double snowFrom = 2,
    int columns = 0,
    double relief = 0,
  }) {
    final cols = columns > 0 ? columns : quality.mountainColumns;
    final step = (_w + 40) / cols;
    // Faces turned toward the sun (or moon) are lit, the others shaded.
    final lightSide = (_sunVis > 0 ? _sunX : _w * 0.25) < _w * 0.5 ? -1.0 : 1.0;
    var prevX = -20.0, prevY = 0.0;
    var prevC = topCol;
    for (var k = 0; k <= cols; k++) {
      final x = -20 + k * step;
      final u = (x + offset) / period;
      final hn = _sampleTable(table, u);
      final y = baseY - hn * height;
      var c = snowCol != 0 && hn > snowFrom
          ? lerpColor(topCol, snowCol, clampD((hn - snowFrom) / (1 - snowFrom) * 1.6, 0, 1))
          : topCol;
      if (relief > 0) {
        // Slope over a wide window so whole faces are lit or shaded together.
        const du = 0.02;
        final slope = (_sampleTable(table, u + du) - _sampleTable(table, u - du)) * height / (2 * du * period);
        c = shadeColor(c, 1 - clampD(slope * lightSide * relief * 0.5, -0.2, 0.2));
      }
      if (k > 0) {
        // Quad from previous column to this one: bottom edge at bottomY.
        m.quadP(prevX, bottomY, x, bottomY, x, y, prevX, prevY, botCol, botCol, c, prevC);
      }
      prevX = x;
      prevY = y;
      prevC = c;
    }
  }

  static double _sampleTable(Float32List table, double u) {
    u -= u.floorToDouble();
    final fi = u * table.length;
    final i0 = fi.floor() % table.length;
    final i1 = (i0 + 1) % table.length;
    return lerpD(table[i0], table[i1], fi - fi.floorToDouble());
  }

  void _drawMountains(Canvas canvas, Game g) {
    final m = _back..reset();
    final so = g.skyOffset * _w;
    final fogC = pal.fog;
    final relief = quality.detail ? 0.9 * (1 - pal.night * 0.6) : 0.0;
    final farTop = lerpColor(pal.mountainFar, fogC, 0.15);
    final snow = lerpColor(0xfff4f8ff, fogC, 0.25 + pal.night * 0.35);
    _mountainLayer(
      m,
      _mFar,
      _w * 2.6,
      so * 0.12 + g.camX * 2,
      _w * 0.30,
      _cy + 1,
      _cy + _h * 0.03,
      farTop,
      lerpColor(pal.mountainFar, fogC, 0.8),
      snowCol: snow,
      snowFrom: 0.72,
      relief: relief * 0.6,
    );
    _mountainLayer(
      m,
      _mMid,
      _w * 1.9,
      so * 0.22 + g.camX * 4,
      _w * 0.17,
      _cy + 2,
      _cy + _h * 0.05,
      lerpColor(pal.mountainMid, fogC, 0.1),
      lerpColor(pal.mountainMid, fogC, 0.7),
      relief: relief,
    );
    if (quality.detail) {
      // Distant forest edge.
      final treeC = lerpColor(shadeColor(pal.hills, 0.8), fogC, 0.42);
      _mountainLayer(
        m,
        _mTrees,
        _w * 1.15,
        so * 0.3 + g.camX * 6,
        _w * 0.05,
        _cy + 2.5,
        _cy + _h * 0.05,
        treeC,
        lerpColor(pal.hills, fogC, 0.6),
        columns: 150,
      );
    }
    _mountainLayer(
      m,
      _mNear,
      _w * 1.3,
      so * 0.38 + g.camX * 8,
      _w * 0.06,
      _cy + 3,
      _h + 50,
      lerpColor(pal.hills, fogC, 0.25),
      lerpColor(pal.hills, fogC, 0.6),
      relief: relief * 0.6,
    );
    m.draw(canvas, _meshPaint);
  }

  // ------------------------------------------------------------------- road

  // Cross profile of the asphalt (meters from the center line) and brightness:
  // dirty edges, darker oil strip in the middle of each lane and polished
  // wheel tracks.
  static const List<double> _profX = [
    -3.2, -2.95, -2.75, -2.0, -1.25, -1.0, -0.75, 0.0, 0.75, 1.0, 1.25, 2.0, 2.75, 2.95, 3.2, //
  ];
  static const List<double> _profF = [
    0.84, 0.97, 1.04, 0.93, 1.04, 1.0, 1.04, 0.93, 1.04, 1.0, 1.04, 0.93, 1.04, 0.97, 0.84, //
  ];

  double _gain = 1;
  int _fogG = 0;

  /// Lit, fogged color of [c] at projected row [i] (pre-divided by the texture
  /// mean when the ground is textured).
  int _shadePoint(int c, int i) => lerpColor(shadeColor(c, _lit[i] * _gain), _fogG, _fog[i]);

  void _drawRoad(Canvas canvas, Game g) {
    final m = _road..reset();
    final p = pal;
    final tex = _tex != null && quality.textures;
    final detail = quality.detail;
    _gain = tex ? 1 / _tex!.mean : 1.0;
    _fogG = shadeColor(p.fog, _gain);
    const tS = _texPerM;
    const shM = K.roadHalf + K.rumbleW + 0.5;
    const kbM = K.roadHalf + K.rumbleW;
    final gl = -_w * 0.3, gr = _w * 1.3;
    for (var i = _nSeg; i >= 0; i--) {
      if (_vis[i] == 0) continue;
      final j = i + 1;
      final seg = _base + i;
      final x1 = _sx[i], y1 = _sy[i], s1 = _ss[i];
      final x2 = _sx[j], y2 = _sy[j], s2 = _ss[j];
      final alt3 = (seg ~/ 3) & 1 == 0;
      final alt2 = (seg ~/ 2) & 1 == 0;
      // Texture coordinates: u across the road, v along it (wraps seamlessly
      // every 64 segments = 20 texture tiles).
      final k1 = _kt[i], k2 = _kt[j];
      final u1 = tS * k1, u2 = tS * k2;
      final vb = (seg & 63) * K.segLen * tS * k1;
      final v1 = vb, v2 = vb + K.segLen * tS * k1;

      // Grass, split at the road so it can get a soft lateral falloff.
      final gc = alt3 ? p.grassA : p.grassB;
      final gn1 = _shadePoint(gc, i), gn2 = _shadePoint(gc, j);
      var gf1 = gn1, gf2 = gn2;
      if (detail) {
        final gFar = lerpColor(gc, p.hills, 0.35);
        gf1 = _shadePoint(gFar, i);
        gf2 = _shadePoint(gFar, j);
      }
      final sh1 = shM * s1, sh2 = shM * s2;
      m.quad4(gl, x1 - sh1, y1, gl, x2 - sh2, y2, gf1, gn1, gn2, gf2);
      if (tex) {
        m.uvLast((gl - x1) / s1 * u1, -shM * u1, v1 * 0.2, (gl - x2) / s2 * u2, -shM * u2, v2 * 0.2);
      }
      m.quad4(x1 + sh1, gr, y1, x2 + sh2, gr, y2, gn1, gf1, gf2, gn2);
      if (tex) {
        m.uvLast(shM * u1, (gr - x1) / s1 * u1, v1 * 0.2, shM * u2, (gr - x2) / s2 * u2, v2 * 0.2);
      }

      // Gravel shoulder just outside the kerb.
      final shoulder = shadeColor(lerpColor(gc, 0xff8a8170, 0.35), 0.8);
      m.quad(x1 - sh1, x1 + sh1, y1, x2 - sh2, x2 + sh2, y2, _shadePoint(shoulder, i), _shadePoint(shoulder, j));
      if (tex) m.uvLast(-shM * u1, shM * u1, v1, -shM * u2, shM * u2, v2);

      // Kerbs (beveled: lit inner edge, darker outer edge).
      final rw1 = K.roadHalf * s1, rw2 = K.roadHalf * s2;
      final kb1 = kbM * s1, kb2 = kbM * s2;
      final rc = alt2 ? p.rumbleA : p.rumbleB;
      final rc1 = _shadePoint(rc, i), rc2 = _shadePoint(rc, j);
      final ro1 = detail ? shadeColor(rc1, 0.78) : rc1, ro2 = detail ? shadeColor(rc2, 0.78) : rc2;
      final ri1 = detail ? shadeColor(rc1, 1.08) : rc1, ri2 = detail ? shadeColor(rc2, 1.08) : rc2;
      m.quad4(x1 - kb1, x1 - rw1, y1, x2 - kb2, x2 - rw2, y2, ro1, ri1, ri2, ro2);
      if (tex) m.uvLast(-kbM * u1, -K.roadHalf * u1, v1, -kbM * u2, -K.roadHalf * u2, v2);
      m.quad4(x1 + rw1, x1 + kb1, y1, x2 + rw2, x2 + kb2, y2, ri1, ro1, ro2, ri2);
      if (tex) m.uvLast(K.roadHalf * u1, kbM * u1, v1, K.roadHalf * u2, kbM * u2, v2);

      // Asphalt.
      final ac = alt3 ? p.roadA : p.roadB;
      final a1 = _shadePoint(ac, i), a2 = _shadePoint(ac, j);
      if (detail && s1 > 1.5) {
        // Occasional repaired patch in one lane (spans 3 segments).
        var patch = 9;
        final grp = seg ~/ 3;
        if (hash01(grp * 7 + 1) < 0.08) patch = (hash01(grp * 13 + 5) * 3).floor() - 1;
        for (var k = 0; k < _profX.length - 1; k++) {
          final xa = _profX[k], xb = _profX[k + 1];
          var fa = _profF[k], fb = _profF[k + 1];
          if (patch != 9 && ((xa + xb) * 0.5 - patch * K.laneW).abs() < 0.9) {
            fa *= 0.9;
            fb *= 0.9;
          }
          m.quad4(
            x1 + xa * s1,
            x1 + xb * s1,
            y1,
            x2 + xa * s2,
            x2 + xb * s2,
            y2,
            shadeColor(a1, fa),
            shadeColor(a1, fb),
            shadeColor(a2, fb),
            shadeColor(a2, fa),
          );
          if (tex) m.uvLast(xa * u1, xb * u1, v1, xa * u2, xb * u2, v2);
        }
      } else {
        m.quad(x1 - rw1, x1 + rw1, y1, x2 - rw2, x2 + rw2, y2, a1, a2);
        if (tex) m.uvLast(-K.roadHalf * u1, K.roadHalf * u1, v1, -K.roadHalf * u2, K.roadHalf * u2, v2);
      }

      // Solid edge lines.
      final lc1 = _shadePoint(p.lane, i), lc2 = _shadePoint(p.lane, j);
      if (s1 * 0.1 > 0.4) {
        const e0 = K.roadHalf - 0.3, e1 = K.roadHalf - 0.18;
        m.quad(x1 - e1 * s1, x1 - e0 * s1, y1, x2 - e1 * s2, x2 - e0 * s2, y2, lc1, lc2);
        if (tex) m.uvLast(-e1 * u1, -e0 * u1, v1, -e1 * u2, -e0 * u2, v2);
        m.quad(x1 + e0 * s1, x1 + e1 * s1, y1, x2 + e0 * s2, x2 + e1 * s2, y2, lc1, lc2);
        if (tex) m.uvLast(e0 * u1, e1 * u1, v1, e0 * u2, e1 * u2, v2);
      }
      // Dashed lane separators.
      if (seg % 4 < 2 && s1 * 0.14 > 0.5) {
        const l0 = K.laneW * 0.5 - 0.07, l1 = K.laneW * 0.5 + 0.07;
        m.quad(x1 - l1 * s1, x1 - l0 * s1, y1, x2 - l1 * s2, x2 - l0 * s2, y2, lc1, lc2);
        if (tex) m.uvLast(-l1 * u1, -l0 * u1, v1, -l1 * u2, -l0 * u2, v2);
        m.quad(x1 + l0 * s1, x1 + l1 * s1, y1, x2 + l0 * s2, x2 + l1 * s2, y2, lc1, lc2);
        if (tex) m.uvLast(l0 * u1, l1 * u1, v1, l0 * u2, l1 * u2, v2);
      }

      if (detail && s1 > 0.8) _drawRails(m, seg, i, j);
    }
    if (tex) {
      m.draw(canvas, _texPaint, textured: true, mode: BlendMode.modulate);
    } else {
      m.draw(canvas, _meshPaint);
    }
  }

  /// Guard rails in the forest, wooden fences in the meadows. Built from mesh
  /// quads so hills hide them correctly and they cost no sprites.
  void _drawRails(_Mesh m, int seg, int i, int j) {
    final biome = (seg ~/ 500) % 3;
    if (biome == 2) return;
    final x1 = _sx[i], y1 = _sy[i], s1 = _ss[i];
    final x2 = _sx[j], s2 = _ss[j];
    const railX = K.roadHalf + K.rumbleW + 0.95;
    final metal = biome == 0;
    for (var side = -1.0; side <= 1; side += 2) {
      final xx = side * railX;
      final ax = x1 + xx * s1, bx = x2 + xx * s2;
      if (metal) {
        _railBand(m, i, j, ax, bx, 0.46, 0.62, 0xffa5adb8);
        _railBand(m, i, j, ax, bx, 0.62, 0.78, 0xffd2d8e0);
      } else {
        _railBand(m, i, j, ax, bx, 0.34, 0.44, 0xff9a7550);
        _railBand(m, i, j, ax, bx, 0.76, 0.88, 0xffa98460);
      }
      // Post at the near end of the section.
      if (seg.isEven) {
        final pw = (metal ? 0.07 : 0.08) * s1;
        final ph = (metal ? 0.8 : 1.0) * s1;
        final pc = metal ? 0xff6d747e : 0xff6a4a2c;
        final top = _shadePoint(pc, i), bot = _shadePoint(shadeColor(pc, 0.6), i);
        m.quad(ax - pw, ax + pw, y1, ax - pw, ax + pw, y1 - ph, bot, top);
        // Reflector on the guard rail posts, picked up by the headlight.
        if (metal && pal.night > 0.3) {
          final rc = lerpColor(0xffff9a20, 0xffffffff, 0.2);
          final rcol = lerpColor(withAlpha(rc, 1), _fogG, _fog[i]);
          m.quad(ax - pw, ax + pw, y1 - ph * 0.72, ax - pw, ax + pw, y1 - ph * 0.86, rcol, rcol);
        }
      }
    }
  }

  void _railBand(_Mesh m, int i, int j, double ax, double bx, double h0, double h1, int c) {
    final s1 = _ss[i], s2 = _ss[j], y1 = _sy[i], y2 = _sy[j];
    final dark = shadeColor(c, 0.78);
    m.quadP(
      ax,
      y1 - h0 * s1,
      bx,
      y2 - h0 * s2,
      bx,
      y2 - h1 * s2,
      ax,
      y1 - h1 * s1,
      _shadePoint(dark, i),
      _shadePoint(dark, j),
      _shadePoint(c, j),
      _shadePoint(c, i),
    );
  }

  /// Hazy band where the land meets the sky (aerial perspective).
  void _drawHorizonHaze(Canvas canvas) {
    if (!quality.detail) return;
    final m = _fx..reset();
    final c = lerpColor(pal.fog, 0xffffffff, 0.12 * (1 - pal.night));
    const a = 0.5;
    final top = _cy - _h * 0.05, bot = _cy + _h * 0.025;
    m.quad(-10, _w + 10, _cy, -10, _w + 10, top, withAlpha(c, a), withAlpha(c, 0));
    m.quad(-10, _w + 10, bot, -10, _w + 10, _cy, withAlpha(c, 0), withAlpha(c, a));
    m.draw(canvas, _meshPaint);
  }

  final Float32List _hlN = Float32List(4), _hlM = Float32List(4), _hlF = Float32List(4);
  static const List<double> _hlNo = [-0.8, -0.35, 0.35, 0.8];
  static const List<double> _hlMo = [-1.3, -0.6, 0.6, 1.3];
  static const List<double> _hlFo = [-4.2, -2.2, 2.2, 4.2];

  void _drawHeadlight(Canvas canvas, Game g) {
    final night = pal.night;
    if (night < 0.2 || g.phase == Phase.crashing) return;
    final m = _fx..reset();
    if (!_projectZ(g.playerZ + 0.6, g.x, 0, g)) return;
    final nx = _ox, ny = _oy, ns = _os;
    if (!_projectZ(g.playerZ + 4, g.x + g.lean * 0.4, 0, g)) return;
    final mx = _ox, my = _oy, ms = _os;
    if (!_projectZ(g.playerZ + 30, g.x + g.lean * 2, 0, g)) return;
    final fx = _ox, fy = _oy, fs = _os;
    final a = (night - 0.2) / 0.8;
    final c1 = withAlpha(0xffffe6a8, 0.34 * a);
    const c0 = 0x00ffe6a8;
    // 3 columns (soft fringe, core, soft fringe) x 2 rows: fades in just
    // ahead of the wheel, full at ~4 m, gone at 30 m.
    final nxs = _hlN, mxs = _hlM, fxs = _hlF;
    for (var k = 0; k < 4; k++) {
      nxs[k] = nx + _hlNo[k] * ns;
      mxs[k] = mx + _hlMo[k] * ms;
      fxs[k] = fx + _hlFo[k] * fs;
    }
    for (var k = 0; k < 3; k++) {
      final ml = k == 0 ? c0 : c1, mr = k == 2 ? c0 : c1;
      m.quadP(nxs[k], ny, nxs[k + 1], ny, mxs[k + 1], my, mxs[k], my, c0, c0, mr, ml);
      m.quadP(mxs[k], my, mxs[k + 1], my, fxs[k + 1], fy, fxs[k], fy, ml, mr, c0, c0);
    }
    m.draw(canvas, _addMeshPaint);
  }

  // ---------------------------------------------------------------- sprites

  int _spriteColor(double zr, double fogT, {double extraLight = 0}) {
    final head = pal.night * math.exp(-zr / 14) + extraLight;
    final tint = lerpColor(pal.spriteTint, 0xffffffff, clampD(head, 0, 1));
    final a = 1 - fogT * fogT;
    return withAlpha(tint, a);
  }

  double _fogAt(double zr) {
    final fo = 1 - math.exp(-zr * 3.2 / (_nSeg * K.segLen));
    return fo * fo * (3 - 2 * fo);
  }

  void _addWorld(
    _Batch b,
    SpriteAtlas a,
    int id,
    double sx,
    double sy,
    double pxPerM,
    double clip,
    int color, {
    double rot = 0,
    double scaleMul = 1,
  }) {
    final sc = pxPerM / a.metersToSrc[id] * scaleMul;
    final hPx = a.height(id) * sc;
    if (hPx < 1.2) return;
    var crop = 0.0;
    // Only sprites standing on the ground can be hidden by hills.
    final bottom = sy + (a.height(id) - a.anchorY[id]) * sc;
    if (bottom > clip && rot == 0) {
      crop = (bottom - clip) / sc;
      if (crop >= a.height(id)) return;
    }
    if (sx < -hPx * 2 || sx > _w + hPx * 2) return;
    b.add(a, id, sx, sy, sc, color, rot: rot, cropBottom: crop);
  }

  void _collectSprites(Game g, SpriteAtlas a) {
    // Sort visible objects far -> near (insertion sort on a fixed index list).
    _orderN = 0;
    final maxZ = g.camZ + _nSeg * K.segLen;
    final objs = g.objects;
    for (var k = 0; k < objs.length; k++) {
      final o = objs[k];
      if (!o.active || o.z < g.camZ + 0.7 || o.z > maxZ) continue;
      var j = _orderN++;
      while (j > 0 && objs[_order[j - 1]].z < o.z) {
        _order[j] = _order[j - 1];
        j--;
      }
      _order[j] = k;
    }
    var oi = 0;
    final detail = quality.detail;
    final step = quality.sceneryStep;
    final pz = g.playerZ;

    for (var i = _nSeg - 1; i >= 1; i--) {
      final seg = _base + i;
      final segZ = seg * K.segLen;
      // World objects belonging to this segment (and anything farther).
      while (oi < _orderN && objs[_order[oi]].z >= segZ) {
        _addObject(g, a, objs[_order[oi]]);
        oi++;
      }
      if (_valid[i] == 0) continue;
      final b = segZ > pz ? _far : _near;
      final s = _ss[i];
      final fogT = _fog[i];
      final zr = _zr[i];
      final col = _spriteColor(zr, fogT);
      final clip = _clip[i];
      final biome = (seg ~/ 500) % 3;

      // Street lamps along the boulevard biome and sometimes elsewhere.
      if (seg % 14 == 0 && (biome == 2 || seg % 42 == 0)) {
        final side = (seg ~/ 14).isEven ? -1 : 1;
        final poleX = side * (K.roadHalf + K.rumbleW + 0.7);
        const poleOff = 59 / 170 * 2.8; // pole distance from sprite center
        const headOff = 108 / 170 * 2.8; // lamp head distance from the pole
        final id = side < 0 ? Spr.lampL : Spr.lampR;
        _addWorld(b, a, id, _sx[i] + (poleX - side * poleOff) * s, _sy[i], s, clip, col);
        if (quality.glows && pal.night > 0.25) {
          final hx = poleX - side * headOff;
          final glowC = withAlpha(0xffffd890, (pal.night - 0.25) * 0.9 * (1 - fogT));
          _addWorld(_glow, a, Spr.glow, _sx[i] + hx * s, _sy[i] - 6.2 * s, s, 1e9, glowC, scaleMul: 2.4);
          if (detail && _wet > 0.1) {
            // Reflection of the lamp on the (wet) asphalt.
            final rc = withAlpha(0xffffd890, (pal.night - 0.25) * 0.8 * _wet * (1 - fogT));
            _addWorld(_glow, a, Spr.streak, _sx[i] + hx * s, _sy[i] - 0.05 * s, s, clip, rc, scaleMul: 1.4);
          }
        }
      }

      _collectExtras(g, a, b, i, seg, biome, s, zr, fogT, col, clip);

      if (seg % 97 == 0 && seg > 20) {
        final side = (seg ~/ 97).isEven ? 1 : -1;
        _addWorld(b, a, Spr.billboard, _sx[i] + side * (K.roadHalf + 6) * s, _sy[i], s, clip, col);
        continue;
      }

      if (seg % step != 0) continue;
      for (var side = -1; side <= 1; side += 2) {
        final h = hash01(seg * 2 + (side > 0 ? 1 : 0));
        final density = biome == 0 ? 0.85 : (biome == 1 ? 0.6 : 0.35);
        if (h > density) continue;
        final h2 = hash01(seg * 31 + side * 7 + 5);
        final h3 = hash01(seg * 17 + side * 3 + 9);
        int id;
        if (biome == 0) {
          id = h2 < 0.6 ? Spr.pine : (h2 < 0.76 ? Spr.birch : (h2 < 0.88 ? Spr.bush : Spr.rock));
        } else if (biome == 1) {
          id = h2 < 0.4 ? Spr.oak : (h2 < 0.62 ? Spr.bush : (h2 < 0.8 ? Spr.flower : (h2 < 0.9 ? Spr.rock : Spr.pine)));
        } else {
          id = h2 < 0.5 ? Spr.bush : (h2 < 0.75 ? Spr.oak : Spr.flower);
        }
        final dist = K.roadHalf + K.rumbleW + 1.6 + h3 * (id == Spr.flower || id == Spr.bush ? 4 : 11);
        final sm = 0.8 + h3 * 0.45;
        _addWorld(b, a, id, _sx[i] + side * dist * s, _sy[i], s, clip, col, scaleMul: sm);
      }
    }
    while (oi < _orderN) {
      _addObject(g, a, objs[_order[oi]]);
      oi++;
    }
  }

  /// Landmarks and small details: wind turbines, barns, poplar avenue, grass
  /// tufts and fireflies. Everything is derived from the segment index, so
  /// nothing is stored.
  void _collectExtras(
    Game g,
    SpriteAtlas a,
    _Batch b,
    int i,
    int seg,
    int biome,
    double s,
    double zr,
    double fogT,
    int col,
    double clip,
  ) {
    final sx = _sx[i], sy = _sy[i];
    if (biome == 1) {
      // Wind turbines far out in the fields.
      if (seg % 37 == 5) {
        final side = hash01(seg * 3) < 0.5 ? -1 : 1;
        final lat = side * (34 + hash01(seg * 7 + 1) * 46);
        final sm = 0.85 + hash01(seg * 11) * 0.3;
        final bx = sx + lat * s;
        _addWorld(b, a, Spr.tower, bx, sy, s, clip, col, scaleMul: sm);
        final hubY = sy - a.height(Spr.tower) / a.metersToSrc[Spr.tower] * s * sm;
        if (hubY < clip) {
          _addWorld(b, a, Spr.blades, bx, hubY, s, 1e9, col, rot: g.time * 0.9 + seg, scaleMul: sm);
        }
      }
      if (seg % 113 == 40) {
        final side = hash01(seg * 5) < 0.5 ? -1 : 1;
        _addWorld(b, a, Spr.barn, sx + side * (17 + hash01(seg * 9) * 9) * s, sy, s, clip, col);
      }
    } else if (biome == 2 && seg % 6 == 3) {
      // Poplar avenue.
      for (var side = -1; side <= 1; side += 2) {
        final sm = 0.9 + hash01(seg * 13 + side) * 0.25;
        _addWorld(b, a, Spr.poplar, sx + side * (K.roadHalf + K.rumbleW + 3.4) * s, sy, s, clip, col, scaleMul: sm);
      }
    }
    if (!quality.detail) return;

    // Grass tufts along the road edge (only near the camera).
    if (zr < 60) {
      for (var side = -1; side <= 1; side += 2) {
        final h = hash01(seg * 41 + side * 5 + 2);
        if (h > 0.8) continue;
        final id = Spr.tuft0 + (biome == 1 && h < 0.35 ? 1 : 0);
        final lat = side * (K.roadHalf + K.rumbleW + 0.6 + hash01(seg * 43 + side) * 2.6);
        _addWorld(b, a, id, sx + lat * s, sy, s, clip, col, scaleMul: 0.7 + h * 0.6);
      }
    }

    // Fireflies on summer nights.
    final night = pal.night;
    if (quality.glows && night > 0.45 && biome != 2 && seg.isEven && zr < 90) {
      final hh = hash01(seg * 19 + 3);
      if (hh < 0.45) {
        final side = hh < 0.22 ? -1 : 1;
        final t = g.time;
        final lat = side * (5.2 + hash01(seg * 23) * 7) + math.sin(t * 0.7 + seg) * 0.6;
        final fy = 0.6 + hash01(seg * 29) * 1.6 + math.sin(t * 1.1 + seg * 1.3) * 0.35;
        final blink = 0.5 + 0.5 * math.sin(t * 2.6 + seg * 2.1);
        final fc = withAlpha(0xffd4ff6a, (night - 0.45) * 1.8 * blink * blink * (1 - fogT));
        _addWorld(_glow, a, Spr.glow, sx + lat * s, sy - fy * s, s, 1e9, fc, scaleMul: 0.4);
      }
    }
  }

  void _addObject(Game g, SpriteAtlas a, WorldObject o) {
    final k = o.kind;
    var yOff = o.y;
    final isPickup = k == Kind.coin || k.isPowerUp;
    if (isPickup) yOff += math.sin(o.phase) * 0.12;
    if (!_projectZ(o.z, o.x, yOff, g)) return;
    final b = o.z > g.playerZ + 0.4 ? _far : _near;
    final fogT = _fogAt(_oz);
    final col = _spriteColor(_oz, fogT);
    final clip = o.knocked ? 1e9 : _oclip;
    switch (k) {
      case Kind.car:
        _addWorld(
          b,
          a,
          Spr.car0 + (o.variant & 3),
          _ox,
          _oy + math.sin(g.time * 20 + o.phase) * 0.01 * _os,
          _os,
          clip,
          col,
          rot: o.rot,
        );
        _tailLights(g, a, 0.72, 0.74, fogT);
      case Kind.truck:
        _addWorld(b, a, Spr.truck, _ox, _oy, _os, clip, col, rot: o.rot);
        _tailLights(g, a, 0.95, 0.55, fogT);
      case Kind.barrier:
        _addWorld(b, a, Spr.barrier, _ox, _oy, _os, clip, col, rot: o.rot);
        if (quality.glows && b == _far) {
          final blink = (math.sin(g.time * 8 + o.phase) > 0) ? 0.7 : 0.25;
          final gc = withAlpha(0xffffb020, blink * (1 - fogT));
          final ox = _ox, oy = _oy, os = _os;
          _addWorld(_glow, a, Spr.glow, ox - 0.7 * os, oy - 0.98 * os, os, 1e9, gc, scaleMul: 0.7);
          _addWorld(_glow, a, Spr.glow, ox + 0.7 * os, oy - 0.98 * os, os, 1e9, gc, scaleMul: 0.7);
        }
      case Kind.gate:
        _addWorld(b, a, Spr.gate, _ox, _oy, _os, clip, col, rot: o.rot);
      case Kind.cone:
        _addWorld(b, a, Spr.cone, _ox, _oy, _os, clip, col, rot: o.rot);
      case Kind.puddle:
        _addWorld(b, a, Spr.puddle, _ox, _oy + 0.3 * _os, _os, clip, withAlpha(col, 0.9 * (1 - fogT)));
      case Kind.coin:
        final ox = _ox, oy = _oy, os = _os;
        if (quality.shadows && _projectZ(o.z, o.x, 0, g)) {
          _addWorld(b, a, Spr.shadow, _ox, _oy, _os * 0.6, _oclip, withAlpha(0xffffffff, 0.5 * (1 - fogT)));
        }
        final frame = ((g.time * 9 + o.phase) % 8).floor() & 7;
        _addWorld(b, a, Spr.coin0 + frame, ox, oy, os, clip, col);
        if (quality.detail && quality.glows && b == _far) {
          // Occasional glint.
          final tw = math.sin(g.time * 3.1 + o.phase * 5.3);
          if (tw > 0.9) {
            final k = (tw - 0.9) * 10;
            final sc = withAlpha(0xffffffff, k * (1 - fogT));
            _addWorld(_glow, a, Spr.sparkle, ox + 0.17 * os, oy - 0.17 * os, os, 1e9, sc, scaleMul: 0.75 * k + 0.2);
          }
        }
      default:
        // Power-ups.
        final id = switch (k) {
          Kind.shield => Spr.shield,
          Kind.magnet => Spr.magnet,
          Kind.turbo => Spr.turbo,
          _ => Spr.x2,
        };
        final ox = _ox, oy = _oy, os = _os;
        if (quality.glows && b == _far) {
          _addWorld(
            _glow,
            a,
            Spr.glow,
            ox,
            oy,
            os,
            1e9,
            withAlpha(0xffffffff, 0.55 * (1 - fogT)),
            scaleMul: 1.8 + math.sin(g.time * 5) * 0.2,
          );
        }
        _addWorld(b, a, id, ox, oy, os, clip, col);
    }
  }

  void _tailLights(Game g, SpriteAtlas a, double dx, double h, double fogT) {
    if (!quality.glows) return;
    final i = 0.25 + pal.night * 0.75;
    final c = withAlpha(0xffff3030, i * (1 - fogT));
    final ox = _ox, oy = _oy, os = _os;
    _addWorld(_glow, a, Spr.glow, ox - dx * os, oy - h * os, os, 1e9, c, scaleMul: 0.9 + pal.night * 0.6);
    _addWorld(_glow, a, Spr.glow, ox + dx * os, oy - h * os, os, 1e9, c, scaleMul: 0.9 + pal.night * 0.6);
    if (quality.detail && _wet > 0.15) {
      final rc = withAlpha(0xffff3030, i * 0.7 * _wet * (1 - fogT));
      _addWorld(_glow, a, Spr.streak, ox - dx * os, oy + 0.05 * os, os, 1e9, rc, scaleMul: 0.55);
      _addWorld(_glow, a, Spr.streak, ox + dx * os, oy + 0.05 * os, os, 1e9, rc, scaleMul: 0.55);
    }
  }

  // ----------------------------------------------------------------- player

  void _drawPlayer(Canvas canvas, Game g, SpriteAtlas a) {
    if (!_projectZ(g.playerZ, g.x, 0, g)) return;
    final gx = _ox, gy = _oy, s = _os;
    g.playerScreenX = gx;
    g.playerScreenY = gy;
    g.playerPxPerM = s;

    // Turbo exhaust glow.
    if (g.turboT > 0) {
      final pulse = 0.8 + math.sin(g.time * 30) * 0.2;
      _glow.add(a, Spr.glow, gx, gy - 0.5 * s - g.jumpY * s, s * 1.6 / a.metersToSrc[Spr.glow] * pulse, 0xccff8a20);
      _glow.draw(canvas, a.image, _additive);
    }

    canvas.save();
    canvas.translate(gx, gy);
    canvas.scale(s, s);
    bike.paintShadow(canvas, g.jumpY);
    canvas.restore();

    final blink = g.invulnT > 0 && g.phase == Phase.playing && ((g.time * 14).floor() & 1) == 0;
    if (blink) return;

    // Let the scene light (dusk, night, storm) tint the rider so they sit in
    // the world instead of looking pasted on. One small offscreen layer.
    final tint = _riderTint();
    final tinted = quality.detail && tint != 0xffffffff;
    if (tinted) {
      if (tint != _tintColor) {
        _tintColor = tint;
        _tintPaint.colorFilter = ColorFilter.mode(Color(tint), BlendMode.modulate);
      }
      final top = gy - (g.jumpY + 2.1) * s;
      canvas.saveLayer(Rect.fromLTRB(gx - 1.3 * s, top, gx + 1.3 * s, gy + 0.3 * s), _tintPaint);
    }
    canvas.save();
    canvas.translate(gx, gy - g.jumpY * s);
    canvas.scale(s, s);
    bike.paint(
      canvas,
      pedal: g.pedal,
      duck: g.ducking ? 1 : 0,
      lean: g.lean,
      night: pal.night,
      shield: g.shield,
      time: g.time,
      crash: g.phase == Phase.crashing ? 1 : 0,
    );
    canvas.restore();
    if (tinted) canvas.restore();

    // Blinking rear LED at night.
    if (quality.glows && pal.night > 0.3) {
      final on = math.sin(g.time * 9) > -0.2 ? 1.0 : 0.3;
      final rc = withAlpha(0xffff2020, (pal.night - 0.3) * 0.95 * on);
      final rot = g.lean;
      final rx = gx + math.sin(rot) * 0.79 * s;
      final ry = gy - g.jumpY * s - math.cos(rot) * 0.79 * s;
      _glow.add(a, Spr.glow, rx, ry, s * 0.55 / a.metersToSrc[Spr.glow], rc);
      _glow.draw(canvas, a.image, _additive);
    }
  }

  int _tintColor = 0xffffffff;
  final Paint _tintPaint = Paint();

  int _riderTint() {
    // Quantized so the color filter is rebuilt only a few times per cycle.
    var t = lerpColor(pal.spriteTint, 0xffffffff, 0.45);
    t = shadeColor(t, 1 - _stormK * 0.25);
    return t & 0xfff8f8f8 | 0xff070707;
  }

  // -------------------------------------------------------------- particles

  void _drawParticles(Canvas canvas, Game g, SpriteAtlas a) {
    final pw = a.width(Spr.puff);
    final sm = g.smoke;
    for (var i = 0; i < sm.count; i++) {
      final lf = sm.life[i] / sm.maxLife[i];
      final c = sm.color[i];
      final alpha = ((c >> 24) & 0xff) / 255 * lf;
      _smoke.add(a, Spr.puff, sm.x[i], sm.y[i], sm.size[i] * 2 / pw, withAlpha(shadeColor(c, pal.light), alpha));
    }
    _smoke.draw(canvas, a.image, _spritePaint);

    final gw = a.width(Spr.glow);
    final sp = g.sparks;
    for (var i = 0; i < sp.count; i++) {
      final lf = sp.life[i] / sp.maxLife[i];
      final c = sp.color[i];
      final alpha = ((c >> 24) & 0xff) / 255 * math.min(1, lf * 1.5);
      _sparks.add(a, Spr.glow, sp.x[i], sp.y[i], sp.size[i] * 2.4 / gw, withAlpha(c, alpha));
    }
    _sparks.draw(canvas, a.image, _additive);
  }

  // --------------------------------------------------------------- overlays

  static const List<double> _flareT = [0.42, 0.7, 1.05, 1.32, 1.7];
  static const List<double> _flareS = [0.05, 0.11, 0.04, 0.17, 0.08];
  static const List<double> _flareA = [0.16, 0.08, 0.22, 0.06, 0.1];
  static const List<int> _flareC = [0xffffd27a, 0xff9fe0ff, 0xffffffff, 0xffb48cff, 0xff8affc8];

  void _drawOverlays(Canvas canvas, Game g, SpriteAtlas atlas) {
    final w = _w, h = _h;
    final playing = g.phase != Phase.menu;
    final stormK = _stormK;

    // Sun bloom and lens flare ghosts along the sun -> screen center line.
    if (quality.detail && quality.glows && _sunVis > 0.05 && _sunX > -w * 0.2 && _sunX < w * 1.2) {
      final base = _sunVis * (1 - stormK);
      final gw = atlas.width(Spr.glow);
      final dx = w * 0.5 - _sunX, dy = h * 0.5 - _sunY;
      _flare.add(atlas, Spr.glow, _sunX, _sunY, w * 1.3 / gw, withAlpha(pal.sun, 0.16 * base));
      for (var k = 0; k < _flareT.length; k++) {
        final t = _flareT[k];
        _flare.add(
          atlas,
          Spr.glow,
          _sunX + dx * t,
          _sunY + dy * t,
          w * _flareS[k] * 2 / gw,
          withAlpha(_flareC[k], _flareA[k] * base),
        );
      }
      _flare.draw(canvas, atlas.image, _additive);
    }

    // Speed lines (turbo or very fast).
    final speedK = clampD((g.speed - 24) / 10, 0, 1);
    final lineK = math.max(clampD(g.turboT, 0, 1), speedK * 0.5);
    if (lineK > 0.02 && playing) {
      final n = (40 * lineK).round().clamp(4, 40);
      final cx = w * 0.5, cy = _cy;
      final maxR = math.sqrt(w * w + h * h) * 0.6;
      for (var i = 0; i < n; i++) {
        final ang = hash01(i * 7 + 1) * math.pi * 2;
        final ph = (hash01(i * 3 + 2) + g.time * (1.6 + hash01(i) * 1.2)) % 1.0;
        final r0 = maxR * (0.25 + ph * 0.9);
        final r1 = r0 + maxR * 0.12 * (0.5 + ph);
        final ca = math.cos(ang), sa = math.sin(ang);
        _lineBuf[i * 4] = cx + ca * r0;
        _lineBuf[i * 4 + 1] = cy + sa * r0;
        _lineBuf[i * 4 + 2] = cx + ca * r1;
        _lineBuf[i * 4 + 3] = cy + sa * r1;
      }
      _lines.color = Color.fromRGBO(255, 255, 255, 0.28 * lineK);
      _lines.strokeWidth = math.max(1.5, w / 260);
      canvas.drawRawPoints(ui.PointMode.lines, Float32List.sublistView(_lineBuf, 0, n * 4), _lines);
    }

    // Rain gets heavier as the storm closes in.
    final rainK = clampD(stormK * 1.3, 0, 1);
    if (rainK > 0.05) {
      final n = (quality.rain * rainK).round().clamp(0, 160);
      final len = h * 0.05;
      for (var i = 0; i < n; i++) {
        final x0 = hash01(i * 11 + 5) * (w + 100) - 50;
        final sp = 1.4 + hash01(i * 3) * 0.8;
        final y0 = ((hash01(i * 5 + 1) + g.time * sp) % 1.0) * (h + len) - len;
        final x = x0 - y0 * 0.18;
        _rainBuf[i * 4] = x;
        _rainBuf[i * 4 + 1] = y0;
        _rainBuf[i * 4 + 2] = x - len * 0.18;
        _rainBuf[i * 4 + 3] = y0 + len;
      }
      _rain.color = Color.fromRGBO(200, 215, 255, 0.45 * rainK);
      _rain.strokeWidth = math.max(1.2, w / 400);
      if (n > 0) canvas.drawRawPoints(ui.PointMode.lines, Float32List.sublistView(_rainBuf, 0, n * 4), _rain);
    }

    // Storm wall rising from the bottom of the screen. The path is built in a
    // normalized vertical space so one cached gradient always fits it.
    if (stormK > 0.01) {
      final top = h - h * 0.5 * math.pow(stormK, 1.2);
      final span = h - top + 1;
      _stormPath.reset();
      _stormPath.moveTo(-10, 1.1);
      const k = 14;
      for (var i = 0; i <= k; i++) {
        final x = -10 + (w + 20) * i / k;
        final wave = math.sin(i * 1.7 + g.time * 2.2) * 0.05 + math.sin(i * 0.6 - g.time * 1.3) * 0.06;
        _stormPath.lineTo(x, wave);
      }
      _stormPath.lineTo(w + 10, 1.1);
      _stormPath.close();
      canvas.save();
      canvas.translate(0, top);
      canvas.scale(1, span);
      canvas.drawPath(_stormPath, _storm);
      canvas.restore();
      // General darkening of the scene.
      _flat.color = Color.fromRGBO(10, 6, 24, 0.28 * stormK);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _flat);
    }

    // Lightning.
    if (g.lightning > 0.01) {
      if (g.lightning > 0.55) {
        final seed = (g.time * 0.37).floor();
        var x = w * (0.15 + hash01(seed) * 0.7);
        var y = 0.0;
        _boltPath.reset();
        _boltPath.moveTo(x, y);
        for (var i = 1; i <= 9; i++) {
          y = _cy * i / 9;
          x += (hash01(seed * 13 + i) - 0.5) * w * 0.12;
          _boltPath.lineTo(x, y);
        }
        _bolt.color = Color.fromRGBO(230, 235, 255, g.lightning);
        _bolt.strokeWidth = math.max(2, w / 180);
        canvas.drawPath(_boltPath, _bolt);
      }
      _flat.color = Color.fromRGBO(220, 225, 255, g.lightning * 0.25);
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _flat);
    }

    // Vignette (stronger at night and near the storm).
    final vig = 0.35 + pal.night * 0.25 + stormK * 0.35;
    _vignette.color = Color.fromRGBO(0, 0, 0, clampD(vig, 0, 1));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _vignette);

    if (g.hurt > 0.01) {
      _hurt.color = Color.fromRGBO(0, 0, 0, clampD(g.hurt * 0.8, 0, 1));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _hurt);
    }

    if (g.flash > 0.01) {
      _flat.color = Color.fromRGBO(255, 255, 255, clampD(g.flash * 0.7, 0, 1));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _flat);
    }
  }
}
