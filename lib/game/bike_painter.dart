import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'skins.dart';

/// Draws the cyclist seen from behind, in local meter units with the origin at
/// the rear tyre's ground contact point (y grows downwards).
///
/// All Paint objects and shaders are created once per skin and then reused
/// every frame, so drawing the rider allocates nothing but a few Offsets.
class BikePainter {
  BikePainter(Skin skin) {
    setSkin(skin);
  }

  Skin _skin = kSkins.first;

  final Paint _tire = Paint()..color = const Color(0xff17181b);
  final Paint _tireHi = Paint()
    ..color = const Color(0xff3a3d44)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.012;
  final Paint _frame = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.045;
  final Paint _frameThin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.028;
  final Paint _dark = Paint()..color = const Color(0xff202228);
  final Paint _bar = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.035
    ..color = const Color(0xff2a2d33);
  final Paint _thigh = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.14;
  final Paint _shin = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.1
    ..color = const Color(0xffe0ac84);
  final Paint _shinShade = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.04
    ..color = const Color(0x33000000);
  final Paint _shoe = Paint()..color = const Color(0xfff2f2f2);
  final Paint _shoeSole = Paint()..color = const Color(0xff2b2b2b);
  final Paint _arm = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.085
    ..color = const Color(0xffe0ac84);
  final Paint _sleeve = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 0.1;
  final Paint _torso = Paint();
  final Paint _stripe = Paint();
  final Paint _shorts = Paint();
  final Paint _helmet = Paint();
  final Paint _vent = Paint()..color = const Color(0xff15161a);
  final Paint _neck = Paint()..color = const Color(0xffd29a72);
  final Paint _hair = Paint()..color = const Color(0xff3b2a1e);
  final Paint _reflector = Paint()..color = const Color(0xffff2a2a);
  final Paint _shadow = Paint();
  final Paint _shield = Paint();
  final Paint _shieldRim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.035;
  final Paint _number = Paint()..color = const Color(0xffffffff);
  final Paint _torsoShade = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(-0.24, 0),
      const Offset(0.24, 0),
      const [Color(0x10ffffff), Color(0x00000000), Color(0x00000000), Color(0x55000000)],
      const [0, 0.3, 0.6, 1],
    );
  final Paint _pocket = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.012
    ..color = const Color(0x40000000);
  final Paint _spec = Paint()..color = const Color(0x88ffffff);
  final Paint _bag = Paint()..color = const Color(0xff2a2c31);

  final Path _path = Path();

  void setSkin(Skin s) {
    _skin = s;
    _frame.color = s.frame;
    _frameThin.color = Color.lerp(s.frame, const Color(0xff000000), 0.25)!;
    _thigh.color = s.shorts;
    _sleeve.color = s.jersey;
    _shorts.color = s.shorts;
    _torso.shader = ui.Gradient.linear(
      const Offset(0, -1.55),
      const Offset(0, -0.98),
      [
        Color.lerp(s.jersey, const Color(0xffffffff), 0.28)!,
        s.jersey,
        Color.lerp(s.jersey, const Color(0xff000000), 0.35)!,
      ],
      const [0, 0.4, 1],
    );
    _stripe.color = s.accent;
    _helmet.shader = ui.Gradient.radial(
      const Offset(-0.04, -1.7),
      0.2,
      [
        Color.lerp(s.helmet, const Color(0xffffffff), 0.6)!,
        s.helmet,
        Color.lerp(s.helmet, const Color(0xff000000), 0.45)!,
      ],
      const [0, 0.5, 1],
    );
    _shadow.shader = ui.Gradient.radial(Offset.zero, 1, const [Color(0x66000000), Color(0x00000000)]);
    _shield.shader = ui.Gradient.radial(
      Offset.zero,
      1.05,
      const [Color(0x00a0e8ff), Color(0x2240c8ff), Color(0x7740c8ff)],
      const [0, 0.75, 1],
    );
    _shieldRim.color = const Color(0xaad8f6ff);
  }

  Skin get skin => _skin;

  /// Ground shadow; drawn separately so it stays on the road while jumping.
  void paintShadow(Canvas c, double jumpY) {
    final s = 1 / (1 + jumpY * 0.6);
    c.save();
    c.scale(0.5 * s, 0.13 * s);
    c.drawCircle(Offset.zero, 1, _shadow);
    c.restore();
  }

  /// [pedal] crank angle, [duck] 0..1, [lean] radians, [night] 0..1.
  void paint(
    Canvas c, {
    required double pedal,
    required double duck,
    required double lean,
    required double night,
    required bool shield,
    required double time,
    required double crash,
  }) {
    c.save();
    c.rotate(lean);

    final d = duck;
    // The upper body rocks gently with every pedal stroke.
    final bob = crash > 0 ? 0.0 : math.sin(pedal * 2) * 0.012;
    final rock = crash > 0 ? 0.0 : math.sin(pedal) * 0.018;
    final hipY = -1.0 + d * 0.06;
    final shoulderY = -1.47 + d * 0.2 + bob;
    final headY = -1.66 + d * 0.27 + bob;

    // --- front wheel (far, partly hidden) and handlebars
    final steer = -lean * 0.08;
    c.drawRRect(RRect.fromLTRBR(-0.03 + steer, -0.68, 0.03 + steer, -0.12, const Radius.circular(0.03)), _tire);

    // --- rear wheel
    c.drawRRect(RRect.fromLTRBR(-0.05, -0.68, 0.05, 0.0, const Radius.circular(0.05)), _tire);
    c.drawLine(const Offset(-0.022, -0.6), const Offset(-0.022, -0.08), _tireHi);
    // Spinning spoke glint.
    final g = (pedal * 2.3) % 1.0;
    c.drawLine(Offset(-0.01, -0.62 + g * 0.56), Offset(0.01, -0.6 + g * 0.56), _tireHi);

    // --- frame: seat stays + seat tube
    c.drawLine(const Offset(-0.06, -0.34), const Offset(-0.02, -0.92), _frameThin);
    c.drawLine(const Offset(0.06, -0.34), const Offset(0.02, -0.92), _frameThin);
    c.drawLine(const Offset(0, -0.4), const Offset(0, -0.96), _frame);
    // Fender + reflector.
    c.drawRRect(RRect.fromLTRBR(-0.07, -0.74, 0.07, -0.69, const Radius.circular(0.02)), _dark);
    _reflector.color = night > 0.3 ? const Color(0xffff4040) : const Color(0xffd92020);
    c.drawRRect(RRect.fromLTRBR(-0.045, -0.82, 0.045, -0.76, const Radius.circular(0.012)), _reflector);

    // --- handlebar
    c.drawLine(Offset(-0.31 + steer, -1.17 + d * 0.04), Offset(0.31 + steer, -1.17 + d * 0.04), _bar);

    // --- legs (pedaling)
    final legs = crash > 0 ? 0.0 : 1.0;
    for (var side = -1; side <= 1; side += 2) {
      final a = pedal + (side < 0 ? 0 : math.pi);
      final footY = -0.3 + math.sin(a) * 0.17 * legs;
      final footX = side * (0.16 + math.cos(a) * 0.015);
      final hip = Offset(side * 0.1, hipY);
      final up = (1 - math.sin(a)) * 0.5; // 1 when the foot is at the top
      final knee = Offset(side * (0.15 + up * 0.03), hipY + (footY - hipY) * (0.5 - up * 0.08) - up * 0.06);
      final ankle = Offset(footX, footY - 0.06);
      c.drawLine(knee, ankle, _shin);
      c.drawLine(knee + Offset(side * 0.025, 0.02), ankle + Offset(side * 0.02, 0), _shinShade);
      c.drawLine(hip, knee, _thigh);
      // Shoe seen from behind.
      c.drawRRect(
        RRect.fromLTRBR(footX - 0.055, footY - 0.08, footX + 0.055, footY + 0.02, const Radius.circular(0.035)),
        _shoe,
      );
      c.drawRRect(
        RRect.fromLTRBR(footX - 0.055, footY - 0.005, footX + 0.055, footY + 0.025, const Radius.circular(0.012)),
        _shoeSole,
      );
    }

    // --- seat + saddle bag
    c.drawRRect(RRect.fromLTRBR(-0.1, hipY - 0.01, 0.1, hipY + 0.04, const Radius.circular(0.03)), _dark);
    c.drawRRect(RRect.fromLTRBR(-0.06, hipY + 0.04, 0.06, hipY + 0.12, const Radius.circular(0.025)), _bag);

    // --- shorts
    c.drawRRect(RRect.fromLTRBR(-0.19, hipY - 0.13, 0.19, hipY + 0.03, const Radius.circular(0.08)), _shorts);

    // --- arms (behind torso edges)
    final sway = math.sin(pedal) * 0.012;
    for (var side = -1; side <= 1; side += 2) {
      final sh = Offset(side * 0.2 + rock * 0.5, shoulderY + 0.06);
      final hand = Offset(side * 0.29 + steer, -1.17 + d * 0.04);
      final elbow = Offset(side * (0.3 + d * 0.05), (sh.dy + hand.dy) * 0.5 + 0.02 + side * sway);
      c.drawLine(elbow, hand, _arm);
      c.drawLine(sh, elbow, _sleeve);
      c.drawCircle(hand, 0.045, _dark); // gloves
    }

    // --- torso / back (rocks around the hips)
    c.save();
    c.translate(rock * 0.5, 0);
    _path
      ..reset()
      ..moveTo(-0.17, hipY - 0.08)
      ..quadraticBezierTo(-0.24, (hipY + shoulderY) * 0.5, -0.22, shoulderY + 0.03)
      ..quadraticBezierTo(0, shoulderY - 0.08, 0.22, shoulderY + 0.03)
      ..quadraticBezierTo(0.24, (hipY + shoulderY) * 0.5, 0.17, hipY - 0.08)
      ..quadraticBezierTo(0, hipY - 0.02, -0.17, hipY - 0.08)
      ..close();
    c.drawPath(_path, _torso);
    c.drawPath(_path, _torsoShade);
    // Jersey back pockets.
    final py = hipY - 0.17;
    c.drawLine(Offset(-0.17, py), Offset(0.17, py), _pocket);
    c.drawLine(Offset(-0.06, py), Offset(-0.06, hipY - 0.07), _pocket);
    c.drawLine(Offset(0.06, py), Offset(0.06, hipY - 0.07), _pocket);
    // Accent stripe and number panel.
    final my = shoulderY + (hipY - shoulderY) * 0.42;
    c.drawRect(Rect.fromLTRB(-0.215, my - 0.025, 0.215, my + 0.025), _stripe);
    final ny = shoulderY + (hipY - shoulderY) * 0.7;
    c.drawRRect(RRect.fromLTRBR(-0.075, ny - 0.05, 0.075, ny + 0.05, const Radius.circular(0.012)), _number);
    c.drawRect(Rect.fromLTRB(-0.012, ny - 0.035, 0.012, ny + 0.035), _vent);
    // Spine shading.
    c.drawLine(Offset(0, shoulderY + 0.05), Offset(0, hipY - 0.1), _shinShade);

    // --- neck + head
    c.drawRect(Rect.fromLTRB(-0.045, headY + 0.05, 0.045, shoulderY + 0.02), _neck);
    c.drawOval(Rect.fromLTRB(-0.1, headY - 0.06, 0.1, headY + 0.1), _hair);
    // Helmet with vents.
    final hr = Rect.fromLTRB(-0.13, headY - 0.13, 0.13, headY + 0.07);
    c.drawOval(hr, _helmet);
    for (var i = -1; i <= 1; i++) {
      c.drawRRect(
        RRect.fromLTRBR(i * 0.055 - 0.014, headY - 0.1, i * 0.055 + 0.014, headY + 0.0, const Radius.circular(0.01)),
        _vent,
      );
    }
    c.drawRect(Rect.fromLTRB(-0.12, headY + 0.03, 0.12, headY + 0.055), _stripe);
    // Specular highlight on the helmet shell.
    c.drawOval(Rect.fromLTRB(-0.085, headY - 0.125, -0.01, headY - 0.085), _spec);
    c.restore();

    c.restore();

    if (shield) {
      final pulse = 1 + math.sin(time * 6) * 0.03;
      c.save();
      c.translate(0, -0.9);
      c.scale(pulse, pulse * 1.05);
      c.drawCircle(Offset.zero, 1.05, _shield);
      c.drawCircle(Offset.zero, 1.05, _shieldRim);
      c.restore();
    }
  }
}
