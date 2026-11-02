// Shared drawing primitives for the Pedal Escape brand art: palette, the
// bicycle + rider figure, coins, lightning, clouds and small vector helpers.
//
// All drawing is pure dart:ui so it can run inside `flutter test`.

import 'dart:math' as math;
import 'dart:ui';

/// Brand palette.
abstract final class Brand {
  static const navy = Color(0xFF0E0B2A);
  static const purple = Color(0xFF2A1B5E);
  static const orange = Color(0xFFFF7A1A);
  static const coral = Color(0xFFFF4D6D);
  static const yellow = Color(0xFFFFD23F);
  static const gold = Color(0xFFFFC530);
  static const teal = Color(0xFF16C2B0);
  static const white = Color(0xFFFFFFFF);

  // Derived tones used for shading.
  static const navyDeep = Color(0xFF07051A);
  static const purpleMid = Color(0xFF3D2A7D);
  static const lilac = Color(0xFF8E6BD8);
  static const sunCore = Color(0xFFFFF4C2);
  static const goldDark = Color(0xFFC98400);
}

Color withAlpha(Color c, double a) => c.withValues(alpha: a.clamp(0.0, 1.0));

Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;

Offset polar(double r, double a) => Offset(math.cos(a) * r, math.sin(a) * r);

Offset unit(Offset o) => o / o.distance;

/// Perpendicular (rotated +90deg in a y-down coordinate system).
Offset perp(Offset o) => Offset(-o.dy, o.dx);

Paint fill(Color c) => Paint()
  ..color = c
  ..isAntiAlias = true;

Paint stroke(Color c, double w, {StrokeCap cap = StrokeCap.round}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = cap
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

Paint blurred(Paint p, double sigma) => p..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

/// Two-bone inverse kinematics: returns the joint between [a] and [c] for
/// segment lengths [l1], [l2], choosing the solution on the side of [prefer].
Offset solveJoint(Offset a, Offset c, double l1, double l2, Offset prefer) {
  final d = c - a;
  final dist = d.distance.clamp((l1 - l2).abs() + 1e-3, l1 + l2 - 1e-3);
  final u = unit(d);
  final x = (l1 * l1 - l2 * l2 + dist * dist) / (2 * dist);
  final h = math.sqrt(math.max(0, l1 * l1 - x * x));
  var n = perp(u);
  if (n.dx * prefer.dx + n.dy * prefer.dy < 0) n = -n;
  return a + u * x + n * h;
}

/// Draws a tapered capsule from [a] (radius [ra]) to [b] (radius [rb]).
void drawLimb(Canvas c, Offset a, Offset b, double ra, double rb, Paint p) {
  final u = unit(b - a);
  final n = perp(u);
  final path = Path()
    ..moveTo((a + n * ra).dx, (a + n * ra).dy)
    ..lineTo((b + n * rb).dx, (b + n * rb).dy)
    ..lineTo((b - n * rb).dx, (b - n * rb).dy)
    ..lineTo((a - n * ra).dx, (a - n * ra).dy)
    ..close();
  c.drawPath(path, p);
  c.drawCircle(a, ra, p);
  c.drawCircle(b, rb, p);
}

Path smoothClosed(List<Offset> pts) {
  // Closed Catmull-Rom spline through pts.
  final path = Path();
  final n = pts.length;
  path.moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n];
    final p1 = pts[i];
    final p2 = pts[(i + 1) % n];
    final p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  path.close();
  return path;
}

// ---------------------------------------------------------------------------
// Bicycle + rider
// ---------------------------------------------------------------------------

/// Colours for every part of the figure. [RiderLook.mono] paints a flat
/// silhouette (used for icons and for the rim-light masks).
class RiderLook {
  const RiderLook({
    required this.tire,
    required this.tireHighlight,
    required this.rim,
    required this.rimEdge,
    required this.rimDecal,
    required this.spoke,
    required this.hub,
    required this.frame,
    required this.frameHighlight,
    required this.frameDecal,
    required this.component,
    required this.componentLight,
    required this.saddle,
    required this.chain,
    required this.skin,
    required this.skinShade,
    required this.jersey,
    required this.jerseyStripe,
    required this.shorts,
    required this.shoe,
    required this.shoeAccent,
    required this.sock,
    required this.glove,
    required this.helmet,
    required this.helmetStripe,
    required this.visor,
    required this.visorGlint,
    required this.bottle,
    this.mono = false,
    this.farShade = 0.42,
  });

  factory RiderLook.mono(Color c) => RiderLook(
        tire: c,
        tireHighlight: c,
        rim: c,
        rimEdge: c,
        rimDecal: c,
        spoke: c,
        hub: c,
        frame: c,
        frameHighlight: c,
        frameDecal: c,
        component: c,
        componentLight: c,
        saddle: c,
        chain: c,
        skin: c,
        skinShade: c,
        jersey: c,
        jerseyStripe: c,
        shorts: c,
        shoe: c,
        shoeAccent: c,
        sock: c,
        glove: c,
        helmet: c,
        helmetStripe: c,
        visor: c,
        visorGlint: c,
        bottle: c,
        mono: true,
        farShade: 0,
      );

