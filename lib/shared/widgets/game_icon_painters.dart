/// Custom-painted game icons (no image assets). Use [GameIcon] with a
/// [GameIconType]; every icon is drawn in a 1x1 unit box and scaled.
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';

enum GameIconType {
  coin,
  gem,
  star,
  lock,
  gear,
  trophy,
  gift,
  wheel,
  bike,
  back,
  play,
  chest,
  calendar,
  tasks,
  check,
  close,
  bolt,
  infinity,
  flag,
  clock,
  globe,
  sound,
  music,
  vibration,
  graphics,
  swipe,
  refresh,
  trash,
  chevronLeft,
  chevronRight,
  paint,
  wrench,
  storm,
  xp,
}

/// A crisp vector icon. [color] tints monochrome icons; coin/gem/star/chest
/// have their own colors.
class GameIcon extends StatelessWidget {
  const GameIcon(this.type, {super.key, this.size = 24, this.color, this.mirrorInRtl = false});

  final GameIconType type;
  final double size;
  final Color? color;

  /// Flip horizontally in RTL layouts (arrows).
  final bool mirrorInRtl;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.maybeOf(context) == TextDirection.rtl;
    final autoMirror = type == GameIconType.back ||
        type == GameIconType.chevronLeft ||
        type == GameIconType.chevronRight;
    Widget icon = CustomPaint(
      size: Size.square(size),
      painter: GameIconPainter(type, color ?? AppColors.textPrimary),
    );
    if ((mirrorInRtl || autoMirror) && rtl) {
      icon = Transform.flip(flipX: true, child: icon);
    }
    return SizedBox.square(dimension: size, child: icon);
  }
}

class GameIconPainter extends CustomPainter {
  GameIconPainter(this.type, this.color);

