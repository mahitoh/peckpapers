// lib/core/widgets/stat_tile.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glow_container.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.color = AppColors.amber,
    this.icon,
    this.trend,
    this.trendUp,
    this.onTap,
    this.isCompact = false,
  });

  final String value;
  final String label;
  final Color color;
  final Widget? icon;
  final String? trend;
  final bool? trendUp;
  final VoidCallback? onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlowContainer(
        glowColor: color,
        glowRadius: 32,
        glowOpacity: 0.15,
        child: Container(
          padding: EdgeInsets.all(isCompact ? 14 : 18),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.25), width: 1),
          ),
          child: isCompact
              ? _CompactContent(
                  value: value,
                  label: label,
                  color: color,
                  icon: icon,
                )
              : _FullContent(
                  value: value,
                  label: label,
                  color: color,
                  icon: icon,
                  trend: trend,
                  trendUp: trendUp,
                ),
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
    this.trend,
    this.trendUp,
  });

  final String value;
  final String label;
  final Color color;
  final Widget? icon;
  final String? trend;
  final bool? trendUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (icon != null)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: IconTheme(
                    data: IconThemeData(color: color, size: 18),
                    child: icon!,
                  ),
                ),
              ),
            if (trend != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (trendUp == true ? AppColors.success : AppColors.error)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp == true
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: trendUp == true
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend!,
                      style: AppTextStyles.labelMD.copyWith(
                        color: trendUp == true
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(value, style: AppTextStyles.statMD.copyWith(color: color)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelMD),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: 18),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.headingMD.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelMD),
          ],
        ),
      ],
    );
  }
}
