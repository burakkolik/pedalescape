/// Fast ARGB int color helpers for the software renderer.
library;

import 'dart:ui';

abstract final class ColorUtils {
  static int argb(int a, int r, int g, int b) =>
      ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);

  static int fromColor(Color c) => c.toARGB32();

  static int lerp(int c1, int c2, double t) {
    final a1 = (c1 >> 24) & 0xFF, r1 = (c1 >> 16) & 0xFF, g1 = (c1 >> 8) & 0xFF, b1 = c1 & 0xFF;
    final a2 = (c2 >> 24) & 0xFF, r2 = (c2 >> 16) & 0xFF, g2 = (c2 >> 8) & 0xFF, b2 = c2 & 0xFF;
    return argb(
      (a1 + (a2 - a1) * t).round(),
      (r1 + (r2 - r1) * t).round(),
      (g1 + (g2 - g1) * t).round(),
      (b1 + (b2 - b1) * t).round(),
    );
  }

  /// Multiplies rgb channels by [f] (can brighten above 1, clamped).
  static int scale(int c, double f) {
    int ch(int v) {
      final x = (v * f).round();
      return x < 0 ? 0 : (x > 255 ? 255 : x);
    }

    return argb((c >> 24) & 0xFF, ch((c >> 16) & 0xFF), ch((c >> 8) & 0xFF), ch(c & 0xFF));
  }

  static int withAlpha(int c, double alpha) =>
      (c & 0x00FFFFFF) | (((alpha.clamp(0.0, 1.0) * 255).round()) << 24);

  static Color lerpColor(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  /// Darkens or lightens a Color by [amount] (-1..1).
  static Color shade(Color c, double amount) => amount >= 0
      ? Color.lerp(c, const Color(0xFFFFFFFF), amount)!
      : Color.lerp(c, const Color(0xFF000000), -amount)!;
}
