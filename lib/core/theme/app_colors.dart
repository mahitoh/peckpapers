// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.isDark,
    required this.bgBase,
    required this.bgSurface,
    required this.bgCard,
    required this.bgCardHover,
    required this.bgOverlay,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryDim,
    required this.primaryMid,
    required this.primaryGlow,
    required this.secondary,
    required this.secondaryDim,
    required this.accentOrange,
    required this.accentBlue,
    required this.accentGreen,
    required this.border,
    required this.borderActive,
    required this.divider,
    required this.success,
    required this.successDim,
    required this.error,
    required this.errorDim,
    required this.warning,
    required this.warningDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.textMuted,
  });

  final bool isDark;
  final Color bgBase;
  final Color bgSurface;
  final Color bgCard;
  final Color bgCardHover;
  final Color bgOverlay;

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryDim;
  final Color primaryMid;
  final Color primaryGlow;

  final Color secondary;
  final Color secondaryDim;

  final Color accentOrange;
  final Color accentBlue;
  final Color accentGreen;

  final Color border;
  final Color borderActive;
  final Color divider;

  final Color success;
  final Color successDim;
  final Color error;
  final Color errorDim;
  final Color warning;
  final Color warningDim;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color textMuted;

  static const AppPalette light = AppPalette(
    isDark: false,
    bgBase: Color(0xFFFFFFFF),
    bgSurface: Color(0xFFF8F9FA),
    bgCard: Color(0xFFFFFFFF),
    bgCardHover: Color(0xFFF5F5F7),
    bgOverlay: Color(0x80000000),
    primary: Color(0xFF6B4EFF),
    primaryLight: Color(0xFF8B74FF),
    primaryDark: Color(0xFF5A3FE8),
    primaryDim: Color(0x1A6B4EFF),
    primaryMid: Color(0x336B4EFF),
    primaryGlow: Color(0x506B4EFF),
    secondary: Color(0xFF9D88FF),
    secondaryDim: Color(0x1A9D88FF),
    accentOrange: Color(0xFFFF6B35),
    accentBlue: Color(0xFF4A90E2),
    accentGreen: Color(0xFF3ECF8E),
    border: Color(0xFFE8E8EC),
    borderActive: Color(0xFF6B4EFF),
    divider: Color(0xFFF0F0F2),
    success: Color(0xFF3ECF8E),
    successDim: Color(0x1A3ECF8E),
    error: Color(0xFFEF4444),
    errorDim: Color(0x1AEF4444),
    warning: Color(0xFFFFA500),
    warningDim: Color(0x1AFFA500),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    textInverse: Color(0xFFFFFFFF),
    textMuted: Color(0xFFB4B4B4),
  );

  static const AppPalette dark = AppPalette(
    isDark: true,
    bgBase: Color(0xFF0F1117),
    bgSurface: Color(0xFF151821),
    bgCard: Color(0xFF1A1F2B),
    bgCardHover: Color(0xFF202634),
    bgOverlay: Color(0x99000000),
    primary: Color(0xFF7B6CFF),
    primaryLight: Color(0xFF9A8BFF),
    primaryDark: Color(0xFF5F52E6),
    primaryDim: Color(0x267B6CFF),
    primaryMid: Color(0x407B6CFF),
    primaryGlow: Color(0x667B6CFF),
    secondary: Color(0xFFB2A2FF),
    secondaryDim: Color(0x33B2A2FF),
    accentOrange: Color(0xFFFF8A5C),
    accentBlue: Color(0xFF6AA9F5),
    accentGreen: Color(0xFF4BE3A0),
    border: Color(0xFF2B3141),
    borderActive: Color(0xFF7B6CFF),
    divider: Color(0xFF222837),
    success: Color(0xFF4BE3A0),
    successDim: Color(0x264BE3A0),
    error: Color(0xFFFF6B6B),
    errorDim: Color(0x26FF6B6B),
    warning: Color(0xFFFFB24D),
    warningDim: Color(0x26FFB24D),
    textPrimary: Color(0xFFF5F7FF),
    textSecondary: Color(0xFFB6BECC),
    textTertiary: Color(0xFF8A93A6),
    textInverse: Color(0xFF0B0D12),
    textMuted: Color(0xFF6C7486),
  );
}

class AppColors {
  AppColors._();

  static AppPalette _palette = AppPalette.light;

  static void useDark(bool value) {
    _palette = value ? AppPalette.dark : AppPalette.light;
  }

  static bool get isDark => _palette.isDark;

  static Color get bgBase => _palette.bgBase;
  static Color get bgSurface => _palette.bgSurface;
  static Color get bgCard => _palette.bgCard;
  static Color get bgCardHover => _palette.bgCardHover;
  static Color get bgOverlay => _palette.bgOverlay;

  static Color get primary => _palette.primary;
  static Color get primaryLight => _palette.primaryLight;
  static Color get primaryDark => _palette.primaryDark;
  static Color get primaryDim => _palette.primaryDim;
  static Color get primaryMid => _palette.primaryMid;
  static Color get primaryGlow => _palette.primaryGlow;

  static Color get secondary => _palette.secondary;
  static Color get secondaryDim => _palette.secondaryDim;

  static Color get accentOrange => _palette.accentOrange;
  static Color get accentBlue => _palette.accentBlue;
  static Color get accentGreen => _palette.accentGreen;

  static Color get border => _palette.border;
  static Color get borderActive => _palette.borderActive;
  static Color get divider => _palette.divider;

  static Color get success => _palette.success;
  static Color get successDim => _palette.successDim;
  static Color get error => _palette.error;
  static Color get errorDim => _palette.errorDim;
  static Color get warning => _palette.warning;
  static Color get warningDim => _palette.warningDim;

  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textTertiary => _palette.textTertiary;
  static Color get textInverse => _palette.textInverse;
  static Color get textMuted => _palette.textMuted;

  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static LinearGradient get secondaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondary.withOpacity(0.7)],
  );

  static LinearGradient get cardGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgCard, bgSurface],
  );

  static LinearGradient get violetGradient => primaryGradient;

  static RadialGradient get primaryRadial => RadialGradient(
    colors: [primary.withOpacity(0.20), primary.withOpacity(0.0)],
    radius: 0.8,
  );

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(isDark ? 0.35 : 0.08),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowStrong => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(isDark ? 0.45 : 0.12),
      blurRadius: 24,
      spreadRadius: -2,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withOpacity(isDark ? 0.40 : 0.30),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static Color get amber => accentOrange;
  static Color get amberLight => accentOrange;
  static Color get amberDim => accentOrange.withOpacity(0.18);
  static Color get violet => primary;
  static Color get violetLight => primaryLight;
  static Color get violetDim => primaryDim;
  static Color get violetGlow => primaryGlow;
  static Color get scanner => accentOrange;
  static Color get scannerLight => accentOrange;
  static Color get scannerFrame => accentOrange;
  static Color get scannerGlow => accentOrange.withOpacity(0.25);
  static Color get scannerHighlight => accentOrange.withOpacity(0.45);
  static Color get scannerLine => accentOrange;

  static LinearGradient get scannerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, accentOrange.withOpacity(0.85)],
  );

  static List<BoxShadow> get amberShadow => [
    BoxShadow(
      color: accentOrange.withOpacity(isDark ? 0.50 : 0.35),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get violetShadow => primaryShadow;
}
