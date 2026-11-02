import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Sprite ids inside the generated atlas.
class Spr {
  Spr._();
  static const pine = 0;
  static const oak = 1;
  static const bush = 2;
  static const lampL = 3; // pole on the left, arm reaching right
  static const lampR = 4;
  static const rock = 5;
  static const billboard = 6;
  static const car0 = 7; // 4 colors: 7..10
  static const truck = 11;
  static const barrier = 12;
  static const gate = 13;
  static const cone = 14;
  static const puddle = 15;
  static const coin0 = 16; // 8 frames: 16..23
  static const shield = 24;
  static const magnet = 25;
  static const turbo = 26;
  static const x2 = 27;
  static const glow = 28;
  static const puff = 29;
  static const cloud0 = 30;
  static const cloud1 = 31;
  static const shadow = 32;
  static const flower = 33;
  static const count = 34;
}

class _Def {
  const _Def(this.w, this.h, this.worldW, this.anchorY);
  final double w, h; // base pixel size at quality 1
  final double worldW; // meters
  final double anchorY; // 1 = bottom, 0.5 = center
}

const List<_Def> _defs = [
  _Def(200, 400, 3.4, 1), // pine
  _Def(300, 360, 5.2, 1), // oak
  _Def(200, 120, 2.4, 1), // bush
  _Def(170, 420, 2.8, 1), // lampL
  _Def(170, 420, 2.8, 1), // lampR
  _Def(170, 110, 1.9, 1), // rock
  _Def(380, 300, 6.4, 1), // billboard
  _Def(280, 236, 2.05, 1), // car x4
  _Def(280, 236, 2.05, 1),
  _Def(280, 236, 2.05, 1),
  _Def(280, 236, 2.05, 1),
  _Def(300, 360, 2.6, 1), // truck
  _Def(260, 140, 1.95, 1), // barrier
  _Def(260, 290, 1.95, 1), // gate
  _Def(90, 120, 0.55, 1), // cone
  _Def(260, 90, 1.9, 1), // puddle
  _Def(96, 96, 0.62, 0.5), // coins x8
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(96, 96, 0.62, 0.5),
  _Def(128, 128, 1.0, 0.5), // shield
  _Def(128, 128, 1.0, 0.5), // magnet
  _Def(128, 128, 1.0, 0.5), // turbo
  _Def(128, 128, 1.0, 0.5), // x2
  _Def(64, 64, 1.0, 0.5), // glow
  _Def(64, 64, 1.0, 0.5), // puff
  _Def(512, 190, 1.0, 0.5), // cloud0
  _Def(440, 170, 1.0, 0.5), // cloud1
  _Def(128, 40, 1.0, 0.5), // shadow
  _Def(110, 60, 0.9, 1), // flower patch
];

/// The whole world's art, drawn procedurally once into a single texture so that
/// every frame can render hundreds of sprites with one `drawRawAtlas` call.
class SpriteAtlas {
  SpriteAtlas._(this.image, this.left, this.top, this.right, this.bottom, this.anchorX, this.anchorY, this.metersToSrc);

  final ui.Image image;

  /// Source rects (atlas pixels).
  final List<double> left, top, right, bottom;

  /// Anchor in sprite-local pixels.
  final List<double> anchorX, anchorY;

  /// Atlas pixels per meter for world sprites (srcWidth / worldWidth).
  final List<double> metersToSrc;

  double width(int id) => right[id] - left[id];
  double height(int id) => bottom[id] - top[id];

  void dispose() => image.dispose();

