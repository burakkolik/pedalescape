import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'bike_painter.dart';
import 'config.dart';
import 'entities.dart';
import 'game.dart';
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

/// Growable-never vertex buffer for colored triangles.
class _Mesh {
  _Mesh(int maxVerts, int maxIdx)
    : pos = Float32List(maxVerts * 2),
      col = Int32List(maxVerts),
      idx = Uint16List(maxIdx);

  final Float32List pos;
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
  void quad4(double x1l, double x1r, double y1, double x2l, double x2r, double y2, int bl, int br, int tr, int tl) {
    if (full) return;
    final b = v;
    final p = v * 2;
    pos[p] = x1l;
    pos[p + 1] = y1;
    pos[p + 2] = x1r;
    pos[p + 3] = y1;
    pos[p + 4] = x2r;
    pos[p + 5] = y2;
    pos[p + 6] = x2l;
    pos[p + 7] = y2;
    col[v] = bl;
    col[v + 1] = br;
    col[v + 2] = tr;
    col[v + 3] = tl;
    v += 4;
    idx[i] = b;
    idx[i + 1] = b + 1;
    idx[i + 2] = b + 2;
    idx[i + 3] = b;
    idx[i + 4] = b + 2;
    idx[i + 5] = b + 3;
    i += 6;
  }

