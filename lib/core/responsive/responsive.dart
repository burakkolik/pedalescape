/// Responsive helpers. All UI sizes go through `context.rs(x)` so layouts
/// scale smoothly from 320 dp phones to 10" tablets. The design baseline is a
/// 390 x 844 dp phone (scale 1.0).
library;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Device class derived from the shortest side.
enum DeviceClass { compactPhone, phone, tablet }

/// Snapshot of screen metrics with derived scale factors.
class Responsive {
  const Responsive(this.size);

  factory Responsive.of(BuildContext context) =>
      Responsive(MediaQuery.sizeOf(context));

  final Size size;

  static const double _baseShort = 390;
  static const double _baseLong = 800;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => math.min(size.width, size.height);
  double get longestSide => math.max(size.width, size.height);

  /// Uniform UI scale (0.8 .. 1.5). Uses the tighter of width & height so
  /// short phones (e.g. 320 x 568) shrink instead of overflowing.
  double get scale {
    if (shortestSide <= 0) return 1;
    final s = math.min(shortestSide / _baseShort, longestSide / _baseLong);
    return s.clamp(0.8, 1.5).toDouble();
  }

  DeviceClass get deviceClass {
    if (shortestSide >= 600) return DeviceClass.tablet;
    if (shortestSide < 360 || height < 640) return DeviceClass.compactPhone;
    return DeviceClass.phone;
  }

  bool get isTablet => deviceClass == DeviceClass.tablet;
  bool get isCompact => deviceClass == DeviceClass.compactPhone;

  /// Short screens (e.g. 568 dp tall) get condensed vertical layouts.
  bool get isShort => height < 680;

  /// Max width of centered content columns (lists, panels) on wide screens.
  double get maxContentWidth => isTablet ? math.min(width * 0.82, 720) : width;

  /// Scales a design-space value.
  double rs(double value) => value * scale;

  /// Horizontal page padding.
  double get pagePadding => rs(isTablet ? 28 : 16);
}

extension ResponsiveContext on BuildContext {
  Responsive get responsive => Responsive.of(this);

  /// Scales a design-space size (dp at 390 dp width) to this screen.
  double rs(double value) => Responsive.of(this).rs(value);
}

/// Centers [child] and caps its width to [Responsive.maxContentWidth].
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final max = maxWidth ?? context.responsive.maxContentWidth;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}