  /// The hero look used on the feature graphic.
  static const hero = RiderLook(
    tire: Color(0xFF17122E),
    tireHighlight: Color(0xFF4A3D73),
    rim: Color(0xFF221A45),
    rimEdge: Color(0xFFB9B3D6),
    rimDecal: Brand.teal,
    spoke: Color(0xFFCFCBE6),
    hub: Color(0xFFE6E3F5),
    frame: Brand.yellow,
    frameHighlight: Color(0xFFFFF3B8),
    frameDecal: Brand.navy,
    component: Color(0xFF1C1736),
    componentLight: Color(0xFFA8A3C4),
    saddle: Color(0xFF15112B),
    chain: Color(0xFF6E688C),
    skin: Color(0xFFD99268),
    skinShade: Color(0xFFA9603F),
    jersey: Brand.coral,
    jerseyStripe: Brand.white,
    shorts: Color(0xFF1A1440),
    shoe: Brand.white,
    shoeAccent: Brand.coral,
    sock: Brand.white,
    glove: Color(0xFF1A1440),
    helmet: Brand.teal,
    helmetStripe: Brand.white,
    visor: Color(0xFF120D2C),
    visorGlint: Brand.orange,
    bottle: Brand.teal,
  );

  final Color tire, tireHighlight, rim, rimEdge, rimDecal, spoke, hub;
  final Color frame, frameHighlight, frameDecal, component, componentLight, saddle, chain;
  final Color skin, skinShade, jersey, jerseyStripe, shorts, shoe, shoeAccent, sock, glove;
  final Color helmet, helmetStripe, visor, visorGlint, bottle;
  final bool mono;

  /// How much far-side limbs are darkened (0 = not at all).
  final double farShade;
}

/// A road bike with a racing cyclist, side view, facing +x.
///
/// Local units are roughly millimetres: rear axle at (0,0), front axle at
/// (1010,0), y grows downwards. Use [bounds] to fit it into a scene.
class BikeRider {
  BikeRider({this.crank = 0.62, this.wheelPhase = 0.0, this.withRider = true});

  /// Near-side crank angle in radians (0 = pointing forward, y-down).
  final double crank;
  final double wheelPhase;
  final bool withRider;

  static const Rect bounds = Rect.fromLTRB(-365, -1225, 1375, 365);
  static const Rect bikeBounds = Rect.fromLTRB(-365, -660, 1375, 365);

  // --- Geometry ------------------------------------------------------------
  static const rearAxle = Offset(0, 0);
  static const frontAxle = Offset(1010, 0);
  static const wheelR = 340.0;
  static const bb = Offset(420, 70);
  static final Offset _seatDir = Offset(-math.cos(73.5 * math.pi / 180), -math.sin(73.5 * math.pi / 180));
  static final Offset _headDir = Offset(-math.cos(72 * math.pi / 180), -math.sin(72 * math.pi / 180));

  static Offset get seatTop => bb + _seatDir * 520;
  static Offset get seatPoint => bb + _seatDir * 705;
  static Offset get headBottom => frontAxle + _headDir * 405;
  static Offset get headTop => headBottom + _headDir * 150;
  static Offset get steererTop => headTop + _headDir * 48;
  static Offset get stemEnd => steererTop + const Offset(118, -10);
  static Offset get hood => stemEnd + const Offset(84, -14);

  static const crankLen = 172.0;
  static const ringR = 108.0;
  static const cogR = 46.0;

  Offset get nearPedal => bb + polar(crankLen, crank);
  Offset get farPedal => bb - polar(crankLen, crank);

  // Rider skeleton.
  static Offset get hip => seatPoint + const Offset(-18, -58);
  static final double _torsoA = -32 * math.pi / 180;
  static Offset get shoulder => hip + polar(565, _torsoA);
  static Offset get headCenter => shoulder + const Offset(140, -100);

  static const thigh = 445.0, shin = 455.0, upperArm = 295.0, forearm = 285.0;

  static Offset ankleFor(Offset pedal) => pedal + const Offset(-38, -62);