  /// Builds the atlas. [q] scales the texture resolution (0.4 .. 1.0).
  static SpriteAtlas build(double q) {
    const pad = 3.0;
    final maxW = (1024 * q).ceilToDouble();
    final l = List<double>.filled(Spr.count, 0);
    final t = List<double>.filled(Spr.count, 0);
    final r = List<double>.filled(Spr.count, 0);
    final b = List<double>.filled(Spr.count, 0);
    final ax = List<double>.filled(Spr.count, 0);
    final ay = List<double>.filled(Spr.count, 0);
    final m2s = List<double>.filled(Spr.count, 1);

    // Shelf packing, tallest first.
    final order = List<int>.generate(Spr.count, (i) => i)..sort((a, c) => _defs[c].h.compareTo(_defs[a].h));
    var x = pad, y = pad, shelfH = 0.0;
    for (final id in order) {
      final d = _defs[id];
      final w = (d.w * q).ceilToDouble(), h = (d.h * q).ceilToDouble();
      if (x + w + pad > maxW) {
        x = pad;
        y += shelfH + pad;
        shelfH = 0;
      }
      l[id] = x;
      t[id] = y;
      r[id] = x + w;
      b[id] = y + h;
      ax[id] = w * 0.5;
      ay[id] = h * d.anchorY;
      m2s[id] = w / d.worldW;
      x += w + pad;
      if (h > shelfH) shelfH = h;
    }
    final totalH = (y + shelfH + pad).ceil();

    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    for (var id = 0; id < Spr.count; id++) {
      final d = _defs[id];
      c.save();
      c.translate(l[id], t[id]);
      c.clipRect(Rect.fromLTWH(0, 0, r[id] - l[id], b[id] - t[id]));
      c.scale(q);
      _draw(c, id, d.w, d.h);
      c.restore();
    }
    final pic = rec.endRecording();
    final img = pic.toImageSync(maxW.toInt(), totalH);
    pic.dispose();
    return SpriteAtlas._(img, l, t, r, b, ax, ay, m2s);
  }
}

// --------------------------------------------------------------------------
// Procedural art. Everything is drawn in base pixel units (quality 1).

Paint _fill(Color c) => Paint()
  ..color = c
  ..isAntiAlias = true;

List<double>? _evenStops(List<Color> colors, List<double>? stops) {
  if (stops != null || colors.length <= 2) return stops;
  return List<double>.generate(colors.length, (i) => i / (colors.length - 1));
}

Paint _grad(Offset a, Offset b, List<Color> colors, [List<double>? stops]) =>
    Paint()..shader = ui.Gradient.linear(a, b, colors, _evenStops(colors, stops));

Paint _radial(Offset c, double r, List<Color> colors, [List<double>? stops]) =>
    Paint()..shader = ui.Gradient.radial(c, r, colors, _evenStops(colors, stops));

void _shadow(Canvas c, double cx, double cy, double rx, double ry, [double a = 0.35]) {
  c.save();
  c.translate(cx, cy);
  c.scale(1, ry / rx);
  c.drawCircle(Offset.zero, rx, _radial(Offset.zero, rx, [Color.fromRGBO(0, 0, 0, a), const Color(0x00000000)]));
  c.restore();
}

void _draw(Canvas c, int id, double w, double h) {
  switch (id) {
    case Spr.pine:
      _pine(c, w, h);
    case Spr.oak:
      _oak(c, w, h);
    case Spr.bush:
      _bush(c, w, h);
    case Spr.lampL:
      _lamp(c, w, h, false);
    case Spr.lampR:
      _lamp(c, w, h, true);
    case Spr.rock:
      _rock(c, w, h);
    case Spr.billboard:
      _billboard(c, w, h);
    case Spr.truck:
      _truck(c, w, h);
    case Spr.barrier:
      _barrier(c, w, h);
    case Spr.gate:
      _gate(c, w, h);
    case Spr.cone:
      _cone(c, w, h);
    case Spr.puddle:
      _puddle(c, w, h);
    case Spr.shield:
      _orb(c, w, const Color(0xff3fc8ff), _shieldIcon);
    case Spr.magnet:
      _orb(c, w, const Color(0xffff4d6d), _magnetIcon);
    case Spr.turbo:
      _orb(c, w, const Color(0xffff9a1f), _boltIcon);
    case Spr.x2:
      _orb(c, w, const Color(0xffa070ff), _x2Icon);
    case Spr.glow:
      c.drawCircle(
        Offset(w / 2, h / 2),
        w / 2,
        _radial(
          Offset(w / 2, h / 2),
          w / 2,
          const [Color(0xffffffff), Color(0x66ffffff), Color(0x00ffffff)],
          const [0, 0.35, 1],
        ),
      );
    case Spr.puff:
      c.drawCircle(
        Offset(w / 2, h / 2),
        w / 2,
        _radial(
          Offset(w / 2, h / 2),
          w / 2,
          const [Color(0xffffffff), Color(0xaaffffff), Color(0x00ffffff)],
          const [0, 0.5, 1],
        ),
      );
    case Spr.cloud0:
    case Spr.cloud1:
      _cloud(c, w, h, id - Spr.cloud0);
    case Spr.shadow:
      _shadow(c, w / 2, h / 2, w / 2, h / 2, 0.55);
    case Spr.flower:
      _flowers(c, w, h);
    default:
      if (id >= Spr.car0 && id < Spr.car0 + 4) {
        _car(c, w, h, id - Spr.car0);
      } else if (id >= Spr.coin0 && id < Spr.coin0 + 8) {
        _coin(c, w, h, id - Spr.coin0);
      }
  }
}

