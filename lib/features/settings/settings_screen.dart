// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import '../../core/settings/app_settings_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';
import 'model_health_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.headingLG),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          _SectionHeader(title: 'Appearance', icon: Icons.palette_outlined),
          const SizedBox(height: 12),
          PeckCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  settings.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    settings.isDark ? 'Dark Mode' : 'Light Mode',
                    style: AppTextStyles.bodyMDMedium,
                  ),
                ),
                _ModePill(
                  label: 'Light',
                  active: !settings.isDark,
                  onTap: () => settings.setThemeMode(ThemeMode.light),
                ),
                const SizedBox(width: 8),
                _ModePill(
                  label: 'Dark',
                  active: settings.isDark,
                  onTap: () => settings.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'Notifications', icon: Icons.notifications_none),
          const SizedBox(height: 12),
          PeckCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Enable notifications',
                  subtitle: 'Get reminders to keep your streak alive.',
                  value: settings.notifyEnabled,
                  onChanged: settings.setNotifyEnabled,
                ),
                Divider(height: 24, color: AppColors.border),
                _TimeRow(
                  title: 'Notify me daily at',
                  subtitle: 'Pick a time that fits your routine.',
                  time: settings.dailyNotifyTime,
                  enabled: settings.notifyEnabled,
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: settings.dailyNotifyTime,
                    );
                    if (picked != null) {
                      await settings.setDailyNotifyTime(picked);
                    }
                  },
                ),
                Divider(height: 24, color: AppColors.border),
                _SwitchRow(
                  title: 'Study reminder',
                  subtitle: 'Remind me to study for a minimum duration.',
                  value: settings.studyReminderEnabled,
                  onChanged: settings.setStudyReminderEnabled,
                ),
                const SizedBox(height: 14),
                _SliderRow(
                  label: 'At least ${settings.studyMinutes} minutes',
                  value: settings.studyMinutes.toDouble(),
                  enabled: settings.studyReminderEnabled,
                  onChanged: (value) =>
                      settings.setStudyMinutes(value.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'AI', icon: Icons.auto_awesome_outlined),
          const SizedBox(height: 12),
          PeckCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SwitchRow(
                  title: 'Fast mode',
                  subtitle: 'Faster results with fewer tokens and cards.',
                  value: settings.aiFastMode,
                  onChanged: settings.setAiFastMode,
                ),
                Divider(height: 24, color: AppColors.border),
                _NavRow(
                  title: 'Model health',
                  subtitle: 'Verify bundled ONNX model and runtime.',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ModelHealthScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'About', icon: Icons.info_outline),
          const SizedBox(height: 12),
          PeckCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Local-only build. No data leaves your device.',
                    style: AppTextStyles.bodyMD,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.headingMD),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLG.copyWith(
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMDMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.bodySM),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.enabled,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final TimeOfDay time;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = enabled ? AppColors.textPrimary : AppColors.textTertiary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMDMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTextStyles.bodySM),
            ],
          ),
        ),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: enabled ? AppColors.bgSurface : AppColors.border,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              time.format(context),
              style: AppTextStyles.labelLG.copyWith(color: textColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMDMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySM),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLG.copyWith(
            color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
          ),
        ),
        Slider(
          value: value.clamp(15, 180),
          min: 15,
          max: 180,
          divisions: 11,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}

