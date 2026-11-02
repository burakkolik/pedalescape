// Google Play feature graphic (1024x500): a cyclist escaping a lightning
// storm on a road that vanishes into a sunset, with the localized title and
// tagline. For right-to-left locales the whole scene is mirrored so the text
// sits on the reading-start side and the rider still flees the storm.

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show Canvas, Color, Offset, Paint, PaintingStyle, Path, Rect, RRect, Radius, Shadow;

import 'brand_art.dart';
import 'font_registry.dart';

class FeatureText {
  const FeatureText({required this.locale, required this.title, required this.tagline});

  final String locale;
  final String title;
  final String tagline;

  static const _rtl = {'ar', 'fa', 'he', 'ur'};

  ui.TextDirection get direction => _rtl.contains(locale) ? ui.TextDirection.rtl : ui.TextDirection.ltr;
  bool get isRtl => direction == ui.TextDirection.rtl;

  /// Scripts where an italic Latin face is appropriate.
  bool get _latinScript => !{'ar', 'hi', 'ja', 'ko', 'zh', 'fa', 'he', 'ur'}.contains(locale);

  String get titleFamily => switch (locale) {
        'ar' => BrandFonts.arabic,
        'hi' => BrandFonts.devanagari,
        'ja' => BrandFonts.cjkJp,
        'ko' => BrandFonts.cjkKr,
        'zh' => BrandFonts.cjkTc,
        _ => BrandFonts.latinItalic,
      };

  String get bodyFamily => _latinScript ? BrandFonts.latin : titleFamily;

  List<String> get fallback => [
        BrandFonts.latin,
        BrandFonts.arabic,
        BrandFonts.devanagari,
        if (locale == 'ko') BrandFonts.cjkKr,
        if (locale == 'zh') BrandFonts.cjkTc,
        BrandFonts.cjkJp,
        BrandFonts.cjkKr,
        BrandFonts.cjkTc,
      ];

  /// Line-height multiplier: scripts with tall marks need more room.
  double get lineHeight => switch (locale) {
        'ar' || 'hi' => 1.22,
        'ja' || 'ko' || 'zh' => 1.12,
        _ => 1.04,
      };
}

class FeatureGraphicPainter {
  FeatureGraphicPainter(this.text);

  final FeatureText text;

  static const double width = 1024;
  static const double height = 500;
  static const double margin = 40;

  static const double _horizon = 292;
  static const Offset _vp = Offset(600, _horizon);
  static const double _roadHalf = 660; // half road width at the bottom edge

  void paint(Canvas c) {
    c.save();
    c.clipRect(const Rect.fromLTWH(0, 0, width, height));
    c.save();
    if (text.isRtl) {
      c.translate(width, 0);
      c.scale(-1, 1);
    }
    _sky(c);
    _sun(c);
    _storm(c);
    _mountains(c);
    _city(c);
    _ground(c);
    _road(c);
    _roadside(c);
    _coins(c);
    _motionStreaks(c);
    _rider(c);
    _foregroundSparkles(c);
    _vignette(c);
    c.restore();
    _grain(c);
    _texts(c);
    c.restore();
  }

  // --- Perspective -----------------------------------------------------------

  /// Screen point on the road for lateral position [lane] (-1..1 = road
  /// edges) at depth [z] (1 = bottom edge of the image, larger = farther).
  Offset road(double lane, double z, {double lift = 0}) =>
      Offset(_vp.dx + lane * _roadHalf / z, _horizon + (height - _horizon) / z - lift / z);

  // --- Background ------------------------------------------------------------

