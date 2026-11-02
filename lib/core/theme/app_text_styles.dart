/// Game typography. No font assets are bundled, so we lean on heavy system
/// weights, tight letter spacing and drop shadows for a chunky game look.
/// Sizes are scaled with [Responsive.scale].
library;

import 'package:flutter/widgets.dart';

import '../responsive/responsive.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles(this.scale);

  factory AppTextStyles.of(BuildContext context) =>
      AppTextStyles(Responsive.of(context).scale);

  final double scale;

  static const List<Shadow> _shadow = [
    Shadow(color: Color(0xAA000000), offset: Offset(0, 2), blurRadius: 3),
  ];

  static const List<Shadow> _softShadow = [
    Shadow(color: Color(0x88000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  TextStyle _base(double size, FontWeight weight, {Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: size * scale,
        fontWeight: weight,
        color: color,
        height: 1.15,
        letterSpacing: 0.2,
      );

  /// Huge logo / screen-hero text.
  TextStyle get display =>
      _base(40, FontWeight.w900).copyWith(letterSpacing: 0.5, shadows: _shadow);

  /// Screen titles.
  TextStyle get title =>
      _base(26, FontWeight.w900).copyWith(letterSpacing: 0.4, shadows: _shadow);

  /// Panel headings.
  TextStyle get heading => _base(20, FontWeight.w800).copyWith(shadows: _softShadow);

  TextStyle get subheading => _base(16, FontWeight.w800).copyWith(shadows: _softShadow);

  TextStyle get body => _base(14, FontWeight.w600, color: AppColors.textSecondary)
      .copyWith(height: 1.3);

  TextStyle get bodyStrong => _base(14, FontWeight.w800);

  TextStyle get caption => _base(12, FontWeight.w700, color: AppColors.textMuted);

  TextStyle get tiny => _base(10, FontWeight.w800, color: AppColors.textSecondary);

  /// Button labels (white with dark drop shadow).
  TextStyle get button =>
      _base(18, FontWeight.w900).copyWith(letterSpacing: 0.6, shadows: _shadow);

  TextStyle get buttonSmall =>
      _base(14, FontWeight.w900).copyWith(letterSpacing: 0.4, shadows: _softShadow);

  /// Numbers in counters / currency chips (tabular figures).
  TextStyle get number => _base(16, FontWeight.w900).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: _softShadow,
      );

  TextStyle get bigNumber => _base(34, FontWeight.w900).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: _shadow,
      );
}

extension AppTextStylesContext on BuildContext {
  AppTextStyles get text => AppTextStyles.of(this);
}
