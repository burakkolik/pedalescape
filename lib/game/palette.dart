import 'util.dart';

/// A full set of scene colors. Interpolated between key times of day into a
/// single mutable instance every frame (no allocations).
class Palette {
  int skyTop;
  int skyHorizon;
  int fog;
  int sun;
  int mountainFar;
  int mountainMid;
  int hills;
  int grassA;
  int grassB;
  int roadA;
  int roadB;
  int rumbleA;
  int rumbleB;
  int lane;
  int cloud;
  int spriteTint; // multiplied onto world sprites
  double light; // sprite brightness multiplier 0..1
  double night; // 0 day .. 1 full night

  Palette({
    this.skyTop = 0,
    this.skyHorizon = 0,
    this.fog = 0,
    this.sun = 0,
    this.mountainFar = 0,
    this.mountainMid = 0,
    this.hills = 0,
    this.grassA = 0,
    this.grassB = 0,
    this.roadA = 0,
    this.roadB = 0,
    this.rumbleA = 0,
    this.rumbleB = 0,
    this.lane = 0,
    this.cloud = 0,
    this.spriteTint = 0xffffffff,
    this.light = 1,
    this.night = 0,
  });

  void lerpFrom(Palette a, Palette b, double t) {
    skyTop = lerpColor(a.skyTop, b.skyTop, t);
    skyHorizon = lerpColor(a.skyHorizon, b.skyHorizon, t);
    fog = lerpColor(a.fog, b.fog, t);
    sun = lerpColor(a.sun, b.sun, t);
    mountainFar = lerpColor(a.mountainFar, b.mountainFar, t);
    mountainMid = lerpColor(a.mountainMid, b.mountainMid, t);
    hills = lerpColor(a.hills, b.hills, t);
    grassA = lerpColor(a.grassA, b.grassA, t);
    grassB = lerpColor(a.grassB, b.grassB, t);
    roadA = lerpColor(a.roadA, b.roadA, t);
    roadB = lerpColor(a.roadB, b.roadB, t);
    rumbleA = lerpColor(a.rumbleA, b.rumbleA, t);
    rumbleB = lerpColor(a.rumbleB, b.rumbleB, t);
    lane = lerpColor(a.lane, b.lane, t);
    cloud = lerpColor(a.cloud, b.cloud, t);
    spriteTint = lerpColor(a.spriteTint, b.spriteTint, t);
    light = lerpD(a.light, b.light, t);
    night = lerpD(a.night, b.night, t);
  }
}

final Palette _day = Palette(
  skyTop: 0xff2f7fe0,
  skyHorizon: 0xffbfe3ff,
  fog: 0xffc9e6fb,
  sun: 0xfffff6d8,
  mountainFar: 0xff8fb3d6,
  mountainMid: 0xff5f8fa8,
  hills: 0xff3f8a4a,
  grassA: 0xff5cb548,
  grassB: 0xff52a840,
  roadA: 0xff6b6e75,
  roadB: 0xff65686f,
  rumbleA: 0xffe8e8e8,
  rumbleB: 0xffd43a2f,
  lane: 0xfff5f5f0,
  cloud: 0xffffffff,
  spriteTint: 0xffffffff,
  light: 1.0,
  night: 0,
);

final Palette _sunset = Palette(
  skyTop: 0xff3b3f8f,
  skyHorizon: 0xffff9a5c,
  fog: 0xffe99c78,
  sun: 0xffffc070,
  mountainFar: 0xff9a6b8a,
  mountainMid: 0xff6c4a6e,
  hills: 0xff3d5a3a,
  grassA: 0xff6b9a3e,
  grassB: 0xff618f36,
  roadA: 0xff64606a,
  roadB: 0xff5e5a64,
  rumbleA: 0xffe9d8cc,
  rumbleB: 0xffc8392d,
  lane: 0xfff3e2cf,
  cloud: 0xffffc6a0,
  spriteTint: 0xffffd6bc,
  light: 0.85,
  night: 0.25,
);

final Palette _night = Palette(
  skyTop: 0xff050816,
  skyHorizon: 0xff1b2550,
  fog: 0xff141c3a,
  sun: 0xffdfe8ff,
  mountainFar: 0xff1d2547,
  mountainMid: 0xff151b36,
  hills: 0xff0f1d22,
  grassA: 0xff1d3b2a,
  grassB: 0xff193424,
  roadA: 0xff2c2f3a,
  roadB: 0xff292b35,
  rumbleA: 0xff8e93a8,
  rumbleB: 0xff7a2430,
  lane: 0xffc9cfe6,
  cloud: 0xff3a4570,
  spriteTint: 0xff6c78aa,
  light: 0.42,
  night: 1.0,
);

final Palette _dawn = Palette(
  skyTop: 0xff4a5fa8,
  skyHorizon: 0xffffc1a8,
  fog: 0xfff0c3b4,
  sun: 0xffffe0b0,
  mountainFar: 0xffa48fb0,
  mountainMid: 0xff76688f,
  hills: 0xff3f6a48,
  grassA: 0xff5fa64c,
  grassB: 0xff569a43,
  roadA: 0xff686a74,
  roadB: 0xff62646e,
  rumbleA: 0xffeee2dc,
  rumbleB: 0xffcf3c33,
  lane: 0xfff6ece6,
  cloud: 0xffffe2d6,
  spriteTint: 0xffffe2d8,
  light: 0.9,
  night: 0.2,
);

/// Key frames over one cycle: [time, palette]. Day dominates.
final List<(double, Palette)> _keys = [
  (0.00, _day),
  (0.42, _day),
  (0.55, _sunset),
  (0.64, _night),
  (0.84, _night),
  (0.93, _dawn),
  (1.00, _day),
];

/// Fills [out] with the palette for cycle time [t] in [0,1).
void paletteAt(double t, Palette out) {
  t = t - t.floorToDouble();
  for (var i = 0; i < _keys.length - 1; i++) {
    final a = _keys[i], b = _keys[i + 1];
    if (t >= a.$1 && t <= b.$1) {
      final span = b.$1 - a.$1;
      final f = span <= 0 ? 0.0 : (t - a.$1) / span;
      out.lerpFrom(a.$2, b.$2, easeInOut(f));
      return;
    }
  }
  out.lerpFrom(_day, _day, 0);
}
