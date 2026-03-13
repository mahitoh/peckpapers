// lib/core/widgets/peck_badge.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum BadgeStyle { filled, outline, subtle }

class PeckBadge extends StatelessWidget {
  const PeckBadge({
    super.key,
    required this.label,
    this.color = AppColors.amber,
    this.style = BadgeStyle.subtle,
    this.icon,
    this.fontSize = 10.0,
  });

  final String label;
  final Color color;
  final BadgeStyle style;
  final Widget? icon;
  final double fontSize;

  Color get _bg => switch (style) {
    BadgeStyle.filled => color,
    BadgeStyle.outline => Colors.transparent,
    BadgeStyle.subtle => color.withOpacity(0.12),
  };

  Color get _textColor => switch (style) {
    BadgeStyle.filled => AppColors.textInverse,
    BadgeStyle.outline => color,
    BadgeStyle.subtle => color,
  };

  BorderSide get _side => switch (style) {
    BadgeStyle.outline => BorderSide(color: color, width: 1),
    _ => BorderSide.none,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.fromBorderSide(_side),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: _textColor, size: fontSize + 2),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AppTextStyles.labelCaps.copyWith(
              color: _textColor,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