  /// Paints the figure. When [silhouette] is set, purely decorative thin
  /// parts (spokes, chain links, decals) are skipped so the result can be used
  /// as a lighting mask.
  void paint(Canvas c, RiderLook look, {bool silhouette = false}) {
    final far = look.farShade;
    Color shadeFar(Color col) => far == 0 ? col : mix(col, Brand.navy, far);

    if (withRider) {
      _arm(c, look, far: true, shade: shadeFar);
      _leg(c, look, farPedal, shade: shadeFar);
    }
    _crankArm(c, look, farPedal, shadeFar(look.component), shadeFar(look.componentLight), look.mono);
    _wheel(c, look, rearAxle, silhouette);
    _wheel(c, look, frontAxle, silhouette);
    _frame(c, look, silhouette);
    _drivetrain(c, look, silhouette);
    if (withRider) {
      _torso(c, look, silhouette);
      _head(c, look, silhouette);
    }
    _crankArm(c, look, nearPedal, look.component, look.componentLight, look.mono);
    if (withRider) {
      _leg(c, look, nearPedal, shade: (x) => x);
      _arm(c, look, far: false, shade: (x) => x);
    } else {
      _pedal(c, look, nearPedal, look.component);
    }
  }

  // --- Parts ---------------------------------------------------------------

  void _wheel(Canvas c, RiderLook look, Offset center, bool silhouette) {
    // Tyre.
    c.drawCircle(center, 322, stroke(look.tire, 38));
    if (!look.mono) {
      // Subtle tread highlight on the upper side.
      final hl = stroke(withAlpha(look.tireHighlight, 0.9), 5);
      c.drawArc(Rect.fromCircle(center: center, radius: 336), math.pi * 1.08, math.pi * 0.84, false, hl);
    }
    // Deep-section rim.
    c.drawCircle(center, 281, stroke(look.rim, 46));
    if (!look.mono) {
      c.drawCircle(center, 303, stroke(look.rimEdge, 4));
      c.drawCircle(center, 258, stroke(withAlpha(look.rimEdge, 0.35), 2.5));
      final decal = stroke(look.rimDecal, 14, cap: StrokeCap.butt);
      final r = Rect.fromCircle(center: center, radius: 281);
      for (final a in [0.35, 0.35 + math.pi]) {
        c.drawArc(r, wheelPhase + a, 0.85, false, decal);
      }
    }
    if (!silhouette) {
      // Tangentially laced spokes.
      final sp = stroke(look.spoke, look.mono ? 5 : 4.2);
      for (var i = 0; i < 24; i++) {
        final a = wheelPhase + i * math.pi * 2 / 24;
        final side = i.isEven ? 1 : -1;
        final h = center + polar(30, a);
        final rimP = center + polar(258, a + side * 0.42);
        c.drawLine(h, rimP, sp);
      }
    }
    // Hub.
    c.drawCircle(center, 40, fill(look.hub));
    if (!look.mono) {
      c.drawCircle(center, 40, stroke(look.componentLight, 3));
      c.drawCircle(center, 15, fill(look.component));
    }
  }

  void _tube(Canvas c, RiderLook look, Offset a, Offset b, double w, {Color? color}) {
    c.drawLine(a, b, stroke(color ?? look.frame, w));
    if (!look.mono) {
      final u = unit(b - a);
      var n = perp(u);
      if (n.dy > 0) n = -n; // highlight on the upper side
      final o = n * (w * 0.26);
      c.drawLine(a + o + u * (w * 0.3), b + o - u * (w * 0.3),
          stroke(withAlpha(look.frameHighlight, 0.75), w * 0.2));
    }
  }

