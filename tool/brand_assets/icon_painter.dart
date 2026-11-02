// App icon artwork: a backlit cyclist racing out of a lightning storm in
// front of a huge sunset sun. Designed on a 512x512 canvas; every entry point
// scales from that, so the same art produces the Play Store icon, legacy
// launcher icons and the adaptive-icon layers.

import 'dart:math' as math;
import 'dart:ui';

import 'brand_art.dart';

/// Colour behind the adaptive-icon foreground (values/ic_launcher_background.xml).
const Color adaptiveIconBackground = Brand.coral;

class IconPainter {
  const IconPainter();

  static const double design = 512;
  static const Offset _sun = Offset(268, 300);
  static const double _horizon = 392;

  /// Full-bleed square icon (Play Store 512x512 & legacy launcher base).
  void paintFull(Canvas c, double size) {
    c.save();
    c.scale(size / design);
    c.clipRect(const Rect.fromLTWH(0, 0, design, design));
    _sky(c);
    _storm(c);
    _sunDisc(c, _sun, 158);
    _ground(c);
    _speedLines(c, const Offset(0, 0), 1);
    _figure(c, center: const Offset(262, 0), groundY: 468, width: 388);
    _vignette(c);
    c.restore();
  }

  /// Adaptive-icon foreground: artwork confined to the 66dp safe zone of a
  /// 108dp canvas, transparent elsewhere.
  void paintAdaptiveForeground(Canvas c, double size) {
    c.save();
    c.scale(size / 108);
    // Work in a 108-unit space; safe zone = circle r=33 around (54,54).
    const center = Offset(54, 54);
    final sunPaint = Paint()
      ..shader = Gradient.radial(center + const Offset(0, -2), 31, [
        Brand.sunCore,
        Brand.yellow,
        const Color(0xFFFFA21F),
      ], [0, 0.45, 1]);
    c.drawCircle(center + const Offset(0, -4), 40,
        blurred(fill(withAlpha(Brand.yellow, 0.45)), 6));
    c.drawCircle(center + const Offset(0, -2), 29, sunPaint);
    // Map design-space coordinates (512) into the safe zone.
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(66 / 400);
    c.translate(-256, -256);
    _speedLines(c, const Offset(-14, -36), 0.9, light: true);
    _figure(c, center: const Offset(262, 0), groundY: 430, width: 360);
    c.restore();
    c.restore();
  }

  /// Monochrome layer for Android 13 themed icons (alpha only matters).
  void paintAdaptiveMonochrome(Canvas c, double size) {
    c.save();
    c.scale(size / 108);
    const center = Offset(54, 54);
    c.translate(center.dx, center.dy);
    c.scale(66 / 400);
    c.translate(-256, -256);
    _speedLines(c, const Offset(-14, -36), 0.9, light: true, color: Brand.white);
    final fig = BikeRider();
    _placeFigure(c, center: const Offset(262, 0), groundY: 430, width: 360, draw: () {
      fig.paint(c, RiderLook.mono(Brand.white));
    });
    c.restore();
  }

