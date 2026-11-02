/// Material theme configured to match the custom game look (dark, no
/// splash ripples, transparent surfaces). Most widgets are custom-drawn; the
/// theme mainly styles the few Material primitives we still use.
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.sunsetOrange,
      onPrimary: Colors.white,
      secondary: AppColors.gemCyan,
      onSecondary: AppColors.textDark,
      tertiary: AppColors.electricYellow,
      error: AppColors.coral,
      surface: AppColors.panel,
      onSurface: AppColors.textPrimary,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.stormNavy,
      canvasColor: AppColors.stormNavy,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.sunsetOrange,
        inactiveTrackColor: AppColors.panelLight,
        thumbColor: AppColors.electricYellow,
        overlayColor: Color(0x33FFD23F),
        trackHeight: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.transparent, elevation: 0),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0x665845A8)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
      ),
    );
  }
}