  void _sky(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, 0, width, _horizon + 4),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, _horizon), [
            const Color(0xFF140E38),
            Brand.purple,
            const Color(0xFF6B2A7A),
            const Color(0xFFD9416F),
            Brand.orange,
            const Color(0xFFFFB347),
          ], [0, 0.22, 0.48, 0.7, 0.88, 1]));
    // Stars on the clear (right) side.
    final rnd = math.Random(42);
    for (var i = 0; i < 90; i++) {
      final p = Offset(560 + rnd.nextDouble() * 470, rnd.nextDouble() * 150);
      final a = (0.2 + rnd.nextDouble() * 0.7) * (1 - p.dy / 170);
      c.drawCircle(p, 0.5 + rnd.nextDouble() * 1.3, ui.Paint()..color = withAlpha(Brand.white, a));
    }
    drawSparkle(c, const Offset(905, 52), 8, alpha: 0.9);
    drawSparkle(c, const Offset(780, 96), 5, alpha: 0.7);
  }

  void _sun(Canvas c) {
    const center = Offset(600, 282);
    const r = 96.0;
    c.drawCircle(
        center,
        520,
        Paint()
          ..shader = ui.Gradient.radial(center, 520, [
            withAlpha(const Color(0xFFFFC14A), 0.7),
            withAlpha(Brand.orange, 0.35),
            withAlpha(Brand.coral, 0.12),
            withAlpha(Brand.coral, 0),
          ], [0.12, 0.3, 0.6, 1]));
    c.drawCircle(center, r * 1.35, blurred(fill(withAlpha(Brand.yellow, 0.6)), 18));
    c.drawCircle(
        center,
        r,
        Paint()
          ..shader = ui.Gradient.linear(center - const Offset(0, r), center + const Offset(0, r), [
            Brand.sunCore,
            Brand.yellow,
            const Color(0xFFFF9A2A),
          ], [0.05, 0.5, 1]));
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r + 1)));
    for (var i = 0; i < 4; i++) {
      final y = center.dy + r * (0.2 + i * 0.17);
      c.drawRect(Rect.fromLTWH(center.dx - r, y, r * 2, 2.5 + i * 2.2), fill(withAlpha(const Color(0xFFFF6A3A), 0.85)));
    }
    c.restore();
  }

  void _storm(Canvas c) {
    // Darken the storm side of the sky.
    c.drawRect(
        const Rect.fromLTWH(0, 0, width, _horizon + 4),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(760, 0), [
            withAlpha(Brand.navyDeep, 0.92),
            withAlpha(Brand.navy, 0.7),
            withAlpha(Brand.navy, 0),
          ], [0, 0.5, 1]));
    // Rain shafts.
    final rnd = math.Random(5);
    final rain = ui.Paint()
      ..strokeWidth = 1.2
      ..strokeCap = ui.StrokeCap.round;
    for (var i = 0; i < 160; i++) {
      final x = rnd.nextDouble() * 560;
      final y = 120 + rnd.nextDouble() * 170;
      final len = 14 + rnd.nextDouble() * 26;
      rain.color = withAlpha(Brand.lilac, 0.08 + rnd.nextDouble() * 0.16 * (1 - x / 600));
      c.drawLine(Offset(x, y), Offset(x - len * 0.32, y + len), rain);
    }
    // Back cloud layer (soft).
    drawCloudBank(c,
        puffs: const [
          (Offset(40, 190), 70),
          (Offset(150, 205), 60),
          (Offset(270, 215), 52),
          (Offset(380, 225), 40),
          (Offset(470, 232), 30),
        ],
        top: const Color(0xFF34236E),
        bottom: withAlpha(const Color(0xFF1A1244), 0.0),
        blur: 10);
    // Lightning bolts behind the main bank.
    LightningBolt(const Offset(468, 120), const Offset(418, 286), seed: 3, width: 1.0, branches: 2, jag: 0.26)
        .paint(c);
    LightningBolt(const Offset(96, 150), const Offset(132, 280), seed: 9, width: 0.6, branches: 1, jag: 0.3)
        .paint(c, intensity: 0.8);
    // Flash glow where the main bolt leaves the cloud.
    c.drawCircle(const Offset(470, 118), 120, blurred(fill(withAlpha(Brand.lilac, 0.35)), 50));
    c.drawCircle(const Offset(470, 118), 46, blurred(fill(withAlpha(Brand.yellow, 0.35)), 22));
    // Main storm bank across the top.
    drawCloudBank(c,
        puffs: const [
          (Offset(-30, 30), 110),
          (Offset(90, -10), 100),
          (Offset(210, 10), 96),
          (Offset(330, -20), 100),
          (Offset(450, 20), 86),
          (Offset(560, -10), 74),
          (Offset(660, -30), 58),
          (Offset(40, 110), 74),
          (Offset(170, 110), 66),
          (Offset(300, 96), 62),
          (Offset(420, 104), 52),
          (Offset(520, 70), 46),
          (Offset(-10, 170), 56),
        ],
        top: const Color(0xFF2E2066),
        bottom: const Color(0xFF110B30),
        blur: 2.5,
        rim: withAlpha(Brand.lilac, 0.55));
    // Underside lit by the flash.
    c.drawOval(Rect.fromCenter(center: const Offset(450, 140), width: 240, height: 60),
        blurred(fill(withAlpha(Brand.lilac, 0.32)), 22));
    // Cloud-to-cloud crawler.
    LightningBolt(const Offset(560, 40), const Offset(720, 18), seed: 21, width: 0.45, branches: 1, jag: 0.35)
        .paint(c, intensity: 0.7);
  }

  void _mountains(Canvas c) {
    double valley(double x) {
      final d = ((x - _vp.dx).abs() / 260).clamp(0.0, 1.0);
      return 0.25 + 0.75 * d * d * (3 - 2 * d);
    }

    void layer(int seed, double amp, double base, List<Color> colors, {double sharp = 1}) {
      final pts = ridge(x0: -10, x1: width + 10, baseY: base, amp: amp, seed: seed, sharp: sharp);
      final path = Path()..moveTo(-10, _horizon + 6);
      for (final p in pts) {
        final h = (base - p.dy) * valley(p.dx);
        path.lineTo(p.dx, base - h);
      }
      path
        ..lineTo(width + 10, _horizon + 6)
        ..close();
      c.drawPath(
          path,
          Paint()
            ..shader = ui.Gradient.linear(Offset(0, base - amp), const Offset(0, _horizon), colors));
    }

    layer(4, 110, _horizon, [const Color(0xFF8C3F86), const Color(0xFFD1587A)], sharp: 0.8);
    // Haze between layers.
    c.drawRect(const Rect.fromLTWH(0, _horizon - 40, width, 44),
        blurred(fill(withAlpha(const Color(0xFFFF8A5A), 0.28)), 16));
    layer(17, 70, _horizon + 2, [const Color(0xFF4A2A78), const Color(0xFF2E1B5A)]);
  }

  void _city(Canvas c) {
    final rnd = math.Random(77);
    var x = 690.0;
    final windows = Paint();
    while (x < 1030) {
      final w = 14 + rnd.nextDouble() * 22;
      final h = 14 + rnd.nextDouble() * 46 * (1 - (x - 690) / 600);
      final r = Rect.fromLTWH(x, _horizon - h, w, h + 2);
      c.drawRect(r, fill(const Color(0xFF231650)));
      if (rnd.nextDouble() < 0.3) {
        c.drawLine(Offset(x + w / 2, _horizon - h), Offset(x + w / 2, _horizon - h - 10),
            stroke(const Color(0xFF231650), 1.5));
        c.drawCircle(Offset(x + w / 2, _horizon - h - 10), 1.6, fill(Brand.coral));
      }
      for (var wy = _horizon - h + 4; wy < _horizon - 3; wy += 6) {
        for (var wx = x + 3; wx < x + w - 3; wx += 5) {
          if (rnd.nextDouble() < 0.32) {
            windows.color = withAlpha(rnd.nextBool() ? Brand.yellow : Brand.orange, 0.5 + rnd.nextDouble() * 0.4);
            c.drawRect(Rect.fromLTWH(wx, wy, 1.8, 2.2), windows);
          }
        }
      }
      x += w + 1 + rnd.nextDouble() * 6;
    }
    // Left-side small skyline (storm side, darker).
    x = 200;
    while (x < 470) {
      final w = 12 + rnd.nextDouble() * 16;
      final h = 8 + rnd.nextDouble() * 24;
      c.drawRect(Rect.fromLTWH(x, _horizon - h, w, h + 2), fill(const Color(0xFF1E1446)));
      x += w + 2 + rnd.nextDouble() * 10;
    }
  }

  void _ground(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, _horizon, width, height - _horizon),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, _horizon), const Offset(0, height), [
            const Color(0xFF2A1A57),
            const Color(0xFF150F38),
            Brand.navy,
          ], [0, 0.35, 1]));
    // Sunset light spilling over the ground near the horizon.
    c.drawOval(Rect.fromCenter(center: const Offset(640, _horizon + 6), width: 900, height: 40),
        blurred(fill(withAlpha(Brand.orange, 0.28)), 14));
  }

  void _road(Canvas c) {
    final l0 = road(-1, 1), r0 = road(1, 1);
    final path = Path()
      ..moveTo(_vp.dx - 1, _horizon)
      ..lineTo(_vp.dx + 1, _horizon)
      ..lineTo(r0.dx, r0.dy)
      ..lineTo(l0.dx, l0.dy)
      ..close();
    c.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(_vp, const Offset(600, height), [
            const Color(0xFF6A3A72),
            const Color(0xFF2E2056),
            const Color(0xFF1A1438),
          ], [0, 0.3, 1]));
    // Wet-road sun reflection.
    c.save();
    c.clipPath(path);
    c.drawPath(
        Path()
          ..moveTo(_vp.dx - 8, _horizon)
          ..lineTo(_vp.dx + 8, _horizon)
          ..lineTo(_vp.dx + 120, height)
          ..lineTo(_vp.dx - 120, height)
          ..close(),
        Paint()
          ..shader = ui.Gradient.linear(_vp, const Offset(600, height), [
            withAlpha(const Color(0xFFFFB347), 0.75),
            withAlpha(Brand.orange, 0.22),
            withAlpha(Brand.coral, 0.0),
          ], [0, 0.4, 1])
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10));
    // Lane dashes.
    for (final lane in [-1 / 3, 1 / 3]) {
      for (var z = 1.0; z < 40; z *= 1.32) {
        final z1 = z * 1.14;
        final w0 = 6.0 / z, w1 = 6.0 / z1;
        final a = road(lane, z), b = road(lane, z1);
        final fade = (1 - 1 / (z * 0.9)).clamp(0.0, 1.0) * 0.2 + 0.7;
        c.drawPath(
            Path()
              ..moveTo(a.dx - w0, a.dy)
              ..lineTo(a.dx + w0, a.dy)
              ..lineTo(b.dx + w1, b.dy)
              ..lineTo(b.dx - w1, b.dy)
              ..close(),
            fill(withAlpha(const Color(0xFFF4ECFF), fade)));
      }
    }
    c.restore();
    // Glowing road edges.
    for (final lane in [-1.0, 1.0]) {
      final a = road(lane, 1);
      c.drawLine(_vp, a, blurred(stroke(withAlpha(Brand.orange, 0.6), 10), 6));
      c.drawLine(_vp, a, stroke(const Color(0xFFFFB347), 3));
    }
  }

  void _roadside(Canvas c) {
    // Light posts receding to the horizon on both sides.
    for (final side in [-1.0, 1.0]) {
      for (var z = 1.05; z < 26; z *= 1.45) {
        final base = road(side * 1.18, z);
        final h = 200 / z;
        final w = 7 / z;
        final top = base - Offset(0, h);
        c.drawLine(base, top, stroke(const Color(0xFF0B0822), w, cap: ui.StrokeCap.butt));
        final arm = top + Offset(-side * 26 / z, 0);
        c.drawLine(top, arm, stroke(const Color(0xFF0B0822), w * 0.8));
        c.drawCircle(arm, 26 / z, blurred(fill(withAlpha(Brand.yellow, 0.45)), 10 / z));
        c.drawCircle(arm, 5 / z, fill(Brand.sunCore));
        // Light pool on the road.
        c.drawOval(Rect.fromCenter(center: road(side * 0.95, z), width: 120 / z, height: 22 / z),
            blurred(fill(withAlpha(Brand.orange, 0.22)), 8 / z));
      }
    }
  }

  void _coins(Canvas c) {
    // Trail in the left lane, curving up into an arc near the front.
    for (final z in [8.0, 5.6, 4.0, 3.0, 2.3, 1.8]) {
      final p = road(-2 / 3, z, lift: 48);
      drawCoin(c, p, 30 / z, spin: 0.55 + 0.45 * math.sin(z * 1.7).abs());
    }
    // Hop arc over the foreground.
    for (var i = 0; i < 4; i++) {
      final t = i / 3;
      final z = 1.42 - t * 0.28;
      final p = road(-2 / 3 + 0.06 * i, z, lift: 48 + math.sin(t * math.pi) * 120);
      drawCoin(c, p, 30 / z, spin: [0.95, 0.6, 0.85, 0.35][i]);
    }
    // Centre lane far ahead.
    for (final z in [9.0, 6.5, 4.8]) {
      drawCoin(c, road(0, z, lift: 48), 30 / z, spin: 0.8, glow: 0.8);
    }
    drawSparkle(c, road(-2 / 3, 1.3, lift: 48 + 150) + const Offset(40, 0), 9);
    drawSparkle(c, road(-2 / 3, 2.3, lift: 90) + const Offset(-18, 0), 6, alpha: 0.8);
  }

  void _motionStreaks(Canvas c) {
    final rnd = math.Random(12);
    for (var i = 0; i < 46; i++) {
      // Angles mostly below the horizon, fanning out from the vanishing point.
      final a = (0.06 + rnd.nextDouble() * 0.88) * math.pi;
      final r0 = 150 + rnd.nextDouble() * 280;
      final r1 = r0 + 60 + rnd.nextDouble() * 220;
      final p0 = _vp + polar(r0, a);
      final p1 = _vp + polar(r1, a);
      final alpha = 0.10 + rnd.nextDouble() * 0.22;
      c.drawLine(
          p0,
          p1,
          stroke(Brand.white, 0.8 + rnd.nextDouble() * 2.2)
            ..shader = ui.Gradient.linear(p0, p1, [withAlpha(Brand.white, 0), withAlpha(Brand.white, alpha)]));
    }
  }

  static const _riderCenterX = 802.0;
  static const _riderGround = 476.0;
  static const _riderWidth = 336.0;

  void _rider(Canvas c) {
    // Speed trail behind the rider (towards the vanishing point).
    final trail = <(double, double, double)>[(250, 150, 5), (300, 120, 3), (350, 170, 4), (395, 110, 2.5), (430, 140, 3.5)];
    for (final (y, len, w) in trail) {
      final end = Offset(_riderCenterX - _riderWidth * 0.36, y);
      final start = end - Offset(len, (end.dy - _horizon) * len / (end.dx - _vp.dx).abs() * 0.6);
      c.drawLine(
          start,
          end,
          stroke(Brand.white, w)
            ..shader = ui.Gradient.linear(start, end, [withAlpha(Brand.white, 0), withAlpha(Brand.white, 0.65)]));
    }
    // Ground shadow, cast away from the sun.
    c.drawOval(Rect.fromCenter(center: const Offset(_riderCenterX + 30, _riderGround + 2), width: _riderWidth * 1.05, height: 20),
        blurred(fill(withAlpha(Brand.navyDeep, 0.75)), 6));
    final fig = BikeRider(crank: 0.62, wheelPhase: 0.15);
    final b = BikeRider.bounds;
    final s = _riderWidth / b.width;
    c.save();
    c.translate(_riderCenterX - b.center.dx * s, _riderGround - b.bottom * s);
    c.scale(s);
    paintLitFigure(c, fig, RiderLook.hero,
        toLight: const Offset(-1, -0.45),
        rimColor: const Color(0xFFFFC266),
        rimWidth: 14,
        shadeColor: withAlpha(Brand.navyDeep, 0.5),
        shadeWidth: 44);
    c.restore();
    // Warm bounce light on the near side tyre.
    c.drawCircle(Offset(_riderCenterX - _riderWidth * 0.3, _riderGround - 30), 40,
        blurred(fill(withAlpha(Brand.orange, 0.12)), 18));
  }

  void _foregroundSparkles(Canvas c) {
    drawSparkle(c, const Offset(990 - 20, 150), 7, color: Brand.yellow, alpha: 0.9);
  }

  void _vignette(Canvas c) {
    c.drawRect(
        const Rect.fromLTWH(0, 0, width, height),
        Paint()
          ..shader = ui.Gradient.radial(const Offset(600, 280), 680, [
            withAlpha(Brand.navy, 0),
            withAlpha(Brand.navy, 0),
            withAlpha(Brand.navyDeep, 0.55),
          ], [0, 0.6, 1]));
    // Darker floor edge for depth.
    c.drawRect(
        const Rect.fromLTWH(0, 430, width, 70),
        Paint()
          ..shader = ui.Gradient.linear(const Offset(0, 430), const Offset(0, 500),
              [withAlpha(Brand.navyDeep, 0), withAlpha(Brand.navyDeep, 0.45)]));
  }

  /// Very light film grain to avoid gradient banding.
  void _grain(Canvas c) {
    final rnd = math.Random(99);
    final light = <Offset>[], dark = <Offset>[];
    for (var i = 0; i < 26000; i++) {
      final p = Offset(rnd.nextDouble() * width, rnd.nextDouble() * height);
      (i.isEven ? light : dark).add(p);
    }
    c.drawPoints(ui.PointMode.points, light, Paint()
      ..color = withAlpha(Brand.white, 0.035)
      ..strokeWidth = 1);
    c.drawPoints(ui.PointMode.points, dark, Paint()
      ..color = withAlpha(Brand.navyDeep, 0.06)
      ..strokeWidth = 1);
  }

  // --- Text ------------------------------------------------------------------

  static const double _boxWidth = 500;
  static const double _titleMaxHeight = 196;
  static const double _taglineMaxHeight = 74;

  double get _boxLeft => text.isRtl ? width - margin - _boxWidth : margin + 4;

  /// Inserts a line break after a subtitle separator ("Pedal Escape: Bike Run").
  static String breakTitle(String t) {
    for (final sep in [': ', '：', ' - ', ' – ', ' — ', '- ']) {
      final i = t.indexOf(sep);
      if (i > 0 && i < t.length - sep.length) {
        final keep = sep.trim();
        return '${t.substring(0, i)}$keep\n${t.substring(i + sep.length).trim()}';
      }
    }
    return t;
  }

  ui.Paragraph _para(
    String s, {
    required double size,
    required String family,
    required Paint fg,
    required double width,
    required int maxLines,
    double letterSpacing = 0,
    List<Shadow>? shadows,
  }) {
    final b = ui.ParagraphBuilder(ui.ParagraphStyle(
      textDirection: text.direction,
      textAlign: ui.TextAlign.start,
      maxLines: maxLines,
      fontFamily: family,
      fontSize: size,
      height: text.lineHeight,
    ))
      ..pushStyle(ui.TextStyle(
        foreground: fg,
        fontFamily: family,
        fontFamilyFallback: text.fallback,
        fontSize: size,
        height: text.lineHeight,
        letterSpacing: letterSpacing,
        shadows: shadows,
      ))
      ..addText(s);
    return b.build()..layout(ui.ParagraphConstraints(width: width));
  }

  double _fit(String s,
      {required String family,
      required double maxSize,
      required double minSize,
      required double maxHeight,
      required int maxLines,
      required double strokeFactor,
      double letterSpacing = 0}) {
    for (var size = maxSize; size >= 8; size -= 1) {
      final pad = size * strokeFactor;
      final w = _boxWidth - pad * 2;
      final p = _para(s, size: size, family: family, fg: fill(Brand.white), width: w, maxLines: maxLines, letterSpacing: letterSpacing);
      if (p.didExceedMaxLines) continue;
      if (p.minIntrinsicWidth > w + 0.5) continue; // a word would be broken
      if (p.longestLine > w + 0.5) continue;
      if (p.height + pad * 2 > maxHeight) continue;
      if (size < minSize) {
        // ignore: avoid_print
        print('WARNING [${text.locale}] "$s" only fits at ${size}px (< preferred $minSize).');
      }
      return size;
    }
    throw StateError('[${text.locale}] text cannot be fitted: "$s"');
  }

  void _texts(Canvas c) {
    final title = breakTitle(text.title);
    final family = text.titleFamily;
    const strokeF = 0.09;
    final size = _fit(title,
        family: family, maxSize: 94, minSize: 40, maxHeight: _titleMaxHeight, maxLines: 2, strokeFactor: strokeF + 0.04);
    final pad = size * (strokeF + 0.04);
    final w = _boxWidth - pad * 2;
    final x = _boxLeft + pad;
    final y = margin + pad * 0.6;

    Paint strokeP(Color col, double sw, {double blur = 0}) {
      final p = Paint()
        ..color = col
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeJoin = ui.StrokeJoin.round;
      if (blur > 0) p.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blur);
      return p;
    }

    ui.Paragraph build(Paint fg, {List<Shadow>? shadows}) =>
        _para(title, size: size, family: family, fg: fg, width: w, maxLines: 2, shadows: shadows);

    // 1) Warm outer glow.
    final glow = build(strokeP(withAlpha(Brand.coral, 0.55), size * 0.34, blur: size * 0.16));
    c.drawParagraph(glow, Offset(x, y));
    // 2) Extruded depth.
    final extrude = build(strokeP(const Color(0xFF07051A), size * strokeF * 2));
    final depth = (size * 0.075).clamp(2.0, 8.0);
    for (var k = depth; k > 0; k -= 1) {
      c.drawParagraph(extrude, Offset(x + k * 0.35, y + k));
    }
    // 3) Outline.
    c.drawParagraph(build(strokeP(const Color(0xFF1A1045), size * strokeF * 2)), Offset(x, y));
    // 4) Gradient fill, repeating per line.
    final metrics = build(fill(Brand.white)).computeLineMetrics();
    final lineH = metrics.isEmpty ? size : metrics.first.height;
    final top = metrics.isEmpty ? 0.0 : metrics.first.baseline - metrics.first.ascent;
    c.save();
    c.translate(x, y);
    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(0, top), Offset(0, top + lineH), [
        const Color(0xFFFFF7C4),
        Brand.yellow,
        const Color(0xFFFFA51F),
        Brand.orange,
      ], [0.18, 0.45, 0.74, 0.9], ui.TileMode.repeated);
    final fillPara = build(fillPaint);
    c.drawParagraph(fillPara, Offset.zero);
    c.restore();

    // Accent bar under the title.
    final titleBottom = y + fillPara.height + pad * 0.6;
    final linesW = metrics.fold<double>(0, (m, l) => math.max(m, l.width));
    final barW = math.min(170.0, math.max(90.0, linesW * 0.4));
    final barLeft = text.isRtl ? _boxLeft + _boxWidth - pad - barW : x;
    final bar = RRect.fromRectAndRadius(Rect.fromLTWH(barLeft, titleBottom + 6, barW, 6), const Radius.circular(3));
    c.drawRRect(bar.shift(const Offset(0, 2)), fill(withAlpha(Brand.navyDeep, 0.7)));
    c.drawRRect(
        bar,
        Paint()
          ..shader = ui.Gradient.linear(bar.outerRect.centerLeft, bar.outerRect.centerRight,
              text.isRtl ? [Brand.yellow, Brand.orange, Brand.teal] : [Brand.teal, Brand.orange, Brand.yellow]));

    // Tagline.
    final tagFamily = text.bodyFamily;
    final ls = text.fallback.first == tagFamily ? 0.4 : 0.0;
    final tagSize = _fit(text.tagline,
        family: tagFamily,
        maxSize: 34,
        minSize: 18,
        maxHeight: _taglineMaxHeight,
        maxLines: 2,
        strokeFactor: 0.12,
        letterSpacing: ls);
    final tPad = tagSize * 0.12;
    final tw = _boxWidth - tPad * 2;
    final tx = _boxLeft + tPad;
    final ty = titleBottom + 22;
    final shadows = [
      Shadow(color: withAlpha(Brand.navyDeep, 0.9), offset: const Offset(0, 3), blurRadius: 6),
    ];
    c.drawParagraph(
        _para(text.tagline,
            size: tagSize,
            family: tagFamily,
            fg: strokeP(const Color(0xFF1A1045), tagSize * 0.2),
            width: tw,
            maxLines: 2,
            letterSpacing: ls,
            shadows: shadows),
        Offset(tx, ty));
    c.drawParagraph(
        _para(text.tagline, size: tagSize, family: tagFamily, fg: fill(Brand.white), width: tw, maxLines: 2, letterSpacing: ls),
        Offset(tx, ty));

    final textBottom = ty + _para(text.tagline, size: tagSize, family: tagFamily, fg: fill(Brand.white), width: tw, maxLines: 2).height;
    if (textBottom > height - margin) {
      throw StateError('[${text.locale}] text block overflows the safe area ($textBottom).');
    }
  }
}