void _pine(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 10, w * 0.42, 12);
  c.drawRect(
    Rect.fromLTWH(w / 2 - 9, h - 80, 18, 72),
    _grad(Offset(w / 2 - 9, 0), Offset(w / 2 + 9, 0), const [Color(0xff6b4428), Color(0xff3e2615)]),
  );
  const layers = 4;
  for (var i = 0; i < layers; i++) {
    final f = i / (layers - 1);
    final bottom = h - 60 - i * 78.0;
    final top = bottom - 150 + i * 8;
    final half = w * (0.48 - f * 0.26);
    final p = Path()
      ..moveTo(w / 2, top)
      ..quadraticBezierTo(w / 2 - half * 0.5, bottom - 30, w / 2 - half, bottom)
      ..quadraticBezierTo(w / 2, bottom - 18, w / 2 + half, bottom)
      ..quadraticBezierTo(w / 2 + half * 0.5, bottom - 30, w / 2, top)
      ..close();
    c.drawPath(
      p,
      _grad(
        Offset(w / 2 - half, 0),
        Offset(w / 2 + half, 0),
        const [Color(0xff4a9a52), Color(0xff2a6d3a), Color(0xff174a28)],
        const [0, 0.45, 1],
      ),
    );
    // Lower shading band.
    final band = Path()
      ..moveTo(w / 2 - half, bottom)
      ..quadraticBezierTo(w / 2, bottom - 18, w / 2 + half, bottom)
      ..quadraticBezierTo(w / 2, bottom - 40, w / 2 - half, bottom)
      ..close();
    c.drawPath(band, _fill(const Color(0x33000000)));
  }
}

void _oak(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 10, w * 0.4, 14);
  final trunk = Path()
    ..moveTo(w / 2 - 16, h - 8)
    ..lineTo(w / 2 - 10, h - 150)
    ..lineTo(w / 2 - 40, h - 200)
    ..lineTo(w / 2 - 30, h - 206)
    ..lineTo(w / 2, h - 170)
    ..lineTo(w / 2 + 34, h - 210)
    ..lineTo(w / 2 + 42, h - 200)
    ..lineTo(w / 2 + 11, h - 150)
    ..lineTo(w / 2 + 16, h - 8)
    ..close();
  c.drawPath(trunk, _grad(Offset(w / 2 - 16, 0), Offset(w / 2 + 16, 0), const [Color(0xff7a5232), Color(0xff3b2414)]));
  final blobs = <List<double>>[
    [0.5, 0.30, 0.30],
    [0.28, 0.42, 0.22],
    [0.72, 0.42, 0.23],
    [0.38, 0.22, 0.2],
    [0.64, 0.2, 0.2],
    [0.5, 0.48, 0.22],
  ];
  for (final bl in blobs) {
    final cx = bl[0] * w, cy = bl[1] * h, rr = bl[2] * w;
    c.drawCircle(
      Offset(cx, cy),
      rr,
      _radial(
        Offset(cx - rr * 0.35, cy - rr * 0.4),
        rr * 1.4,
        const [Color(0xff8fd06a), Color(0xff3f8f3a), Color(0xff1f5525)],
        const [0, 0.5, 1],
      ),
    );
  }
}

void _bush(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 8, w * 0.46, 10);
  for (final bl in const [
    [0.3, 0.62, 0.22],
    [0.7, 0.62, 0.22],
    [0.5, 0.5, 0.28],
  ]) {
    final cx = bl[0] * w, cy = bl[1] * h, rr = bl[2] * w;
    c.drawCircle(
      Offset(cx, cy),
      rr,
      _radial(
        Offset(cx - rr * 0.3, cy - rr * 0.4),
        rr * 1.3,
        const [Color(0xff9ad66e), Color(0xff3c8a38), Color(0xff1e4f22)],
        const [0, 0.55, 1],
      ),
    );
  }
}

