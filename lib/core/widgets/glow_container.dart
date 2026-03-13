// lib/core/widgets/glow_container.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlowContainer extends StatelessWidget {
  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor = AppColors.amber,
    this.glowRadius = 80.0,
    this.glowOpacity = 0.35,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.border,
  });

  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final double glowOpacity;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(glowOpacity),
            blurRadius: glowRadius,
            spreadRadius: glowRadius * 0.1,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Circular glow container — for icon buttons, fab-style elements
class GlowCircle extends StatelessWidget {
  const GlowCircle({
    super.key,
    required this.child,
    required this.size,
    this.glowColor = AppColors.amber,
    this.fillColor = AppColors.amberDim,
    this.glowRadius = 40.0,
    this.glowOpacity = 0.4,
    this.onTap,
  });

  final Widget child;
  final double size;
  final Color glowColor;
  final Color fillColor;
  final double glowRadius;
  final double glowOpacity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(glowOpacity),
              blurRadius: glowRadius,
              spreadRadius: glowRadius * 0.15,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
