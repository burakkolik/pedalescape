/// Brand palette of Pedal Escape. Every color used by the UI comes from here
/// so the look stays cohesive (storm-night blues/purples + sunset accents).
library;

import 'package:flutter/painting.dart';

abstract final class AppColors {
  // ---- Brand ------------------------------------------------------------
  static const Color stormNavy = Color(0xFF0E0B2A);
  static const Color deepPurple = Color(0xFF2A1B5E);
  static const Color sunsetOrange = Color(0xFFFF7A1A);
  static const Color coral = Color(0xFFFF4D6D);
  static const Color electricYellow = Color(0xFFFFD23F);
  static const Color coinGold = Color(0xFFFFC530);
  static const Color gemCyan = Color(0xFF3DE0FF);
  static const Color teal = Color(0xFF16C2B0);

  // ---- Derived shades ---------------------------------------------------
  static const Color midnight = Color(0xFF070518);
  static const Color indigo = Color(0xFF3B2A7E);
  static const Color violet = Color(0xFF5B3FBF);
  static const Color lavender = Color(0xFFB9A8FF);
  static const Color panel = Color(0xFF1C1446);
  static const Color panelLight = Color(0xFF2E2266);
  static const Color panelBorder = Color(0xFF5845A8);
  static const Color orangeDark = Color(0xFFC24E00);
  static const Color coralDark = Color(0xFFB3203F);
  static const Color tealDark = Color(0xFF0B7A6F);
  static const Color goldDark = Color(0xFFB37E00);
  static const Color cyanDark = Color(0xFF0A8FB0);
  static const Color purpleDark = Color(0xFF1A1040);
  static const Color success = Color(0xFF4CE08A);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4D6D);

  // ---- Text -------------------------------------------------------------
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC9C1F0);
  static const Color textMuted = Color(0xFF8C82BF);
  static const Color textDark = Color(0xFF1A1040);

  // ---- Misc -------------------------------------------------------------
  static const Color shadow = Color(0x99000000);
  static const Color scrim = Color(0xCC070518);
  static const Color locked = Color(0xFF4A4370);
  static const Color starEmpty = Color(0xFF3A3166);
}
