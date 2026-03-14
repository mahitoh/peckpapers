// lib/core/widgets/peck_button.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum PeckButtonVariant { primary, secondary, ghost, violet }

class PeckButton extends StatefulWidget {
  const PeckButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PeckButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 56,
    this.width,
    this.borderRadius = 16.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final PeckButtonVariant variant;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<PeckButton> createState() => _PeckButtonState();
}

class _PeckButtonState extends State<PeckButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isActive => !widget.isDisabled && !widget.isLoading;

  Color get _bgColor {
    if (widget.isDisabled) return AppColors.border;
    return switch (widget.variant) {
      PeckButtonVariant.primary => AppColors.amber,
      PeckButtonVariant.violet => AppColors.violet,
      PeckButtonVariant.secondary => Colors.transparent,
      PeckButtonVariant.ghost => Colors.transparent,
    };
  }

  Color get _textColor {
    if (widget.isDisabled) return AppColors.textTertiary;
    return switch (widget.variant) {
      PeckButtonVariant.primary => AppColors.textInverse,
      PeckButtonVariant.violet => Colors.white,
      PeckButtonVariant.secondary => AppColors.textPrimary,
      PeckButtonVariant.ghost => AppColors.amber,
    };
  }

  BorderSide get _border => switch (widget.variant) {
    PeckButtonVariant.secondary => BorderSide(
      color: AppColors.border,
      width: 1.5,
    ),
    _ => BorderSide.none,
  };

  List<BoxShadow> get _shadow {
    if (widget.isDisabled) return [];
    return switch (widget.variant) {
      PeckButtonVariant.primary => AppColors.amberShadow,
      PeckButtonVariant.violet => AppColors.violetShadow,
      _ => [],
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isActive ? (_) => _ctrl.forward() : null,
      onTapUp: _isActive
          ? (_) {
              _ctrl.reverse();
              widget.onPressed?.call();
            }
          : null,
      onTapCancel: _isActive ? () => _ctrl.reverse() : null,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.fromBorderSide(_border),
            boxShadow: _shadow,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: _textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(color: _textColor, size: 20),
                          child: widget.icon!,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: AppTextStyles.buttonLG.copyWith(
                          color: _textColor,
                        ),
                      ),
                      if (widget.trailingIcon != null) ...[
                        const SizedBox(width: 8),
                        IconTheme(
                          data: IconThemeData(color: _textColor, size: 20),
                          child: widget.trailingIcon!,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