  final GameIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width, size.height);
    switch (type) {
      case GameIconType.coin:
        _coin(canvas);
      case GameIconType.gem:
        _gem(canvas);
      case GameIconType.star:
        _star(canvas, AppColors.electricYellow);
      case GameIconType.lock:
        _lock(canvas);
      case GameIconType.gear:
        _gear(canvas);
      case GameIconType.trophy:
        _trophy(canvas);
      case GameIconType.gift:
        _gift(canvas);
      case GameIconType.wheel:
        _wheel(canvas);
      case GameIconType.bike:
        _bike(canvas);
      case GameIconType.back:
      case GameIconType.chevronLeft:
        _chevron(canvas, left: true);
      case GameIconType.chevronRight:
        _chevron(canvas, left: false);
      case GameIconType.play:
        _play(canvas);
      case GameIconType.chest:
        _chest(canvas);
      case GameIconType.calendar:
        _calendar(canvas);
      case GameIconType.tasks:
        _tasks(canvas);
      case GameIconType.check:
        _check(canvas);
      case GameIconType.close:
        _close(canvas);
      case GameIconType.bolt:
        _bolt(canvas);
      case GameIconType.infinity:
        _infinity(canvas);
      case GameIconType.flag:
        _flag(canvas);
      case GameIconType.clock:
        _clock(canvas);
      case GameIconType.globe:
        _globe(canvas);
      case GameIconType.sound:
        _sound(canvas);
      case GameIconType.music:
        _music(canvas);
      case GameIconType.vibration:
        _vibration(canvas);
      case GameIconType.graphics:
        _graphics(canvas);
      case GameIconType.swipe:
        _swipe(canvas);
      case GameIconType.refresh:
        _refresh(canvas);
      case GameIconType.trash:
        _trash(canvas);
      case GameIconType.paint:
        _paint(canvas);
      case GameIconType.wrench:
        _wrench(canvas);
      case GameIconType.storm:
        _storm(canvas);
      case GameIconType.xp:
        _xp(canvas);
    }
    canvas.restore();
  }

  Paint get _fill => Paint()..color = color;

  Paint _stroke(double w, [Color? c]) => Paint()
    ..color = c ?? color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _coin(Canvas c) {
    const center = Offset(0.5, 0.5);
    c.drawCircle(center.translate(0, 0.04), 0.44, Paint()..color = AppColors.goldDark);
    c.drawCircle(
      center,
      0.44,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0A0), AppColors.coinGold, Color(0xFFE09A00)],
        ).createShader(const Rect.fromLTWH(0, 0, 1, 1)),
    );
    c.drawCircle(center, 0.32, _stroke(0.06, const Color(0xFFE8A300)));
    // Embossed star.
    final p = _starPath(center, 0.2, 0.09);
    c.drawPath(p, Paint()..color = const Color(0xFFFFF4C2));
    c.drawCircle(const Offset(0.34, 0.3), 0.07, Paint()..color = const Color(0xAAFFFFFF));
  }

  void _gem(Canvas c) {
    final outline = Path()
      ..moveTo(0.2, 0.12)
      ..lineTo(0.8, 0.12)
      ..lineTo(0.98, 0.38)
      ..lineTo(0.5, 0.95)
      ..lineTo(0.02, 0.38)
      ..close();
    c.drawPath(outline.shift(const Offset(0, 0.03)), Paint()..color = AppColors.cyanDark);
    c.drawPath(outline, Paint()..color = AppColors.gemCyan);
    final top = Path()
      ..moveTo(0.2, 0.12)
      ..lineTo(0.8, 0.12)
      ..lineTo(0.98, 0.38)
      ..lineTo(0.02, 0.38)
      ..close();
    c.drawPath(top, Paint()..color = const Color(0xFFA8F4FF));
    final facet = Path()
      ..moveTo(0.3, 0.38)
      ..lineTo(0.5, 0.95)
      ..lineTo(0.7, 0.38)
      ..close();
    c.drawPath(facet, Paint()..color = const Color(0xFF7DEBFF));
    c.drawPath(
      Path()
        ..moveTo(0.3, 0.38)
        ..lineTo(0.42, 0.12)
        ..lineTo(0.58, 0.12)
        ..lineTo(0.7, 0.38)
        ..close(),
      Paint()..color = const Color(0xFFE6FCFF),
    );
  }

  Path _starPath(Offset center, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final pt = center + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    return path..close();
  }

  void _star(Canvas c, Color fill) {
    final useColor = color == AppColors.textPrimary ? fill : color;
    final p = _starPath(const Offset(0.5, 0.54), 0.48, 0.22);
    c.drawPath(p.shift(const Offset(0, 0.04)), Paint()..color = const Color(0x66000000));
    c.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(useColor, const Color(0xFFFFFFFF), 0.45)!, useColor],
        ).createShader(const Rect.fromLTWH(0, 0, 1, 1)),
    );
    c.drawPath(p, _stroke(0.035, Color.lerp(useColor, const Color(0xFF000000), 0.3)));
  }

  void _lock(Canvas c) {
    c.drawArc(const Rect.fromLTWH(0.27, 0.1, 0.46, 0.5), math.pi, math.pi, false, _stroke(0.1));
    c.drawLine(const Offset(0.27, 0.35), const Offset(0.27, 0.45), _stroke(0.1));
    c.drawLine(const Offset(0.73, 0.35), const Offset(0.73, 0.45), _stroke(0.1));
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0.16, 0.42, 0.68, 0.5), const Radius.circular(0.1)),
      _fill,
    );
    c.drawCircle(const Offset(0.5, 0.62), 0.07, Paint()..color = const Color(0x99000000));
    c.drawRect(const Rect.fromLTWH(0.47, 0.64, 0.06, 0.14), Paint()..color = const Color(0x99000000));
  }

  void _gear(Canvas c) {
    const center = Offset(0.5, 0.5);
    final path = Path();
    const teeth = 8;
    for (var i = 0; i < teeth * 2; i++) {
      final a0 = i * math.pi / teeth;
      final a1 = (i + 1) * math.pi / teeth;
      final r = i.isEven ? 0.47 : 0.36;
      final p0 = center + Offset(math.cos(a0) * r, math.sin(a0) * r);
      final p1 = center + Offset(math.cos(a1) * r, math.sin(a1) * r);
      if (i == 0) path.moveTo(p0.dx, p0.dy);
      path.lineTo(p0.dx, p0.dy);
      path.lineTo(p1.dx, p1.dy);
    }
    path.close();
    path.addOval(Rect.fromCircle(center: center, radius: 0.15));
    path.fillType = PathFillType.evenOdd;
    c.drawPath(path, _fill);
  }

  void _trophy(Canvas c) {
    final cup = Path()
      ..moveTo(0.22, 0.1)
      ..lineTo(0.78, 0.1)
      ..quadraticBezierTo(0.78, 0.58, 0.5, 0.6)
      ..quadraticBezierTo(0.22, 0.58, 0.22, 0.1)
      ..close();
    final gold = color == AppColors.textPrimary ? AppColors.coinGold : color;
    c.drawArc(const Rect.fromLTWH(0.06, 0.16, 0.3, 0.28), math.pi / 2, math.pi, false, _stroke(0.07, gold));
    c.drawArc(const Rect.fromLTWH(0.64, 0.16, 0.3, 0.28), -math.pi / 2, math.pi, false, _stroke(0.07, gold));
    c.drawPath(cup, Paint()..color = gold);
    c.drawRect(const Rect.fromLTWH(0.44, 0.58, 0.12, 0.18), Paint()..color = gold);
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0.26, 0.76, 0.48, 0.14), const Radius.circular(0.04)),
      Paint()..color = gold,
    );
    c.drawPath(_starPath(const Offset(0.5, 0.3), 0.12, 0.05), Paint()..color = const Color(0xCCFFFFFF));
  }

  void _gift(Canvas c) {
    final box = color == AppColors.textPrimary ? AppColors.coral : color;
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.12, 0.42, 0.76, 0.5), const Radius.circular(0.06)),
        Paint()..color = box);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.06, 0.3, 0.88, 0.16), const Radius.circular(0.05)),
        Paint()..color = Color.lerp(box, const Color(0xFFFFFFFF), 0.25)!);
    final ribbon = Paint()..color = AppColors.electricYellow;
    c.drawRect(const Rect.fromLTWH(0.44, 0.3, 0.12, 0.62), ribbon);
    c.drawOval(const Rect.fromLTWH(0.22, 0.1, 0.28, 0.22), _stroke(0.07, AppColors.electricYellow));
    c.drawOval(const Rect.fromLTWH(0.5, 0.1, 0.28, 0.22), _stroke(0.07, AppColors.electricYellow));
  }

  void _wheel(Canvas c) {
    const center = Offset(0.5, 0.5);
    const colors = [AppColors.coral, AppColors.electricYellow, AppColors.teal, AppColors.violet];
    for (var i = 0; i < 8; i++) {
      c.drawArc(Rect.fromCircle(center: center, radius: 0.44), -math.pi / 2 + i * math.pi / 4, math.pi / 4,
          true, Paint()..color = colors[i % 4]);
    }
    c.drawCircle(center, 0.44, _stroke(0.06, const Color(0xFFFFFFFF)));
    c.drawCircle(center, 0.1, Paint()..color = const Color(0xFFFFFFFF));
    final pin = Path()
      ..moveTo(0.4, 0.0)
      ..lineTo(0.6, 0.0)
      ..lineTo(0.5, 0.18)
      ..close();
    c.drawPath(pin, Paint()..color = const Color(0xFFFFFFFF));
  }

  void _bike(Canvas c) {
    final s = _stroke(0.07);
    c.drawCircle(const Offset(0.22, 0.66), 0.18, s);
    c.drawCircle(const Offset(0.78, 0.66), 0.18, s);
    final frame = Path()
      ..moveTo(0.22, 0.66)
      ..lineTo(0.42, 0.38)
      ..lineTo(0.68, 0.38)
      ..lineTo(0.78, 0.66)
      ..moveTo(0.42, 0.38)
      ..lineTo(0.5, 0.66)
      ..lineTo(0.68, 0.38)
      ..moveTo(0.5, 0.66)
      ..lineTo(0.22, 0.66)
      ..moveTo(0.36, 0.28)
      ..lineTo(0.48, 0.28)
      ..moveTo(0.42, 0.28)
      ..lineTo(0.42, 0.38)
      ..moveTo(0.68, 0.38)
      ..lineTo(0.64, 0.24)
      ..lineTo(0.74, 0.22);
    c.drawPath(frame, s);
  }

  void _chevron(Canvas c, {required bool left}) {
    final p = Path();
    if (left) {
      p
        ..moveTo(0.64, 0.16)
        ..lineTo(0.3, 0.5)
        ..lineTo(0.64, 0.84);
    } else {
      p
        ..moveTo(0.36, 0.16)
        ..lineTo(0.7, 0.5)
        ..lineTo(0.36, 0.84);
    }
    c.drawPath(p, _stroke(0.14));
  }

  void _play(Canvas c) {
    final p = Path()
      ..moveTo(0.28, 0.14)
      ..lineTo(0.86, 0.5)
      ..lineTo(0.28, 0.86)
      ..close();
    c.drawPath(p, _fill);
    c.drawPath(p, _stroke(0.08));
  }

  void _chest(Canvas c) {
    const wood = Color(0xFFB0602A);
    const woodDark = Color(0xFF7A3A12);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.08, 0.44, 0.84, 0.46), const Radius.circular(0.06)),
        Paint()..color = wood);
    final lid = Path()
      ..moveTo(0.08, 0.46)
      ..lineTo(0.08, 0.34)
      ..quadraticBezierTo(0.5, 0.02, 0.92, 0.34)
      ..lineTo(0.92, 0.46)
      ..close();
    c.drawPath(lid, Paint()..color = const Color(0xFFD07A3A));
    final band = Paint()..color = AppColors.coinGold;
    c.drawRect(const Rect.fromLTWH(0.08, 0.42, 0.84, 0.07), band);
    c.drawRect(const Rect.fromLTWH(0.2, 0.2, 0.07, 0.7), band);
    c.drawRect(const Rect.fromLTWH(0.73, 0.2, 0.07, 0.7), band);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.42, 0.4, 0.16, 0.18), const Radius.circular(0.03)),
        Paint()..color = AppColors.electricYellow);
    c.drawRect(const Rect.fromLTWH(0.48, 0.46, 0.04, 0.07), Paint()..color = woodDark);
  }

  void _calendar(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.1, 0.16, 0.8, 0.74), const Radius.circular(0.1)),
        _fill);
    c.drawRRect(
      RRect.fromRectAndCorners(const Rect.fromLTWH(0.1, 0.16, 0.8, 0.2),
          topLeft: const Radius.circular(0.1), topRight: const Radius.circular(0.1)),
      Paint()..color = AppColors.coral,
    );
    c.drawLine(const Offset(0.3, 0.08), const Offset(0.3, 0.24), _stroke(0.08));
    c.drawLine(const Offset(0.7, 0.08), const Offset(0.7, 0.24), _stroke(0.08));
    final dot = Paint()..color = AppColors.deepPurple;
    for (var r = 0; r < 2; r++) {
      for (var col = 0; col < 3; col++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0.2 + col * 0.22, 0.46 + r * 0.2, 0.15, 0.13), const Radius.circular(0.03)),
          dot,
        );
      }
    }
  }

  void _tasks(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.14, 0.1, 0.72, 0.84), const Radius.circular(0.1)),
        _fill);
    final dark = AppColors.deepPurple;
    for (var i = 0; i < 3; i++) {
      final y = 0.3 + i * 0.22;
      c.drawPath(
        Path()
          ..moveTo(0.24, y)
          ..lineTo(0.3, y + 0.06)
          ..lineTo(0.4, y - 0.05),
        _stroke(0.06, AppColors.teal),
      );
      c.drawLine(Offset(0.48, y), Offset(0.76, y), _stroke(0.06, dark));
    }
  }

  void _check(Canvas c) {
    c.drawPath(
      Path()
        ..moveTo(0.16, 0.52)
        ..lineTo(0.4, 0.76)
        ..lineTo(0.86, 0.26),
      _stroke(0.15),
    );
  }

  void _close(Canvas c) {
    final s = _stroke(0.14);
    c.drawLine(const Offset(0.22, 0.22), const Offset(0.78, 0.78), s);
    c.drawLine(const Offset(0.78, 0.22), const Offset(0.22, 0.78), s);
  }

  void _bolt(Canvas c) {
    final p = Path()
      ..moveTo(0.58, 0.04)
      ..lineTo(0.18, 0.56)
      ..lineTo(0.46, 0.56)
      ..lineTo(0.38, 0.96)
      ..lineTo(0.82, 0.42)
      ..lineTo(0.54, 0.42)
      ..close();
    c.drawPath(p, Paint()..color = color == AppColors.textPrimary ? AppColors.electricYellow : color);
  }

  void _infinity(Canvas c) {
    final p = Path()
      ..moveTo(0.5, 0.5)
      ..cubicTo(0.65, 0.25, 0.95, 0.25, 0.95, 0.5)
      ..cubicTo(0.95, 0.75, 0.65, 0.75, 0.5, 0.5)
      ..cubicTo(0.35, 0.25, 0.05, 0.25, 0.05, 0.5)
      ..cubicTo(0.05, 0.75, 0.35, 0.75, 0.5, 0.5);
    c.drawPath(p, _stroke(0.11));
  }

  void _flag(Canvas c) {
    c.drawLine(const Offset(0.2, 0.08), const Offset(0.2, 0.94), _stroke(0.08));
    final checker = Rect.fromLTWH(0.24, 0.1, 0.62, 0.44);
    c.drawRect(checker, Paint()..color = const Color(0xFFFFFFFF));
    final dark = Paint()..color = const Color(0xFF1A1040);
    const n = 4;
    for (var r = 0; r < 3; r++) {
      for (var col = 0; col < n; col++) {
        if ((r + col).isOdd) continue;
        c.drawRect(
          Rect.fromLTWH(checker.left + col * checker.width / n, checker.top + r * checker.height / 3,
              checker.width / n, checker.height / 3),
          dark,
        );
      }
    }
  }

  void _clock(Canvas c) {
    c.drawCircle(const Offset(0.5, 0.5), 0.4, _stroke(0.09));
    c.drawLine(const Offset(0.5, 0.5), const Offset(0.5, 0.26), _stroke(0.08));
    c.drawLine(const Offset(0.5, 0.5), const Offset(0.68, 0.6), _stroke(0.08));
  }

  void _globe(Canvas c) {
    final s = _stroke(0.07);
    c.drawCircle(const Offset(0.5, 0.5), 0.42, s);
    c.drawOval(const Rect.fromLTWH(0.3, 0.08, 0.4, 0.84), s);
    c.drawLine(const Offset(0.08, 0.5), const Offset(0.92, 0.5), s);
    c.drawLine(const Offset(0.5, 0.08), const Offset(0.5, 0.92), s);
  }

  void _speaker(Canvas c) {
    final p = Path()
      ..moveTo(0.08, 0.36)
      ..lineTo(0.26, 0.36)
      ..lineTo(0.5, 0.14)
      ..lineTo(0.5, 0.86)
      ..lineTo(0.26, 0.64)
      ..lineTo(0.08, 0.64)
      ..close();
    c.drawPath(p, _fill);
  }

  void _sound(Canvas c) {
    _speaker(c);
    c.drawArc(const Rect.fromLTWH(0.42, 0.3, 0.3, 0.4), -math.pi / 3, 2 * math.pi / 3, false, _stroke(0.07));
    c.drawArc(const Rect.fromLTWH(0.42, 0.14, 0.48, 0.72), -math.pi / 3, 2 * math.pi / 3, false, _stroke(0.07));
  }

  void _music(Canvas c) {
    c.drawOval(const Rect.fromLTWH(0.12, 0.66, 0.26, 0.2), _fill);
    c.drawOval(const Rect.fromLTWH(0.58, 0.56, 0.26, 0.2), _fill);
    c.drawLine(const Offset(0.36, 0.76), const Offset(0.36, 0.2), _stroke(0.07));
    c.drawLine(const Offset(0.82, 0.66), const Offset(0.82, 0.1), _stroke(0.07));
    c.drawPath(
      Path()
        ..moveTo(0.36, 0.2)
        ..lineTo(0.82, 0.1)
        ..lineTo(0.82, 0.24)
        ..lineTo(0.36, 0.34)
        ..close(),
      _fill,
    );
  }

  void _vibration(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.32, 0.1, 0.36, 0.8), const Radius.circular(0.08)),
        _stroke(0.07));
    final s = _stroke(0.06);
    c.drawLine(const Offset(0.16, 0.34), const Offset(0.16, 0.66), s);
    c.drawLine(const Offset(0.84, 0.34), const Offset(0.84, 0.66), s);
    c.drawLine(const Offset(0.04, 0.42), const Offset(0.04, 0.58), s);
    c.drawLine(const Offset(0.96, 0.42), const Offset(0.96, 0.58), s);
  }

  void _graphics(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.08, 0.16, 0.84, 0.68), const Radius.circular(0.08)),
        _stroke(0.07));
    final m = Path()
      ..moveTo(0.16, 0.74)
      ..lineTo(0.4, 0.44)
      ..lineTo(0.56, 0.62)
      ..lineTo(0.66, 0.5)
      ..lineTo(0.84, 0.74)
      ..close();
    c.drawPath(m, _fill);
    c.drawCircle(const Offset(0.7, 0.32), 0.07, _fill);
  }

  void _swipe(Canvas c) {
    final s = _stroke(0.08);
    c.drawLine(const Offset(0.12, 0.5), const Offset(0.88, 0.5), s);
    c.drawPath(
        Path()
          ..moveTo(0.26, 0.34)
          ..lineTo(0.1, 0.5)
          ..lineTo(0.26, 0.66),
        s);
    c.drawPath(
        Path()
          ..moveTo(0.74, 0.34)
          ..lineTo(0.9, 0.5)
          ..lineTo(0.74, 0.66),
        s);
  }

  void _refresh(Canvas c) {
    c.drawArc(const Rect.fromLTWH(0.14, 0.14, 0.72, 0.72), -math.pi / 2, math.pi * 1.6, false, _stroke(0.09));
    c.drawPath(
      Path()
        ..moveTo(0.5, 0.02)
        ..lineTo(0.66, 0.14)
        ..lineTo(0.5, 0.26)
        ..close(),
      _fill,
    );
  }

  void _trash(Canvas c) {
    c.drawLine(const Offset(0.14, 0.24), const Offset(0.86, 0.24), _stroke(0.08));
    c.drawLine(const Offset(0.4, 0.12), const Offset(0.6, 0.12), _stroke(0.08));
    final can = Path()
      ..moveTo(0.22, 0.3)
      ..lineTo(0.78, 0.3)
      ..lineTo(0.7, 0.9)
      ..lineTo(0.3, 0.9)
      ..close();
    c.drawPath(can, _fill);
  }

  void _paint(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.1, 0.1, 0.66, 0.3), const Radius.circular(0.08)),
        _fill);
    c.drawLine(const Offset(0.76, 0.25), const Offset(0.9, 0.25), _stroke(0.06));
    c.drawLine(const Offset(0.9, 0.25), const Offset(0.9, 0.5), _stroke(0.06));
    c.drawLine(const Offset(0.9, 0.5), const Offset(0.5, 0.56), _stroke(0.06));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.44, 0.56, 0.12, 0.38), const Radius.circular(0.04)),
        _fill);
  }

  void _wrench(Canvas c) {
    c.save();
    c.translate(0.5, 0.5);
    c.rotate(-math.pi / 4);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-0.08, -0.12, 0.16, 0.56), const Radius.circular(0.06)),
        _fill);
    final head = Path()
      ..addOval(Rect.fromCircle(center: const Offset(0, -0.26), radius: 0.2))
      ..addRect(const Rect.fromLTWH(-0.07, -0.5, 0.14, 0.24))
      ..fillType = PathFillType.evenOdd;
    c.drawPath(head, _fill);
    c.restore();
  }

  void _storm(Canvas c) {
    final cloud = Paint()..color = color == AppColors.textPrimary ? const Color(0xFFB9A8FF) : color;
    c.drawCircle(const Offset(0.34, 0.4), 0.18, cloud);
    c.drawCircle(const Offset(0.56, 0.32), 0.22, cloud);
    c.drawCircle(const Offset(0.76, 0.44), 0.15, cloud);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0.16, 0.38, 0.74, 0.2), const Radius.circular(0.1)),
        cloud);
    final bolt = Path()
      ..moveTo(0.54, 0.52)
      ..lineTo(0.4, 0.76)
      ..lineTo(0.52, 0.76)
      ..lineTo(0.44, 0.98)
      ..lineTo(0.66, 0.68)
      ..lineTo(0.54, 0.68)
      ..lineTo(0.62, 0.52)
      ..close();
    c.drawPath(bolt, Paint()..color = AppColors.electricYellow);
  }

  void _xp(Canvas c) {
    final p = Path()
      ..moveTo(0.5, 0.04)
      ..lineTo(0.92, 0.28)
      ..lineTo(0.92, 0.72)
      ..lineTo(0.5, 0.96)
      ..lineTo(0.08, 0.72)
      ..lineTo(0.08, 0.28)
      ..close();
    c.drawPath(p, Paint()..color = AppColors.violet);
    c.drawPath(p, _stroke(0.06, AppColors.gemCyan));
    c.drawPath(_starPath(const Offset(0.5, 0.52), 0.24, 0.1), Paint()..color = AppColors.gemCyan);
  }

  @override
  bool shouldRepaint(GameIconPainter old) => old.type != type || old.color != color;
}