void _flowers(Canvas c, double w, double h) {
  final rnd = math.Random(5);
  for (var i = 0; i < 9; i++) {
    final x = 10 + rnd.nextDouble() * (w - 20), y = h - 6 - rnd.nextDouble() * (h - 26);
    c.drawLine(Offset(x, y), Offset(x, h - 2), _fill(const Color(0xff2f7a2f))..strokeWidth = 3);
    final col = [
      const Color(0xffff6b8a),
      const Color(0xffffe15a),
      const Color(0xffffffff),
      const Color(0xffb07cff),
    ][i % 4];
    c.drawCircle(Offset(x, y), 7, _fill(col));
    c.drawCircle(Offset(x, y), 2.5, _fill(const Color(0xffffb000)));
  }
}

void _lamp(Canvas c, double w, double h, bool right) {
  // Pole stands on the outer side, arm reaches toward the road.
  final px = right ? w - 26 : 26.0;
  final dir = right ? -1.0 : 1.0;
  _shadow(c, px, h - 6, 26, 7);
  c.drawRect(
    Rect.fromLTWH(px - 7, 60, 14, h - 64),
    _grad(Offset(px - 7, 0), Offset(px + 7, 0), const [Color(0xff9aa3ad), Color(0xff4a525b)]),
  );
  c.drawRect(Rect.fromLTWH(px - 11, h - 40, 22, 36), _fill(const Color(0xff3b4148)));
  final arm = Path()
    ..moveTo(px, 70)
    ..quadraticBezierTo(px, 30, px + dir * 50, 30)
    ..lineTo(px + dir * (w - 70), 30);
  c.drawPath(
    arm,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..color = const Color(0xff6b737c),
  );
  final hx = px + dir * (w - 62);
  final head = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset(hx, 34), width: 58, height: 18),
    const Radius.circular(8),
  );
  c.drawRRect(head, _fill(const Color(0xff3b4148)));
  c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(hx, 42), width: 46, height: 8), const Radius.circular(4)),
    _fill(const Color(0xfffff2c0)),
  );
}

void _rock(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 8, w * 0.48, 10);
  final p = Path()
    ..moveTo(12, h - 8)
    ..lineTo(24, h - 60)
    ..lineTo(70, h - 100)
    ..lineTo(118, h - 84)
    ..lineTo(150, h - 46)
    ..lineTo(w - 8, h - 8)
    ..close();
  c.drawPath(
    p,
    _grad(const Offset(30, 0), Offset(w - 10, h), const [Color(0xffb8b4ad), Color(0xff7d7871), Color(0xff4b4742)]),
  );
  final hl = Path()
    ..moveTo(24, h - 60)
    ..lineTo(70, h - 100)
    ..lineTo(90, h - 70)
    ..close();
  c.drawPath(hl, _fill(const Color(0x33ffffff)));
}

void _billboard(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 6, w * 0.45, 10);
  for (final x in [w * 0.28, w * 0.72]) {
    c.drawRect(
      Rect.fromLTWH(x - 8, h * 0.45, 16, h * 0.55 - 4),
      _grad(Offset(x - 8, 0), Offset(x + 8, 0), const [Color(0xff8c949c), Color(0xff4a5158)]),
    );
  }
  final board = RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, w - 16, h * 0.5), const Radius.circular(10));
  c.drawRRect(board, _fill(const Color(0xff1d2230)));
  final inner = RRect.fromRectAndRadius(Rect.fromLTWH(18, 18, w - 36, h * 0.5 - 20), const Radius.circular(6));
  c.drawRRect(
    inner,
    _grad(const Offset(0, 18), Offset(0, h * 0.5), const [Color(0xffff8a3d), Color(0xffff3d6e), Color(0xff8a3dff)]),
  );
  final tp = TextPainter(
    text: const TextSpan(
      children: [
        TextSpan(
          text: 'PEDAL\n',
          style: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w900,
            color: Color(0xffffffff),
            height: 1.0,
            letterSpacing: 4,
          ),
        ),
        TextSpan(
          text: 'ESCAPE',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Color(0xffffe9a8),
            height: 1.0,
            letterSpacing: 6,
          ),
        ),
      ],
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: w - 40);
  tp.paint(c, Offset((w - tp.width) / 2, 18 + (h * 0.5 - 20 - tp.height) / 2));
  tp.dispose();
  c.drawRRect(
    inner,
    Paint()
      ..shader = ui.Gradient.linear(const Offset(0, 18), Offset(w * 0.6, h * 0.5), const [
        Color(0x44ffffff),
        Color(0x00ffffff),
      ]),
  );
}

