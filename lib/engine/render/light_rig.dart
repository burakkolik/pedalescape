/// Directional sun + hemispheric ambient + linear fog.
library;

import 'dart:math' as math;

import 'color_utils.dart';

class LightRig {
  /// Normalized direction pointing TOWARD the sun.
  double sunX = -0.35, sunY = 0.8, sunZ = -0.45;

  /// Sun intensity per channel (0..~1.4).
  double sunR = 1.0, sunG = 0.96, sunB = 0.88;

  /// Ambient intensity per channel.
  double ambR = 0.42, ambG = 0.45, ambB = 0.55;

  int fogColor = 0xFFBFD8F0;
  double fogStart = 40;
  double fogEnd = 230;

  /// Emissive surfaces keep this fraction of their color through fog.
  double emissiveFogResistance = 0.6;

  void setSunDirection(double x, double y, double z) {
    final l = math.sqrt(x * x + y * y + z * z);
    sunX = x / l;
    sunY = y / l;
    sunZ = z / l;
  }

  void setSunColor(int argb, double intensity) {
    sunR = ((argb >> 16) & 0xFF) / 255 * intensity;
    sunG = ((argb >> 8) & 0xFF) / 255 * intensity;
    sunB = (argb & 0xFF) / 255 * intensity;
  }

  void setAmbient(int argb, double intensity) {
    ambR = ((argb >> 16) & 0xFF) / 255 * intensity;
    ambG = ((argb >> 8) & 0xFF) / 255 * intensity;
    ambB = (argb & 0xFF) / 255 * intensity;
  }

  /// Copies all values from [o].
  void copyFrom(LightRig o) {
    sunX = o.sunX; sunY = o.sunY; sunZ = o.sunZ;
    sunR = o.sunR; sunG = o.sunG; sunB = o.sunB;
    ambR = o.ambR; ambG = o.ambG; ambB = o.ambB;
    fogColor = o.fogColor; fogStart = o.fogStart; fogEnd = o.fogEnd;
  }

  int fogged(int color, double depth) {
    final t = ((depth - fogStart) / (fogEnd - fogStart)).clamp(0.0, 1.0);
    return t <= 0 ? color : ColorUtils.lerp(color, fogColor, t);
  }
}