  void _frame(Canvas c, RiderLook look, bool silhouette) {
    final ttStart = bb + _seatDir * 498;
    final ttEnd = headTop - _headDir * 22;
    final dtEnd = headBottom + _headDir * 30;
    final ssStart = bb + _seatDir * 488;

    // Stays.
    _tube(c, look, ssStart, rearAxle + const Offset(8, -6), 20);
    _tube(c, look, bb, rearAxle + const Offset(6, 4), 24);
    // Rear dropout.
    c.drawCircle(rearAxle, 30, fill(look.frame));

    // Fork (slightly raked) and head tube.
    final fork = Path()
      ..moveTo(headBottom.dx, headBottom.dy)
      ..quadraticBezierTo(frontAxle.dx - 40, frontAxle.dy - 140, frontAxle.dx + 6, frontAxle.dy - 4);
    c.drawPath(fork, stroke(look.frame, 26));
    c.drawCircle(frontAxle, 24, fill(look.frame));
    if (!look.mono) {
      final hl = Path()
        ..moveTo(headBottom.dx + 6, headBottom.dy + 20)
        ..quadraticBezierTo(frontAxle.dx - 26, frontAxle.dy - 140, frontAxle.dx + 12, frontAxle.dy - 40);
      c.drawPath(hl, stroke(withAlpha(look.frameHighlight, 0.7), 5));
    }

    // Main triangle.
    _tube(c, look, bb, dtEnd, 46); // down tube (oversized)
    _tube(c, look, ttStart, ttEnd, 32); // top tube
    _tube(c, look, bb, seatTop, 34); // seat tube
    _tube(c, look, headBottom + _headDir * -12, headTop, 44); // head tube

    if (!look.mono && !silhouette) {
      // Down tube decal: a bold stripe + chevrons.
      final u = unit(dtEnd - bb);
      final n = perp(u);
      final p0 = bb + u * 190;
      final p1 = bb + u * 470;
      c.drawLine(p0, p1, stroke(look.frameDecal, 16, cap: StrokeCap.butt));
      final chev = stroke(Brand.coral, 8, cap: StrokeCap.butt);
      for (var k = 0; k < 3; k++) {
        final m = bb + u * (500 + k * 34.0);
        c.drawLine(m + n * 14, m + u * 18, chev);
        c.drawLine(m - n * 14, m + u * 18, chev);
      }
      // Head-tube badge.
      c.drawCircle(headBottom + _headDir * 80, 11, fill(Brand.coral));
    }

    // Bottle cage + bottle on the down tube.
    {
      final u = unit(dtEnd - bb);
      var n = perp(u);
      if (n.dy > 0) n = -n;
      final a = bb + u * 150 + n * 52;
      final b = bb + u * 340 + n * 52;
      drawLimb(c, a, b, 30, 30, fill(look.bottle));
      c.drawLine(b + u * 18, b + u * 42, stroke(look.mono ? look.bottle : look.component, 26));
      if (!look.mono) {
        c.drawLine(a + n * 14 + u * 8, b + n * 14, stroke(withAlpha(Brand.white, 0.55), 6));
        c.drawLine(a - n * 10, b - n * 10, stroke(withAlpha(Brand.navy, 0.25), 8));
      }
    }

    // Seat post + saddle.
    _tube(c, look, seatTop, seatPoint, 22, color: look.mono ? look.frame : look.componentLight);
    final s = seatPoint + const Offset(-6, -16);
    final saddle = smoothClosed([
      s + const Offset(-128, -14),
      s + const Offset(-90, -32),
      s + const Offset(10, -24),
      s + const Offset(118, -14),
      s + const Offset(150, -4),
      s + const Offset(130, 10),
      s + const Offset(10, 12),
      s + const Offset(-112, 14),
    ]);
    c.drawPath(saddle, fill(look.saddle));
    if (!look.mono) {
      c.drawLine(s + const Offset(-96, -24), s + const Offset(80, -18), stroke(withAlpha(Brand.white, 0.25), 4));
    }

    // Stem + drop handlebar.
    c.drawLine(headTop, steererTop, stroke(look.component, 34));
    c.drawLine(steererTop + const Offset(-4, 6), stemEnd, stroke(look.component, 30));
    final e = stemEnd;
    final bar = Path()
      ..moveTo(e.dx, e.dy)
      ..cubicTo(e.dx + 60, e.dy - 6, e.dx + 104, e.dy + 6, e.dx + 106, e.dy + 60)
      ..cubicTo(e.dx + 108, e.dy + 116, e.dx + 70, e.dy + 142, e.dx + 22, e.dy + 134);
    c.drawPath(bar, stroke(look.component, 24));
    // Brake hood + lever.
    final hoodPath = smoothClosed([
      e + const Offset(62, -6),
      e + const Offset(88, -34),
      e + const Offset(112, -28),
      e + const Offset(118, 4),
      e + const Offset(102, 30),
    ]);
    c.drawPath(hoodPath, fill(look.component));
    final lever = Path()
      ..moveTo(e.dx + 112, e.dy + 6)
      ..quadraticBezierTo(e.dx + 130, e.dy + 80, e.dx + 112, e.dy + 128);
    c.drawPath(lever, stroke(look.mono ? look.component : look.componentLight, 12));
    if (!look.mono) {
      c.drawCircle(e, 15, fill(look.componentLight));
    }
    // Rim brake calipers.
    c.drawLine(headBottom + const Offset(14, 30), headBottom + const Offset(44, 86),
        stroke(look.mono ? look.component : look.componentLight, 14));
    final bridge = rearAxle + unit(ssStart - rearAxle) * 300;
    c.drawLine(bridge, bridge + const Offset(-34, 40), stroke(look.mono ? look.component : look.componentLight, 14));
  }