const List<Color> _carColors = [Color(0xffe63946), Color(0xff2f6fdf), Color(0xfff2b632), Color(0xffeef0f2)];

void _car(Canvas c, double w, double h, int v) {
  final body = _carColors[v];
  final dark = Color.lerp(body, const Color(0xff000000), 0.45)!;
  final light = Color.lerp(body, const Color(0xffffffff), 0.35)!;
  _shadow(c, w / 2, h - 14, w * 0.5, 18, 0.5);
  // Tires.
  for (final x in [28.0, w - 28 - 34]) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, h - 58, 34, 50), const Radius.circular(8)),
      _fill(const Color(0xff16171a)),
    );
  }
  // Lower body.
  final lower = RRect.fromRectAndCorners(
    Rect.fromLTWH(14, 96, w - 28, h - 150),
    topLeft: const Radius.circular(26),
    topRight: const Radius.circular(26),
    bottomLeft: const Radius.circular(14),
    bottomRight: const Radius.circular(14),
  );
  c.drawRRect(lower, _grad(const Offset(0, 96), Offset(0, h - 50), [light, body, dark], const [0, 0.35, 1]));
  // Cabin.
  final cabin = Path()
    ..moveTo(44, 104)
    ..lineTo(66, 26)
    ..quadraticBezierTo(w / 2, 14, w - 66, 26)
    ..lineTo(w - 44, 104)
    ..close();
  c.drawPath(cabin, _grad(const Offset(0, 20), const Offset(0, 104), [light, body]));
  // Rear window.
  final glass = Path()
    ..moveTo(60, 96)
    ..lineTo(76, 38)
    ..quadraticBezierTo(w / 2, 28, w - 76, 38)
    ..lineTo(w - 60, 96)
    ..close();
  c.drawPath(
    glass,
    _grad(
      const Offset(0, 30),
      const Offset(0, 96),
      const [Color(0xff9fc4e0), Color(0xff2a3a4f), Color(0xff121a26)],
      const [0, 0.4, 1],
    ),
  );
  final refl = Path()
    ..moveTo(84, 92)
    ..lineTo(100, 40)
    ..lineTo(124, 40)
    ..lineTo(108, 92)
    ..close();
  c.drawPath(refl, _fill(const Color(0x30ffffff)));
  // Tail lights.
  for (final x in [24.0, w - 24 - 52]) {
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, 112, 52, 22), const Radius.circular(6));
    c.drawRRect(r, _grad(Offset(0, 112), Offset(0, 134), const [Color(0xffff6b6b), Color(0xffc0101a)]));
    c.drawRRect(r.deflate(5), _fill(const Color(0x55ffffff)));
  }
  // Trunk line and plate.
  c.drawLine(
    Offset(40, 108),
    Offset(w - 40, 108),
    Paint()
      ..color = dark
      ..strokeWidth = 3,
  );
  c.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w / 2, 150), width: 76, height: 24),
      const Radius.circular(4),
    ),
    _fill(const Color(0xfff4f4f0)),
  );
  c.drawRect(Rect.fromCenter(center: Offset(w / 2 - 30, 150), width: 10, height: 20), _fill(const Color(0xff2a52be)));
  for (var i = 0; i < 5; i++) {
    c.drawRect(Rect.fromLTWH(w / 2 - 18 + i * 9, 144, 6, 12), _fill(const Color(0xff222222)));
  }
  // Bumper.
  c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(18, h - 72, w - 36, 22), const Radius.circular(10)),
    _grad(Offset(0, h - 72), Offset(0, h - 50), const [Color(0xff3b3e45), Color(0xff15161a)]),
  );
  // Roof highlight.
  c.drawLine(
    const Offset(80, 24),
    Offset(w - 80, 24),
    Paint()
      ..color = const Color(0x55ffffff)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round,
  );
}

