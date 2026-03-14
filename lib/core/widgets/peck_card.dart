// lib/core/widgets/peck_card.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PeckCard extends StatefulWidget {
  const PeckCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.glowColor,
    this.gradient,
    this.height,
    this.width,
    this.borderRadius = 20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final Gradient? gradient;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  State<PeckCard> createState() => _PeckCardState();
}

class _PeckCardState extends State<PeckCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = widget.borderColor ?? AppColors.border;
    final effectiveGlow = widget.glowColor;

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (_) {
              _controller.reverse();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: widget.onTap != null ? () => _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.cardGradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: effectiveBorder, width: 1),
            boxShadow: [
              if (effectiveGlow != null)
                BoxShadow(
                  color: effectiveGlow.withOpacityCompat(0.25),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              BoxShadow(
                color: Colors.black.withOpacityCompat(0.35),
                blurRadius: 20,
                spreadRadius: -6,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}