  void _drivetrain(Canvas c, RiderLook look, bool silhouette) {
    // Rear cassette + derailleur.
    c.drawCircle(rearAxle, cogR, fill(look.component));
    if (!look.mono) {
      for (var r = 18.0; r < cogR; r += 9) {
        c.drawCircle(rearAxle, r, stroke(look.componentLight, 2));
      }
    }
    final jockeyA = rearAxle + const Offset(16, 92);
    final jockeyB = rearAxle + const Offset(-2, 160);
    c.drawLine(rearAxle + const Offset(10, 20), jockeyB, stroke(look.component, 16));
    c.drawCircle(jockeyA, 15, fill(look.mono ? look.component : look.componentLight));
    c.drawCircle(jockeyB, 15, fill(look.mono ? look.component : look.componentLight));

    // Chain.
    final chainP = Path()
      ..moveTo(bb.dx + 4, bb.dy - ringR - 2)
      ..lineTo(rearAxle.dx + 4, rearAxle.dy - cogR - 2)
      ..arcToPoint(rearAxle + const Offset(-cogR + 2, 6), radius: const Radius.circular(cogR), clockwise: false)
      ..moveTo(bb.dx + 4, bb.dy + ringR + 2)
      ..lineTo(jockeyB.dx, jockeyB.dy + 14)
      ..moveTo(jockeyB.dx - 12, jockeyB.dy - 4)
      ..lineTo(jockeyA.dx - 14, jockeyA.dy - 4);
    c.drawPath(chainP, stroke(look.chain, 9));
    if (!look.mono && !silhouette) {
      final links = Paint()
        ..color = withAlpha(Brand.white, 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      final metrics = chainP.computeMetrics();
      for (final m in metrics) {
        for (var d = 0.0; d < m.length; d += 16) {
          final t = m.getTangentForOffset(d);
          if (t != null) c.drawCircle(t.position, 1.6, links);
        }
      }
    }

    // Chainring with teeth and a 5-arm spider.
    final teeth = Path();
    const nTeeth = 44;
    for (var i = 0; i < nTeeth; i++) {
      final a0 = crank + i * 2 * math.pi / nTeeth;
      final a1 = a0 + math.pi / nTeeth;
      final p0 = bb + polar(ringR, a0 - 0.02);
      final p1 = bb + polar(ringR + 11, a0 + 0.02);
      final p2 = bb + polar(ringR + 11, a1 - 0.02);
      final p3 = bb + polar(ringR, a1 + 0.02);
      if (i == 0) teeth.moveTo(p0.dx, p0.dy);
      teeth
        ..lineTo(p0.dx, p0.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);
    }
    teeth.close();
    c.drawPath(teeth, fill(look.mono ? look.component : look.componentLight));
    c.drawCircle(bb, ringR - 4, fill(look.component));
    if (!look.mono) {
      c.drawCircle(bb, ringR - 14, stroke(withAlpha(look.componentLight, 0.6), 3));
      final spider = fill(mix(look.component, look.componentLight, 0.35));
      for (var i = 0; i < 5; i++) {
        final a = crank + i * 2 * math.pi / 5;
        drawLimb(c, bb, bb + polar(ringR - 20, a), 16, 9, spider);
      }
      c.drawCircle(bb, 30, fill(look.componentLight));
      c.drawCircle(bb, 12, fill(look.component));
    }
  }

  void _crankArm(Canvas c, RiderLook look, Offset pedal, Color col, Color light, bool mono) {
    drawLimb(c, bb, pedal, 22, 16, fill(col));
    if (!mono) {
      c.drawLine(bb + unit(pedal - bb) * 20, pedal - unit(pedal - bb) * 12, stroke(withAlpha(light, 0.6), 5));
    }
    if (!withRider) _pedal(c, look, pedal, col);
  }

  void _pedal(Canvas c, RiderLook look, Offset pedal, Color col) {
    c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pedal, width: 92, height: 22), const Radius.circular(8)),
        fill(col));
  }

  void _leg(Canvas c, RiderLook look, Offset pedal, {required Color Function(Color) shade}) {
    final ankle = ankleFor(pedal);
    final knee = solveJoint(hip, ankle, thigh, shin, const Offset(1, -0.4));
    final skin = fill(shade(look.skin));
    _pedal(c, look, pedal, shade(look.component));
    // Shin with calf bulge.
    drawLimb(c, knee, ankle, 58, 36, skin);
    final calfDir = unit(ankle - knee);
    var back = perp(calfDir);
    if (back.dx > 0) back = -back;
    c.drawOval(
        Rect.fromCenter(center: knee + calfDir * 150 + back * 22, width: 120, height: 120), skin);
    // Sock.
    drawLimb(c, ankle - calfDir * 80, ankle, 38, 36, fill(shade(look.sock)));
    // Thigh + shorts.
    drawLimb(c, hip, knee, 86, 60, skin);
    final shortsEnd = hip + (knee - hip) * 0.72;
    drawLimb(c, hip, shortsEnd, 94, 68, fill(shade(look.shorts)));
    if (!look.mono) {
      c.drawLine(shortsEnd + perp(unit(knee - hip)) * 66, shortsEnd - perp(unit(knee - hip)) * 66,
          stroke(shade(look.jersey), 12, cap: StrokeCap.butt));
    }
    // Shoe.
    final heel = ankle + const Offset(-56, 22);
    final toe = pedal + const Offset(96, -2);
    final shoe = smoothClosed([
      heel + const Offset(0, -30),
      ankle + const Offset(30, -36),
      toe + const Offset(-20, -26),
      toe + const Offset(4, -4),
      toe + const Offset(-10, 12),
      heel + const Offset(10, 18),
    ]);
    c.drawPath(shoe, fill(shade(look.shoe)));
    if (!look.mono) {
      c.drawLine(heel + const Offset(8, 8), toe + const Offset(-12, 2), stroke(shade(look.shoeAccent), 9));
      c.drawLine(ankle + const Offset(20, -24), toe + const Offset(-40, -18), stroke(shade(look.shoeAccent), 6));
    }
  }

  void _arm(Canvas c, RiderLook look, {required bool far, required Color Function(Color) shade}) {
    final sh = far ? shoulder + const Offset(-30, 14) : shoulder;
    final hand = far ? hood + const Offset(-14, 6) : hood;
    final elbow = solveJoint(sh, hand, upperArm, forearm, const Offset(-0.45, 1));
    final skin = fill(shade(look.skin));
    drawLimb(c, elbow, hand, 42, 32, skin);
    drawLimb(c, sh, elbow, 56, 44, skin);
    // Sleeve.
    final sleeveEnd = sh + (elbow - sh) * 0.55;
    drawLimb(c, sh, sleeveEnd, 66, 52, fill(shade(look.jersey)));
    if (!look.mono) {
      final u = unit(elbow - sh);
      c.drawLine(sleeveEnd + perp(u) * 50, sleeveEnd - perp(u) * 50,
          stroke(shade(look.jerseyStripe), 12, cap: StrokeCap.butt));
    }
    // Glove.
    c.drawCircle(hand + const Offset(4, -4), 38, fill(shade(look.glove)));
  }

  void _torso(Canvas c, RiderLook look, bool silhouette) {
    final u = unit(shoulder - hip);
    var nb = perp(u);
    if (nb.dy > 0) nb = -nb; // back side (up)
    final mid = hip + (shoulder - hip) * 0.5;
    final pts = <Offset>[
      hip - u * 70 + nb * 20, // seat
      hip + nb * 92,
      mid + nb * 128, // arched back
      shoulder + nb * 104 - u * 10,
      shoulder + u * 62 + nb * 40,
      shoulder + u * 52 - nb * 70, // chest
      mid - nb * 92 + u * 40,
      hip - nb * 92 + u * 40, // belly
      hip - nb * 70 - u * 30,
    ];
    final torso = smoothClosed(pts);
    c.drawPath(torso, fill(look.jersey));
    if (!look.mono && !silhouette) {
      c.save();
      c.clipPath(torso);
      // Side panel stripes in brand colours.
      final s0 = hip + nb * 30 - u * 80;
      final s1 = shoulder + nb * 20 + u * 80;
      c.drawLine(s0, s1, stroke(look.jerseyStripe, 30, cap: StrokeCap.butt));
      c.drawLine(s0 - nb * 36, s1 - nb * 36, stroke(Brand.yellow, 14, cap: StrokeCap.butt));
      // Lower shading.
      c.drawLine(hip - nb * 110 - u * 100, shoulder - nb * 110 + u * 100, stroke(withAlpha(Brand.navy, 0.28), 70));
      c.restore();
      // Shorts waist.
      drawLimb(c, hip - u * 40, hip + u * 30, 86, 86, fill(look.shorts));
    } else {
      drawLimb(c, hip - u * 40, hip + u * 30, 86, 86, fill(look.shorts));
    }
  }

  void _head(Canvas c, RiderLook look, bool silhouette) {
    final h = headCenter;
    // Neck.
    drawLimb(c, shoulder + const Offset(30, -10), h + const Offset(-10, 40), 50, 44, fill(look.skinShade));
    // Head / face.
    c.drawCircle(h, 98, fill(look.skin));
    final face = smoothClosed([
      h + const Offset(60, -40),
      h + const Offset(108, 6),
      h + const Offset(102, 40), // nose/mouth
      h + const Offset(70, 92), // chin
      h + const Offset(0, 90),
      h + const Offset(0, 0),
    ]);
    c.drawPath(face, fill(look.skin));
    if (!look.mono) {
      c.drawOval(Rect.fromCenter(center: h + const Offset(-6, 18), width: 40, height: 54), fill(look.skinShade));
    }
    // Sunglasses.
    final glasses = smoothClosed([
      h + const Offset(30, -8),
      h + const Offset(110, -10),
      h + const Offset(112, 22),
      h + const Offset(66, 30),
      h + const Offset(26, 16),
    ]);
    c.drawPath(glasses, fill(look.visor));
    if (!look.mono) {
      c.drawLine(h + const Offset(56, -2), h + const Offset(100, -4), stroke(withAlpha(look.visorGlint, 0.95), 7));
      c.drawLine(h + const Offset(-20, 0), h + const Offset(30, 0), stroke(look.visor, 8));
    }
    // Aero helmet.
    final helmet = smoothClosed([
      h + const Offset(-168, -14), // tail
      h + const Offset(-120, -96),
      h + const Offset(-20, -138),
      h + const Offset(80, -110),
      h + const Offset(122, -42),
      h + const Offset(100, -20),
      h + const Offset(20, -36),
      h + const Offset(-60, -10),
    ]);
    c.drawPath(helmet, fill(look.helmet));
    if (!look.mono && !silhouette) {
      c.save();
      c.clipPath(helmet);
      c.drawLine(h + const Offset(-170, -40), h + const Offset(120, -90), stroke(look.helmetStripe, 16));
      c.drawLine(h + const Offset(-170, 10), h + const Offset(120, -40), stroke(withAlpha(Brand.navy, 0.3), 26));
      for (final x in [-90.0, -30.0, 30.0]) {
        c.drawLine(h + Offset(x, -100), h + Offset(x + 40, -70), stroke(withAlpha(Brand.navy, 0.55), 10));
      }
      c.restore();
      // Strap.
      c.drawLine(h + const Offset(-20, -20), h + const Offset(30, 70), stroke(look.helmetStripe, 6));
    }
  }
}