  void draw(Canvas c, Paint p) {
    if (i == 0) return;
    final vs = ui.Vertices.raw(
      ui.VertexMode.triangles,
      Float32List.sublistView(pos, 0, v * 2),
      colors: Int32List.sublistView(col, 0, v),
      indices: Uint16List.sublistView(idx, 0, i),
    );
    c.drawVertices(vs, BlendMode.dst, p);
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
  final Uint8List _valid = Uint8List(_maxSeg + 2);
  // Per segment.
  final Float32List _clip = Float32List(_maxSeg + 2);
  final Uint8List _vis = Uint8List(_maxSeg + 2);

  final _Mesh _road = _Mesh(_maxSeg * 36, _maxSeg * 54);
  final _Mesh _back = _Mesh(800, 1200);
  final _Mesh _fx = _Mesh(64, 96);

  final _Batch _far = _Batch(700);
  final _Batch _near = _Batch(160);
  final _Batch _glow = _Batch(160);
  final _Batch _sky = _Batch(16);
  final _Batch _skyGlow = _Batch(4);
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
  final Float32List _starXY = Float32List(160);
  final Float32List _starBuf = Float32List(160);
  final Float32List _rainBuf = Float32List(4 * 160);
  final Float32List _lineBuf = Float32List(4 * 40);

  // Frame values.
  double _w = 0, _h = 0, _f = 0, _cy = 0;
  int _base = 0;
  int _nSeg = 0;

  // Projection output for objects.
  double _ox = 0, _oy = 0, _os = 0, _oclip = 0, _oz = 0;

  void setSkin(Skin s) => bike.setSkin(s);

  void dispose() {
    _atlas?.dispose();
    _atlas = null;
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
    _ensureShaders(size);
    final atlas = _atlas!;
    _w = size.width;
    _h = size.height;
    final turboAmt = clampD(g.turboT, 0, 1);
    _f = _w * 0.86 * (1 - 0.12 * turboAmt);
    final playerTargetY = _h * 0.84;
    _cy = math.max(_h * 0.22, playerTargetY - K.camHeight / K.playerDist * _w * 0.86);
    _nSeg = math.min(_maxSeg, quality.segments);
    g.smoke.limit = quality.particles;
    g.sparks.limit = quality.particles;

    final cycle = (g.playerZ + 300) / K.dayCycle;
    paletteAt(cycle, pal);

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
    _drawHeadlight(canvas, g);
    _collectSprites(g, atlas);
    _far.draw(canvas, atlas.image, _spritePaint);
    if (quality.glows) _glow.draw(canvas, atlas.image, _additive);
    _drawPlayer(canvas, g, atlas);
    _near.draw(canvas, atlas.image, _spritePaint);
    _drawParticles(canvas, g, atlas);
    canvas.restore();

    _drawOverlays(canvas, g);
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
        _lit[i] = lit;
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

  int _shadePoint(int c, int i) => lerpColor(shadeColor(c, _lit[i]), pal.fog, _fog[i]);

  // -------------------------------------------------------------------- sky

  void _drawSky(Canvas canvas, Game g, SpriteAtlas atlas, double cycle) {
    final m = _back..reset();
    // Sky gradient (two bands for a richer falloff) + haze below horizon.
    final mid = lerpColor(pal.skyTop, pal.skyHorizon, 0.55);
    final skyMidY = _cy * 0.55;
    m.quad(-50, _w + 50, skyMidY, -50, _w + 50, -50, mid, pal.skyTop);
    m.quad(-50, _w + 50, _cy + 2, -50, _w + 50, skyMidY, pal.skyHorizon, mid);
    m.quad(-50, _w + 50, _h + 50, -50, _w + 50, _cy, pal.fog, pal.fog);
    m.draw(canvas, _meshPaint);

    final night = pal.night;
    // Stars.
    if (night > 0.35) {
      final a = (night - 0.35) / 0.65;
      for (var i = 0; i < 80; i++) {
        var x = (_starXY[i * 2] - g.skyOffset * 0.02) % 1.0;
        if (x < 0) x += 1;
        _starBuf[i * 2] = x * _w;
        _starBuf[i * 2 + 1] = _starXY[i * 2 + 1] * _cy * 0.92;
      }
      _stars.color = Color.fromRGBO(255, 255, 255, a * 0.85);
      _stars.strokeWidth = math.max(1.5, _w / 320);
      canvas.drawRawPoints(ui.PointMode.points, _starBuf, _stars);
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
    if (sunH > -0.2) {
      final by = _cy - sunH * _cy * 0.85;
      final r = _w * 0.06;
      _skyGlow.add(atlas, Spr.glow, bx, by, glowS, withAlpha(pal.sun, 0.55));
      _skyGlow.add(atlas, Spr.glow, bx, by, glowS * 0.35, withAlpha(pal.sun, 0.9));
      _skyGlow.draw(canvas, atlas.image, _additive);
      _sun.color = Color(pal.sun);
      canvas.drawCircle(Offset(bx, by), r, _sun);
    }
    if (night > 0.5) {
      final mx = (_w * 0.25 - g.skyOffset * _w * 0.03) % (_w * 1.6);
      final my = _cy * 0.3;
      final a = (night - 0.5) * 2;
      _skyGlow.add(atlas, Spr.glow, mx, my, glowS * 0.5, withAlpha(0xffc8d8ff, 0.35 * a));
      _skyGlow.draw(canvas, atlas.image, _additive);
      _sun.color = Color.fromRGBO(236, 242, 255, a);
      canvas.drawCircle(Offset(mx, my), _w * 0.045, _sun);
      _sun.color = Color.fromRGBO(180, 190, 215, a * 0.6);
      canvas.drawCircle(Offset(mx - _w * 0.012, my - _w * 0.008), _w * 0.011, _sun);
      canvas.drawCircle(Offset(mx + _w * 0.015, my + _w * 0.012), _w * 0.008, _sun);
    }

    // Clouds.
    if (quality.clouds) {
      final p = _w * 2.4;
      final tint = withAlpha(pal.cloud, 0.92 - night * 0.45);
      for (var i = 0; i < 6; i++) {
        final u = hash01(i * 13 + 1);
        final hy = 0.15 + hash01(i * 7 + 3) * 0.55;
        final id = Spr.cloud0 + (i & 1);
        final sc = _w * (0.45 + hash01(i * 5 + 2) * 0.55) / atlas.width(id);
        var x = (u * p - g.skyOffset * _w * 0.08 - g.time * _w * 0.004) % p;
        if (x < 0) x += p;
        x -= _w * 0.4;
        _sky.add(atlas, id, x, _cy * hy, sc, tint);
      }
      _sky.draw(canvas, atlas.image, _spritePaint);
    }
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
  }) {
    final cols = quality.mountainColumns;
    final step = (_w + 40) / cols;
    var prevX = -20.0, prevY = 0.0;
    var prevC = topCol;
    for (var k = 0; k <= cols; k++) {
      final x = -20 + k * step;
      var u = (x + offset) / period;
      u -= u.floorToDouble();
      final fi = u * table.length;
      final i0 = fi.floor() % table.length;
      final i1 = (i0 + 1) % table.length;
      final hn = lerpD(table[i0], table[i1], fi - fi.floorToDouble());
      final y = baseY - hn * height;
      final c = snowCol != 0 && hn > snowFrom
          ? lerpColor(topCol, snowCol, clampD((hn - snowFrom) / (1 - snowFrom) * 1.6, 0, 1))
          : topCol;
      if (k > 0) {
        // Quad from previous column to this one: bottom edge at bottomY.
        if (m.full) return;
        final b = m.v;
        final p = b * 2;
        m.pos[p] = prevX;
        m.pos[p + 1] = bottomY;
        m.pos[p + 2] = x;
        m.pos[p + 3] = bottomY;
        m.pos[p + 4] = x;
        m.pos[p + 5] = y;
        m.pos[p + 6] = prevX;
        m.pos[p + 7] = prevY;
        m.col[b] = botCol;
        m.col[b + 1] = botCol;
        m.col[b + 2] = c;
        m.col[b + 3] = prevC;
        m.v += 4;
        final ii = m.i;
        m.idx[ii] = b;
        m.idx[ii + 1] = b + 1;
        m.idx[ii + 2] = b + 2;
        m.idx[ii + 3] = b;
        m.idx[ii + 4] = b + 2;
        m.idx[ii + 5] = b + 3;
        m.i += 6;
      }
      prevX = x;
      prevY = y;
      prevC = c;
    }
  }

  void _drawMountains(Canvas canvas, Game g) {
    final m = _back..reset();
    final so = g.skyOffset * _w;
    final fogC = pal.fog;
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
    );
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
    );
    m.draw(canvas, _meshPaint);
  }

