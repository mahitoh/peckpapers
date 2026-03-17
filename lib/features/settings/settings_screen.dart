// lib/features/settings/settings_screen.dart

import 'package:flutter/material.dart';
import '../../core/settings/app_settings_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/peck_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: AppBar(
        backgroundColor: AppColors.bgBase,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.bodyMDMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'Account'),
          _buildSettingsTile(
            Icons.person_outline_rounded,
            'Personal Information',
            'Update your email, phone, and name.',
            onTap: () {},
          ),
          _buildSettingsTile(
            Icons.lock_outline_rounded,
            'Change Password',
            'Secure your account with a strong password.',
            onTap: () {},
          ),

          _SectionHeader(title: 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  settings.isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark Mode', style: AppTextStyles.bodyMDMedium),
                      Text(
                        'Switch between light and dark themes.',
                        style: AppTextStyles.bodySM,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.isDark,
                  onChanged: (v) => settings.setThemeMode(
                    v ? ThemeMode.dark : ThemeMode.light,
                  ),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          _SectionHeader(title: 'Notifications'),
          _buildSettingsTile(
            Icons.notifications_none_rounded,
            'Push Notifications',
            'Manage how you receive study reminders.',
            trailing: Switch(
              value: settings.notifyEnabled,
              onChanged: settings.setNotifyEnabled,
              activeColor: AppColors.primary,
            ),
          ),

          _SectionHeader(title: 'Sync & Backup'),
          _buildSettingsTile(
            Icons.cloud_outlined,
            'Cloud Sync',
            'Keep your data synced across devices.',
            onTap: () {},
          ),

          _SectionHeader(title: 'About PECKPAPERS'),
          _buildSettingsTile(
            Icons.help_outline_rounded,
            'Help Center',
            null,
            onTap: () {},
          ),
          _buildSettingsTile(
            Icons.shield_outlined,
            'Privacy Policy',
            null,
            onTap: () {},
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 2.0.0 (X-Edition)',
              style: AppTextStyles.labelSM.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String? subtitle, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMDMedium),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySM.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      color: AppColors.bgSurface.withOpacity(0.5),
      child: Text(
        title,
        style: AppTextStyles.bodyMDMedium.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
        ),
      ),
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