/// Paints [fig] with [look] plus a rim light on the edges facing [toLight]
/// and a soft core shadow on the opposite edges.
void paintLitFigure(
  Canvas c,
  BikeRider fig,
  RiderLook look, {
  required Offset toLight,
  required Color rimColor,
  required double rimWidth,
  Color? shadeColor,
  double shadeWidth = 0,
  double rimBlur = 0,
}) {
  final b = BikeRider.bounds.inflate(80);
  final l = unit(toLight);
  final mono = RiderLook.mono(Brand.navy);
  c.saveLayer(b, Paint());
  fig.paint(c, look);

  void edge(Color color, Offset shift, double blur) {
    c.saveLayer(b, Paint()..blendMode = BlendMode.srcATop);
    fig.paint(c, RiderLook.mono(color), silhouette: true);
    c.saveLayer(b, Paint()..blendMode = BlendMode.dstOut);
    c.translate(shift.dx, shift.dy);
    if (blur > 0) {
      c.saveLayer(b.shift(-shift), Paint()..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur));
      fig.paint(c, mono, silhouette: true);
      c.restore();
    } else {
      fig.paint(c, mono, silhouette: true);
    }
    c.restore();
    c.restore();
  }

  if (shadeColor != null && shadeWidth > 0) edge(shadeColor, l * shadeWidth, shadeWidth * 0.5);
  edge(rimColor, -l * rimWidth, rimBlur);
  c.restore();
}