  // ------------------------------------------------------------------- road

  void _drawRoad(Canvas canvas, Game g) {
    final m = _road..reset();
    final p = pal;
    for (var i = _nSeg; i >= 0; i--) {
      if (_vis[i] == 0) continue;
      final j = i + 1;
      final seg = _base + i;
      final x1 = _sx[i], y1 = _sy[i], s1 = _ss[i];
      final x2 = _sx[j], y2 = _sy[j], s2 = _ss[j];
      final alt3 = (seg ~/ 3) & 1 == 0;
      final alt2 = (seg ~/ 2) & 1 == 0;

      // Grass.
      final gc = alt3 ? p.grassA : p.grassB;
      m.quad(-_w * 0.3, _w * 1.3, y1, -_w * 0.3, _w * 1.3, y2, _shadePoint(gc, i), _shadePoint(gc, j));

      final rw1 = K.roadHalf * s1, rw2 = K.roadHalf * s2;
      final kb1 = (K.roadHalf + K.rumbleW) * s1, kb2 = (K.roadHalf + K.rumbleW) * s2;
      // Gravel shoulder darker band just outside the kerb.
      final sh1 = (K.roadHalf + K.rumbleW + 0.5) * s1, sh2 = (K.roadHalf + K.rumbleW + 0.5) * s2;
      final shoulder = shadeColor(gc, 0.82);
      final shc1 = _shadePoint(shoulder, i), shc2 = _shadePoint(shoulder, j);
      m.quad(x1 - sh1, x1 + sh1, y1, x2 - sh2, x2 + sh2, y2, shc1, shc2);

      // Kerbs.
      final rc = alt2 ? p.rumbleA : p.rumbleB;
      final rc1 = _shadePoint(rc, i), rc2 = _shadePoint(rc, j);
      m.quad(x1 - kb1, x1 - rw1, y1, x2 - kb2, x2 - rw2, y2, rc1, rc2);
      m.quad(x1 + rw1, x1 + kb1, y1, x2 + rw2, x2 + kb2, y2, rc1, rc2);

      // Asphalt.
      final ac = alt3 ? p.roadA : p.roadB;
      m.quad(x1 - rw1, x1 + rw1, y1, x2 - rw2, x2 + rw2, y2, _shadePoint(ac, i), _shadePoint(ac, j));

      // Solid edge lines.
      final lc1 = _shadePoint(p.lane, i), lc2 = _shadePoint(p.lane, j);
      if (s1 * 0.1 > 0.4) {
        const e0 = K.roadHalf - 0.3, e1 = K.roadHalf - 0.18;
        m.quad(x1 - e1 * s1, x1 - e0 * s1, y1, x2 - e1 * s2, x2 - e0 * s2, y2, lc1, lc2);
        m.quad(x1 + e0 * s1, x1 + e1 * s1, y1, x2 + e0 * s2, x2 + e1 * s2, y2, lc1, lc2);
      }
      // Dashed lane separators.
      if (seg % 4 < 2 && s1 * 0.14 > 0.5) {
        const l0 = K.laneW * 0.5 - 0.07, l1 = K.laneW * 0.5 + 0.07;
        m.quad(x1 - l1 * s1, x1 - l0 * s1, y1, x2 - l1 * s2, x2 - l0 * s2, y2, lc1, lc2);
        m.quad(x1 + l0 * s1, x1 + l1 * s1, y1, x2 + l0 * s2, x2 + l1 * s2, y2, lc1, lc2);
      }
    }
    m.draw(canvas, _meshPaint);
  }