  /// Legacy launcher icon: rounded square or circle with a soft drop shadow.
  void paintLegacy(Canvas c, double size, {required bool round}) {
    final inset = size * 2 / 48;
    final rect = Rect.fromLTWH(inset, inset, size - inset * 2, size - inset * 2);
    final shape = round ? (Path()..addOval(rect)) : (Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.2))));
    c.drawPath(shape.shift(Offset(0, size * 0.012)), blurred(fill(withAlpha(Brand.navyDeep, 0.45)), size * 0.012));
    c.save();
    c.clipPath(shape);
    c.translate(rect.left, rect.top);
    paintFull(c, rect.width);
    c.restore();
  }

  // --- Layers ----------------------------------------------------------------

  void _sky(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, 0, design, _horizon + 2),
        Paint()
          ..shader = Gradient.linear(const Offset(0, 0), const Offset(0, _horizon), [
            const Color(0xFF1B1247),
            Brand.purple,
            const Color(0xFF8A2D78),
            Brand.coral,
            Brand.orange,
            const Color(0xFFFFB13B),
          ], [0, 0.18, 0.42, 0.62, 0.84, 1]));
    // Few stars top-right.
    final rnd = math.Random(7);
    for (var i = 0; i < 16; i++) {
      final p = Offset(300 + rnd.nextDouble() * 210, 8 + rnd.nextDouble() * 120);
      c.drawCircle(p, 0.8 + rnd.nextDouble() * 1.4, fill(withAlpha(Brand.white, 0.35 + rnd.nextDouble() * 0.5)));
    }
    drawSparkle(c, const Offset(452, 58), 9, alpha: 0.9);
  }

  void _sunDisc(Canvas c, Offset center, double r) {
    c.drawCircle(
        center,
        r * 2.1,
        Paint()
          ..shader = Gradient.radial(center, r * 2.1, [
            withAlpha(Brand.yellow, 0.75),
            withAlpha(Brand.orange, 0.35),
            withAlpha(Brand.coral, 0),
          ], [0.3, 0.6, 1]));
    c.drawCircle(
        center,
        r,
        Paint()
          ..shader = Gradient.linear(center - Offset(0, r), center + Offset(0, r), [
            Brand.sunCore,
            Brand.yellow,
            const Color(0xFFFFA21F),
          ], [0, 0.5, 1]));
    // Retro horizontal cuts in the lower half of the sun.
    for (var i = 0; i < 4; i++) {
      final y = center.dy + r * (0.22 + i * 0.19);
      final h = 3.0 + i * 2.2;
      c.save();
      c.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r + 1)));
      c.drawRect(Rect.fromLTWH(center.dx - r, y, r * 2, h), fill(withAlpha(const Color(0xFFFF6A3A), 0.9)));
      c.restore();
    }
  }

  void _storm(Canvas c) {
    // Dark wash from the top-left corner.
    c.drawRect(
        const Rect.fromLTWH(0, 0, design, design),
        Paint()
          ..shader = Gradient.radial(const Offset(40, 30), 360, [
            withAlpha(Brand.navyDeep, 0.85),
            withAlpha(Brand.navy, 0.5),
            withAlpha(Brand.navy, 0),
          ], [0, 0.45, 1]));
    LightningBolt(const Offset(96, 70), const Offset(52, 300), seed: 11, width: 0.75, branches: 2, jag: 0.28)
        .paint(c);
    drawCloudBank(c,
        puffs: const [
          (Offset(-10, 40), 80),
          (Offset(70, 20), 70),
          (Offset(150, 0), 66),
          (Offset(220, -16), 56),
          (Offset(40, 86), 54),
          (Offset(118, 70), 48),
          (Offset(-20, 130), 50),
        ],
        top: const Color(0xFF3A2A78),
        bottom: const Color(0xFF130D33),
        blur: 1.5,
        rim: withAlpha(Brand.lilac, 0.6));
    // Lightning flash lighting the cloud bottom.
    c.drawCircle(const Offset(96, 80), 60, blurred(fill(withAlpha(Brand.yellow, 0.35)), 28));
  }

  void _ground(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, _horizon, design, design - _horizon),
        Paint()
          ..shader = Gradient.linear(const Offset(0, _horizon), const Offset(0, design), [
            const Color(0xFF2C1A5A),
            Brand.navy,
          ]));
    const vp = Offset(268, _horizon);
    final road = Path()
      ..moveTo(vp.dx - 6, vp.dy)
      ..lineTo(vp.dx + 6, vp.dy)
      ..lineTo(design + 120, design)
      ..lineTo(-120, design)
      ..close();
    c.drawPath(
        road,
        Paint()
          ..shader = Gradient.linear(vp, const Offset(268, design), [
            const Color(0xFF5A3470),
            const Color(0xFF1B1440),
          ]));
    // Sun reflection on the road.
    c.drawOval(Rect.fromCenter(center: const Offset(268, 410), width: 90, height: 40),
        blurred(fill(withAlpha(Brand.orange, 0.55)), 12));
    final edge = blurred(stroke(withAlpha(Brand.orange, 0.95), 4), 1.2);
    c.drawLine(vp, const Offset(-120, design), edge);
    c.drawLine(vp, const Offset(design + 120, design), edge);
    // Centre dashes.
    for (var z = 1.0; z < 14; z *= 1.55) {
      final y0 = _horizon + (design - _horizon) / z;
      final y1 = _horizon + (design - _horizon) / (z * 1.22);
      final w0 = 7 / z, w1 = 7 / (z * 1.22);
      c.drawPath(
          Path()
            ..moveTo(vp.dx - w0, y0)
            ..lineTo(vp.dx + w0, y0)
            ..lineTo(vp.dx + w1, y1)
            ..lineTo(vp.dx - w1, y1)
            ..close(),
          fill(withAlpha(Brand.yellow, 0.85)));
    }
    // Horizon haze.
    c.drawRect(Rect.fromLTWH(0, _horizon - 10, design, 22), blurred(fill(withAlpha(const Color(0xFFFFA24A), 0.45)), 8));
  }

  void _speedLines(Canvas c, Offset shift, double alpha, {bool light = false, Color color = Brand.white}) {
    final lines = <(double y, double x0, double x1, double w)>[
      (190, 6, 104, 7),
      (236, 20, 92, 5),
      (300, 0, 66, 8),
      (344, 14, 70, 5),
      (262, 120, 150, 4),
    ];
    for (final (y, x0, x1, w) in lines) {
      final a = Offset(x0, y) + shift;
      final b = Offset(x1, y) + shift;
      final p = stroke(color, w)
        ..shader = Gradient.linear(a, b, [withAlpha(color, 0), withAlpha(color, (light ? 1.0 : 0.9) * alpha)]);
      c.drawLine(a, b, p);
    }
  }

  void _placeFigure(Canvas c,
      {required Offset center, required double groundY, required double width, required void Function() draw}) {
    final b = BikeRider.bounds;
    final s = width / b.width;
    c.save();
    c.translate(center.dx - b.center.dx * s, groundY - b.bottom * s);
    c.scale(s);
    draw();
    c.restore();
  }

  void _figure(Canvas c, {required Offset center, required double groundY, required double width}) {
    // Ground shadow.
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, groundY - 2), width: width * 0.95, height: 16),
        blurred(fill(withAlpha(Brand.navyDeep, 0.7)), 5));
    final fig = BikeRider(crank: 0.55, wheelPhase: 0.2);
    _placeFigure(c, center: center, groundY: groundY, width: width, draw: () {
      paintLitFigure(c, fig, RiderLook.mono(Brand.navy),
          toLight: const Offset(-0.25, -1), rimColor: const Color(0xFFFFB347), rimWidth: 16);
    });
  }

  void _vignette(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, 0, design, design),
        Paint()
          ..shader = Gradient.radial(const Offset(256, 280), 380, [
            withAlpha(Brand.navy, 0),
            withAlpha(Brand.navy, 0),
            withAlpha(Brand.navyDeep, 0.45),
          ], [0, 0.7, 1]));
  }
}
