/// Reusable gradients (backgrounds, buttons, bars). Keeping them here lets
/// every screen share the same premium "storm at sunset" mood.
library;

import 'package:flutter/painting.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  /// Full-screen menu background (top = storm sky, bottom = deep night).
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2A1B5E), Color(0xFF17103D), AppColors.stormNavy],
    stops: [0, 0.55, 1],
  );

  /// Warm horizon glow drawn behind titles and the splash logo.
  static const RadialGradient sunsetGlow = RadialGradient(
    colors: [Color(0x66FF7A1A), Color(0x22FF4D6D), Color(0x00FF4D6D)],
    stops: [0, 0.5, 1],
  );

  static const LinearGradient panel = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xF2342673), Color(0xF21C1446)],
  );

  static const LinearGradient panelHighlight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4A37A0), Color(0xFF2A1B5E)],
  );

  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB14A), AppColors.sunsetOrange, Color(0xFFE85D00)],
  );

  static const LinearGradient coral = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFF8197), AppColors.coral, Color(0xFFD9284B)],
  );

  static const LinearGradient teal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FF0DA), AppColors.teal, Color(0xFF0E9486)],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFEA8A), AppColors.coinGold, Color(0xFFE09A00)],
  );

  static const LinearGradient purple = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8B6CFF), AppColors.violet, Color(0xFF3F2896)],
  );

  static const LinearGradient cyan = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9DF3FF), AppColors.gemCyan, Color(0xFF12A6CC)],
  );

  static const LinearGradient disabled = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6E6896), Color(0xFF4A4370)],
  );

  /// Progress bar fills.
  static const LinearGradient xpBar = LinearGradient(
    colors: [AppColors.gemCyan, Color(0xFF7C6CFF)],
  );
  static const LinearGradient progressWarm = LinearGradient(
    colors: [AppColors.sunsetOrange, AppColors.electricYellow],
  );
  static const LinearGradient progressGreen = LinearGradient(
    colors: [AppColors.teal, AppColors.success],
  );

  /// Bottom-to-top scrim used over 3D scenes so UI stays readable.
  static const LinearGradient sceneScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x990E0B2A), Color(0x000E0B2A), Color(0x000E0B2A), Color(0xE60E0B2A)],
    stops: [0, 0.22, 0.5, 1],
  );
}