void _truck(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 14, w * 0.52, 20, 0.55);
  for (final x in [24.0, 64.0, w - 24 - 34, w - 64 - 34]) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, h - 60, 34, 52), const Radius.circular(8)),
      _fill(const Color(0xff141518)),
    );
  }
  final box = RRect.fromRectAndRadius(Rect.fromLTWH(8, 8, w - 16, h - 82), const Radius.circular(8));
  c.drawRRect(
    box,
    _grad(
      const Offset(8, 0),
      Offset(w - 8, 0),
      const [Color(0xffd9dde2), Color(0xfff6f7f9), Color(0xffa9b0b8)],
      const [0, 0.4, 1],
    ),
  );
  // Doors.
  c.drawLine(
    Offset(w / 2, 14),
    Offset(w / 2, h - 80),
    Paint()
      ..color = const Color(0xff8a9199)
      ..strokeWidth = 4,
  );
  for (final x in [w * 0.27, w * 0.73]) {
    c.drawLine(
      Offset(x, 20),
      Offset(x, h - 92),
      Paint()
        ..color = const Color(0xff9aa1a9)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }
  // Stripe.
  c.drawRect(Rect.fromLTWH(8, h * 0.42, w - 16, 26), _fill(const Color(0xffff6b2b)));
  c.drawRect(Rect.fromLTWH(8, h * 0.42 + 26, w - 16, 8), _fill(const Color(0xff2a3a80)));
  // Bottom frame + lights.
  c.drawRect(Rect.fromLTWH(10, h - 84, w - 20, 18), _fill(const Color(0xff2a2c31)));
  for (final x in [16.0, w - 16 - 40]) {
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, h - 82, 40, 14), const Radius.circular(4)),
      _fill(const Color(0xffe01a24)),
    );
  }
  // Mud flaps.
  for (final x in [20.0, w - 20 - 46]) {
    c.drawRect(Rect.fromLTWH(x, h - 66, 46, 44), _fill(const Color(0xff1d1e22)));
  }
  // Dirt gradient.
  c.drawRRect(box, _grad(Offset(0, h * 0.6), Offset(0, h - 74), const [Color(0x00000000), Color(0x44503820)]));
}

void _stripes(Canvas c, Rect r, Color a, Color b, double step) {
  c.save();
  c.clipRRect(RRect.fromRectAndRadius(r, const Radius.circular(6)));
  c.drawRect(r, _fill(a));
  final p = Paint()..color = b;
  for (var x = r.left - r.height; x < r.right + r.height; x += step * 2) {
    final path = Path()
      ..moveTo(x, r.bottom)
      ..lineTo(x + step, r.bottom)
      ..lineTo(x + step + r.height, r.top)
      ..lineTo(x + r.height, r.top)
      ..close();
    c.drawPath(path, p);
  }
  c.drawRect(
    r,
    _grad(
      Offset(0, r.top),
      Offset(0, r.bottom),
      const [Color(0x55ffffff), Color(0x00ffffff), Color(0x44000000)],
      const [0, 0.4, 1],
    ),
  );
  c.restore();
}

void _barrier(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 8, w * 0.5, 10, 0.45);
  for (final x in [30.0, w - 30]) {
    final leg = Path()
      ..moveTo(x - 18, h - 6)
      ..lineTo(x - 4, 50)
      ..lineTo(x + 4, 50)
      ..lineTo(x + 18, h - 6)
      ..close();
    c.drawPath(leg, _fill(const Color(0xff2d3036)));
  }
  _stripes(c, Rect.fromLTWH(6, 34, w - 12, 50), const Color(0xfff4f4f4), const Color(0xffe02828), 22);
  // Warning lamps.
  for (final x in [34.0, w - 34]) {
    c.drawRect(Rect.fromLTWH(x - 4, 16, 8, 20), _fill(const Color(0xff2d3036)));
    c.drawCircle(Offset(x, 14), 11, _radial(Offset(x - 3, 11), 12, const [Color(0xffffffb0), Color(0xffffb300)]));
  }
}

