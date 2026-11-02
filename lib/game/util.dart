import 'dart:math' as math;

/// Small, allocation-free helpers used in the hot game loop.

double clampD(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);

double lerpD(double a, double b, double t) => a + (b - a) * t;

/// Smooth ease in/out, t in [0,1].
double easeInOut(double t) => (1 - math.cos(math.pi * t)) * 0.5;

/// Frame-rate independent exponential approach factor.
double approach(double rate, double dt) => 1 - math.exp(-rate * dt);

/// Linear interpolation between two ARGB colors packed in ints.
int lerpColor(int a, int b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;
  final aa = (a >> 24) & 0xff, ar = (a >> 16) & 0xff, ag = (a >> 8) & 0xff, ab = a & 0xff;
  final ba = (b >> 24) & 0xff, br = (b >> 16) & 0xff, bg = (b >> 8) & 0xff, bb = b & 0xff;
  final na = (aa + (ba - aa) * t).round();
  final nr = (ar + (br - ar) * t).round();
  final ng = (ag + (bg - ag) * t).round();
  final nb = (ab + (bb - ab) * t).round();
  return (na << 24) | (nr << 16) | (ng << 8) | nb;
}

/// Multiplies the RGB channels of [c] by [f] (alpha untouched), clamped.
int shadeColor(int c, double f) {
  int ch(int v) {
    final n = (v * f).round();
    return n < 0 ? 0 : (n > 255 ? 255 : n);
  }

  return (c & 0xff000000) | (ch((c >> 16) & 0xff) << 16) | (ch((c >> 8) & 0xff) << 8) | ch(c & 0xff);
}

/// Replaces the alpha of [c] with [a] in [0,1].
int withAlpha(int c, double a) {
  final ai = (clampD(a, 0, 1) * 255).round();
  return (ai << 24) | (c & 0x00ffffff);
}

/// Cheap deterministic hash -> [0,1). Used for procedural scenery so that
/// nothing has to be stored in memory for roadside decoration.
double hash01(int n) {
  var x = n * 374761393 + 668265263;
  x = (x ^ (x >> 13)) * 1274126177;
  x = x ^ (x >> 16);
  return (x & 0x7fffffff) / 0x7fffffff;
}