// ---------------------------------------------------------------------------
// Coins, sparkles, lightning, clouds
// ---------------------------------------------------------------------------

/// A spinning gold coin. [spin] in (0..1] squashes it horizontally.
void drawCoin(Canvas c, Offset center, double r, {double spin = 1, double glow = 1}) {
  if (glow > 0) {
    c.drawCircle(
        center,
        r * 2.6,
        Paint()
          ..shader = Gradient.radial(center, r * 2.6, [
            withAlpha(Brand.yellow, 0.55 * glow),
            withAlpha(Brand.orange, 0.18 * glow),
            withAlpha(Brand.orange, 0),
          ], [0, 0.45, 1]));
  }
  final w = r * 2 * spin;
  final edgeOffset = Offset(r * 0.16 * (1 - spin * 0.4), 0);
  c.drawOval(Rect.fromCenter(center: center + edgeOffset, width: w, height: r * 2), fill(Brand.goldDark));
  final face = Rect.fromCenter(center: center, width: w, height: r * 2);
  c.drawOval(
      face,
      Paint()
        ..shader = Gradient.linear(face.topLeft, face.bottomRight, [
          const Color(0xFFFFF3B0),
          Brand.gold,
          const Color(0xFFE89A00),
        ], [0, 0.45, 1]));
  final inner = Rect.fromCenter(center: center, width: w * 0.74, height: r * 1.48);
  c.drawOval(inner, stroke(withAlpha(Brand.goldDark, 0.8), r * 0.09));
  // Embossed star.
  final star = Path();
  for (var i = 0; i < 10; i++) {
    final a = -math.pi / 2 + i * math.pi / 5;
    final rr = i.isEven ? r * 0.5 : r * 0.22;
    final p = center + Offset(math.cos(a) * rr * spin, math.sin(a) * rr);
    if (i == 0) {
      star.moveTo(p.dx, p.dy);
    } else {
      star.lineTo(p.dx, p.dy);
    }
  }
  star.close();
  c.drawPath(star.shift(Offset(r * 0.04, r * 0.05)), fill(withAlpha(Brand.goldDark, 0.9)));
  c.drawPath(star, fill(const Color(0xFFFFE27A)));
  // Specular highlight.
  c.drawOval(
      Rect.fromCenter(center: center + Offset(-w * 0.18, -r * 0.42), width: w * 0.36, height: r * 0.26),
      fill(withAlpha(Brand.white, 0.55)));
}