void _gate(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 8, w * 0.5, 10, 0.4);
  for (final x in [14.0, w - 14]) {
    c.drawRect(
      Rect.fromLTWH(x - 7, 40, 14, h - 46),
      _grad(Offset(x - 7, 0), Offset(x + 7, 0), const [Color(0xffb0b6bd), Color(0xff5a6168)]),
    );
    c.drawRect(Rect.fromLTWH(x - 12, h - 18, 24, 14), _fill(const Color(0xff3a3f45)));
  }
  _stripes(c, Rect.fromLTWH(2, 46, w - 4, 44), const Color(0xffffc61a), const Color(0xff1d1d1f), 20);
  // Hanging chains/flags so the gap reads clearly.
  for (var i = 0; i < 6; i++) {
    final x = 34 + i * (w - 68) / 5;
    c.drawLine(
      Offset(x, 90),
      Offset(x, 112),
      Paint()
        ..color = const Color(0xff444444)
        ..strokeWidth = 2,
    );
    final flag = Path()
      ..moveTo(x - 9, 110)
      ..lineTo(x + 9, 110)
      ..lineTo(x, 128)
      ..close();
    c.drawPath(flag, _fill(i.isEven ? const Color(0xffff3b30) : const Color(0xffffffff)));
  }
}

void _cone(Canvas c, double w, double h) {
  _shadow(c, w / 2, h - 8, w * 0.5, 8, 0.4);
  c.drawRRect(
    RRect.fromRectAndRadius(Rect.fromLTWH(4, h - 18, w - 8, 12), const Radius.circular(3)),
    _fill(const Color(0xffd94a12)),
  );
  final p = Path()
    ..moveTo(w / 2 - 6, 6)
    ..lineTo(w / 2 + 6, 6)
    ..lineTo(w - 14, h - 16)
    ..lineTo(14, h - 16)
    ..close();
  c.drawPath(
    p,
    _grad(
      const Offset(14, 0),
      Offset(w - 14, 0),
      const [Color(0xffffa04a), Color(0xffff6a1a), Color(0xffc2410c)],
      const [0, 0.4, 1],
    ),
  );
  for (final y in [h * 0.32, h * 0.58]) {
    final t = (y - 6) / (h - 22);
    final hw = 6 + t * (w / 2 - 20);
    c.drawRect(Rect.fromLTRB(w / 2 - hw, y, w / 2 + hw, y + 11), _fill(const Color(0xfff2f2f2)));
  }
}

void _puddle(Canvas c, double w, double h) {
  c.save();
  c.translate(w / 2, h / 2);
  c.scale(1, (h * 0.42) / (w * 0.48));
  c.drawCircle(
    Offset.zero,
    w * 0.48,
    _radial(
      const Offset(-20, -20),
      w * 0.55,
      const [Color(0xddbfe8ff), Color(0xcc4a8fc4), Color(0x99284a6e), Color(0x00284a6e)],
      const [0, 0.45, 0.85, 1],
    ),
  );
  c.drawCircle(const Offset(-30, -10), w * 0.12, _fill(const Color(0x55ffffff)));
  c.restore();
}

void _coin(Canvas c, double w, double h, int frame) {
  final a = frame / 8 * math.pi; // half turn is enough (symmetric)
  final sx = math.cos(a).abs() * 0.92 + 0.08;
  final edge = math.sin(a).abs();
  final r = w * 0.44;
  c.save();
  c.translate(w / 2, h / 2);
  // Edge thickness (gives a 3D feel when turning).
  if (edge > 0.05) {
    c.save();
    c.translate(edge * 6 * (math.cos(a) >= 0 ? 1 : -1), 0);
    c.scale(sx, 1);
    c.drawCircle(Offset.zero, r, _fill(const Color(0xffa86b00)));
    c.restore();
  }
  c.scale(sx, 1);
  c.drawCircle(
    Offset.zero,
    r,
    _radial(
      Offset(-r * 0.3, -r * 0.4),
      r * 1.6,
      const [Color(0xfffff4a8), Color(0xffffc62a), Color(0xffcf8a00)],
      const [0, 0.5, 1],
    ),
  );
  c.drawCircle(
    Offset.zero,
    r * 0.74,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1
      ..color = const Color(0xffe39b00),
  );
  // Star emboss.
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final rr = i.isEven ? r * 0.46 : r * 0.2;
    final ang = -math.pi / 2 + i * math.pi / 5;
    final p = Offset(math.cos(ang) * rr, math.sin(ang) * rr);
    if (i == 0) {
      star.moveTo(p.dx, p.dy);
    } else {
      star.lineTo(p.dx, p.dy);
    }
  }
  star.close();
  c.drawPath(star, _fill(const Color(0xfffff0b0)));
  c.restore();
}

