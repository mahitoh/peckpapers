// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// PECKPAPERS Design System — Color Tokens
/// Aesthetic: Clean White × Vibrant Purple × Modern Minimal
class AppColors {
  AppColors._();

  // ─── Backgrounds ──────────────────────────────────────────────
  static const Color bgBase = Color(0xFFFFFFFF); // Pure white background
  static const Color bgSurface = Color(0xFFF8F9FA); // Slightly off-white
  static const Color bgCard = Color(0xFFFFFFFF); // White cards
  static const Color bgCardHover = Color(0xFFF5F5F7); // Card pressed state
  static const Color bgOverlay = Color(0x80000000); // Modal scrim

  // ─── Primary — Vibrant Purple ────────────────────────────────
  static const Color primary = Color(0xFF6B4EFF); // Hero purple
  static const Color primaryLight = Color(0xFF8B74FF); // Light purple
  static const Color primaryDark = Color(0xFF5A3FE8); // Darker purple
  static const Color primaryDim = Color(0x1A6B4EFF); // 10% tinted bg
  static const Color primaryMid = Color(0x336B4EFF); // 20% tinted bg
  static const Color primaryGlow = Color(0x506B4EFF); // Purple glow

  // ─── Secondary ───────────────────────────────────────────────
  static const Color secondary = Color(0xFF9D88FF); // Light violet
  static const Color secondaryDim = Color(0x1A9D88FF);

  // ─── Accent Colors ────────────────────────────────────────────
  static const Color accentOrange = Color(0xFFFF6B35); // For warnings/CTAs
  static const Color accentBlue = Color(0xFF4A90E2); // For info
  static const Color accentGreen = Color(0xFF3ECF8E); // For success

  // ─── Borders & Dividers ───────────────────────────────────────
  static const Color border = Color(0xFFE8E8EC); // Light gray border
  static const Color borderActive = Color(0xFF6B4EFF); // Purple active border
  static const Color divider = Color(0xFFF0F0F2); // Subtle divider

  // ─── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF3ECF8E);
  static const Color successDim = Color(0x1A3ECF8E);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDim = Color(0x1AEF4444);
  static const Color warning = Color(0xFFFFA500);
  static const Color warningDim = Color(0x1AFFA500);

  // ─── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E); // Dark text
  static const Color textSecondary = Color(0xFF6B7280); // Gray text
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color textInverse = Color(0xFFFFFFFF); // White text on dark
  static const Color textMuted = Color(0xFFB4B4B4); // Muted labels

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B4EFF), Color(0xFF8B74FF)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D88FF), Color(0xFFB8A8FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
  );

  // Violet gradient alias (maps to primary gradient)
  static const LinearGradient violetGradient = primaryGradient;

  static const RadialGradient primaryRadial = RadialGradient(
    colors: [Color(0x306B4EFF), Color(0x006B4EFF)],
    radius: 0.8,
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.08),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadowStrong => [
    BoxShadow(
      color: const Color(0xFF1A1A2E).withOpacity(0.12),
      blurRadius: 24,
      spreadRadius: -2,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get primaryShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Legacy Color Mappings (for backward compatibility) ─────
  static const Color amber = accentOrange;
  static const Color amberLight = accentOrange;
  static const Color amberDim = Color(0x1AFF6B35);
  static const Color violet = primary;
  static const Color violetLight = primaryLight;
  static const Color violetDim = primaryDim;
  static const Color violetGlow = primaryGlow;
  static const Color scanner = accentOrange;
  static const Color scannerLight = accentOrange;
  static const Color scannerFrame = accentOrange;
  static const Color scannerGlow = Color(0x40FF6B35);
  static const Color scannerHighlight = Color(0x60FF6B35);
  static const Color scannerLine = accentOrange;
  static LinearGradient get scannerGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C5A)],
  );
  static List<BoxShadow> get amberShadow => [
    BoxShadow(
      color: accentOrange.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> get violetShadow => primaryShadow;
}