  void _drawHeadlight(Canvas canvas, Game g) {
    final night = pal.night;
    if (night < 0.2 || g.phase == Phase.crashing) return;
    final m = _fx..reset();
    if (!_projectZ(g.playerZ + 0.8, g.x, 0, g)) return;
    final nx = _ox, ny = _oy, ns = _os;
    if (!_projectZ(g.playerZ + 30, g.x + g.lean * 2, 0, g)) return;
    final fx = _ox, fy = _oy, fs = _os;
    final a = (night - 0.2) / 0.8;
    final c1 = withAlpha(0xffffe6a8, 0.34 * a);
    const c0 = 0x00ffe6a8;
    // Bright core plus soft fringes on both sides fading to nothing.
    m.quad(nx - 0.35 * ns, nx + 0.35 * ns, ny, fx - 2.2 * fs, fx + 2.2 * fs, fy, c1, c0);
    m.quad4(nx - 0.9 * ns, nx - 0.35 * ns, ny, fx - 4.2 * fs, fx - 2.2 * fs, fy, c0, c1, c0, c0);
    m.quad4(nx + 0.35 * ns, nx + 0.9 * ns, ny, fx + 2.2 * fs, fx + 4.2 * fs, fy, c1, c0, c0, c0);
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
        }
      }

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
          id = h2 < 0.75 ? Spr.pine : (h2 < 0.88 ? Spr.bush : Spr.rock);
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

    // Rear reflector glow at night.
    if (quality.glows && pal.night > 0.3) {
      final rc = withAlpha(0xffff2020, (pal.night - 0.3) * 0.9);
      final rot = g.lean;
      final rx = gx + math.sin(rot) * 0.79 * s;
      final ry = gy - g.jumpY * s - math.cos(rot) * 0.79 * s;
      _glow.add(a, Spr.glow, rx, ry, s * 0.55 / a.metersToSrc[Spr.glow], rc);
      _glow.draw(canvas, a.image, _additive);
    }
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

  void _drawOverlays(Canvas canvas, Game g) {
    final w = _w, h = _h;
    final playing = g.phase != Phase.menu;
    final stormK = playing ? clampD(1 - g.stormGap / 32, 0, 1) : 0.0;

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
