// lib/core/widgets/responsive_layout.dart

import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A helper class to get scaled values based on screen size
class ResponsiveScale {
  final BuildContext context;
  ResponsiveScale(this.context);

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;

  /// Returns a value scaled by the screen width relative to a base width (e.g., 375 for iPhone)
  double scale(double value, {double baseWidth = 375}) {
    return value * (width / baseWidth);
  }

  /// Returns a value clamped between a min and max
  double font(double size, {double min = 12, double max = 32}) {
    double s = scale(size);
    if (s < min) return min;
    if (s > max) return max;
    return s;
  }

  /// Returns appropriate horizontal padding
  double get hPadding {
    if (width > 1200) return 120;
    if (width > 600) return 48;
    return 24;
  }
}