void _orb(Canvas c, double w, Color col, void Function(Canvas, double) icon) {
  final cx = w / 2, r = w * 0.44;
  c.drawCircle(
    Offset(cx, cx),
    r + 8,
    _radial(Offset(cx, cx), r + 8, [col.withValues(alpha: 0.55), col.withValues(alpha: 0)]),
  );
  c.drawCircle(
    Offset(cx, cx),
    r,
    _radial(
      Offset(cx - r * 0.35, cx - r * 0.4),
      r * 1.5,
      [Color.lerp(col, const Color(0xffffffff), 0.7)!, col, Color.lerp(col, const Color(0xff000000), 0.45)!],
      const [0, 0.45, 1],
    ),
  );
  c.drawCircle(
    Offset(cx, cx),
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xccffffff),
  );
  c.save();
  c.translate(cx, cx);
  icon(c, r);
  c.restore();
  // Specular.
  c.drawOval(
    Rect.fromCenter(center: Offset(cx - r * 0.3, cx - r * 0.5), width: r * 0.8, height: r * 0.35),
    _fill(const Color(0x66ffffff)),
  );
}

final Paint _iconPaint = Paint()..color = const Color(0xffffffff);

void _shieldIcon(Canvas c, double r) {
  final p = Path()
    ..moveTo(0, -r * 0.6)
    ..lineTo(r * 0.5, -r * 0.4)
    ..quadraticBezierTo(r * 0.5, r * 0.3, 0, r * 0.62)
    ..quadraticBezierTo(-r * 0.5, r * 0.3, -r * 0.5, -r * 0.4)
    ..close();
  c.drawPath(p, _iconPaint);
}

void _magnetIcon(Canvas c, double r) {
  final p = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.26
    ..color = const Color(0xffffffff);
  c.drawArc(Rect.fromCircle(center: Offset(0, -r * 0.02), radius: r * 0.36), 0, math.pi, false, p);
  c.drawLine(Offset(-r * 0.36, 0), Offset(-r * 0.36, -r * 0.42), p);
  c.drawLine(Offset(r * 0.36, 0), Offset(r * 0.36, -r * 0.42), p);
  c.drawRect(Rect.fromLTWH(-r * 0.5, -r * 0.56, r * 0.28, r * 0.16), _fill(const Color(0xff333333)));
  c.drawRect(Rect.fromLTWH(r * 0.22, -r * 0.56, r * 0.28, r * 0.16), _fill(const Color(0xff333333)));
}

void _boltIcon(Canvas c, double r) {
  final p = Path()
    ..moveTo(r * 0.12, -r * 0.66)
    ..lineTo(-r * 0.38, r * 0.08)
    ..lineTo(-r * 0.02, r * 0.08)
    ..lineTo(-r * 0.14, r * 0.66)
    ..lineTo(r * 0.4, -r * 0.12)
    ..lineTo(r * 0.04, -r * 0.12)
    ..close();
  c.drawPath(p, _iconPaint);
}

void _x2Icon(Canvas c, double r) {
  final tp = TextPainter(
    text: TextSpan(
      text: 'x2',
      style: TextStyle(fontSize: r * 0.95, fontWeight: FontWeight.w900, color: const Color(0xffffffff)),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  tp.dispose();
}

void _cloud(Canvas c, double w, double h, int v) {
  final rnd = math.Random(11 + v);
  final n = 7 + v * 2;
  for (var i = 0; i < n; i++) {
    final t = i / (n - 1);
    final cx = w * (0.15 + 0.7 * t) + (rnd.nextDouble() - 0.5) * 30;
    final rr = h * (0.22 + 0.2 * math.sin(t * math.pi)) + rnd.nextDouble() * 14;
    final cy = h * 0.62 - rr * 0.5 + rnd.nextDouble() * 10;
    c.drawCircle(
      Offset(cx, cy),
      rr,
      _radial(
        Offset(cx, cy - rr * 0.3),
        rr,
        const [Color(0xffffffff), Color(0xf0f4f7fb), Color(0x00e6ecf3)],
        const [0, 0.7, 1],
      ),
    );
  }
}