void drawSparkle(Canvas c, Offset p, double size, {Color color = Brand.white, double alpha = 1}) {
  c.drawCircle(p, size * 1.2, blurred(fill(withAlpha(color, 0.45 * alpha)), size * 0.6));
  final path = Path()
    ..moveTo(p.dx, p.dy - size)
    ..quadraticBezierTo(p.dx, p.dy, p.dx + size, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + size)
    ..quadraticBezierTo(p.dx, p.dy, p.dx - size, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - size)
    ..close();
  c.drawPath(path, fill(withAlpha(color, alpha)));
}

/// A jagged lightning bolt from [start] to [end] with optional branches.
class LightningBolt {
  LightningBolt(this.start, this.end, {int seed = 1, this.width = 1, int branches = 2, double jag = 0.22}) {
    final rnd = math.Random(seed);
    main = _jagged(rnd, start, end, 6, jag);
    for (var b = 0; b < branches; b++) {
      final idx = (main.length * (0.25 + 0.45 * rnd.nextDouble())).floor();
      final from = main[idx];
      final dir = unit(end - start);
      final side = rnd.nextBool() ? 1 : -1;
      final len = (end - start).distance * (0.18 + 0.2 * rnd.nextDouble());
      final to = from + (dir * 0.7 + perp(dir) * (0.75 * side)) * len;
      this.branches.add(_jagged(rnd, from, to, 4, jag * 1.1));
    }
  }

  final Offset start, end;
  final double width;
  late final List<Offset> main;
  final List<List<Offset>> branches = [];

  static List<Offset> _jagged(math.Random rnd, Offset a, Offset b, int depth, double jag) {
    var pts = [a, b];
    var amp = (b - a).distance * jag;
    for (var d = 0; d < depth; d++) {
      final next = <Offset>[pts.first];
      for (var i = 0; i < pts.length - 1; i++) {
        final p = pts[i], q = pts[i + 1];
        final m = (p + q) / 2;
        final n = perp(unit(q - p));
        next
          ..add(m + n * ((rnd.nextDouble() - 0.5) * amp))
          ..add(q);
      }
      pts = next;
      amp *= 0.55;
    }
    return pts;
  }

  Path _path(List<Offset> pts) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      p.lineTo(o.dx, o.dy);
    }
    return p;
  }

  void paint(Canvas c, {double intensity = 1}) {
    final w = width;
    final paths = [(_path(main), 1.0), for (final b in branches) (_path(b), 0.55)];
    for (final (p, k) in paths) {
      c.drawPath(p, blurred(stroke(withAlpha(Brand.lilac, 0.45 * intensity), 30 * w * k), 22 * w));
    }
    for (final (p, k) in paths) {
      c.drawPath(p, blurred(stroke(withAlpha(Brand.yellow, 0.85 * intensity), 11 * w * k), 5 * w));
    }
    for (final (p, k) in paths) {
      c.drawPath(p, stroke(withAlpha(const Color(0xFFFFFBEA), intensity), 3.6 * w * k));
    }
  }
}

/// A soft storm-cloud bank made of overlapping puffs.
void drawCloudBank(
  Canvas c, {
  required List<(Offset, double)> puffs,
  required Color top,
  required Color bottom,
  double blur = 0,
  Color? rim,
}) {
  var minY = double.infinity, maxY = -double.infinity;
  for (final (o, r) in puffs) {
    minY = math.min(minY, o.dy - r);
    maxY = math.max(maxY, o.dy + r);
  }
  final shader = Gradient.linear(Offset(0, minY), Offset(0, maxY), [top, bottom], [0.0, 0.85]);
  final path = Path();
  for (final (o, r) in puffs) {
    path.addOval(Rect.fromCircle(center: o, radius: r));
  }
  final p = Paint()..shader = shader;
  if (blur > 0) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
  // Draw puffs individually so overlaps never cancel.
  for (final (o, r) in puffs) {
    c.drawCircle(o, r, p);
  }
  if (rim != null) {
    for (final (o, r) in puffs) {
      c.drawArc(Rect.fromCircle(center: o, radius: r * 0.97), math.pi * 1.1, math.pi * 0.8, false,
          blurred(stroke(rim, r * 0.07), r * 0.05));
    }
  }
}

/// Deterministic ridge line for mountain silhouettes.
List<Offset> ridge({
  required double x0,
  required double x1,
  required double baseY,
  required double amp,
  required int seed,
  double step = 6,
  double sharp = 1,
}) {
  final rnd = math.Random(seed);
  final waves = List.generate(5, (i) {
    final f = (0.004 + rnd.nextDouble() * 0.006) * math.pow(1.9, i);
    return (f, rnd.nextDouble() * math.pi * 2, 1 / math.pow(1.8, i));
  });
  final pts = <Offset>[];
  for (var x = x0; x <= x1 + step; x += step) {
    var y = 0.0;
    for (final (f, ph, a) in waves) {
      y += math.sin(x * f + ph) * a;
    }
    // Sharpen peaks.
    final s = y.sign * math.pow(y.abs(), sharp).toDouble();
    pts.add(Offset(x, baseY - amp * (0.5 + 0.42 * s)));
  }
  return pts;
}
