// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// PECKPAPERS Design System — Color Tokens
/// Aesthetic: Deep Ink × Electric Amber × Violet AI
class AppColors {
  AppColors._();

  // ─── Backgrounds ──────────────────────────────────────────────
  static const Color bgBase = Color(0xFF09090C); // True deep ink
  static const Color bgSurface = Color(0xFF111116); // Slightly lifted dark
  static const Color bgCard = Color(0xFF1A1A22); // Card base
  static const Color bgCardHover = Color(0xFF22222D); // Card pressed state
  static const Color bgOverlay = Color(0xFF0D0D12); // Modal scrim layer

  // ─── Borders & Dividers ───────────────────────────────────────
  static const Color border = Color(0xFF252530); // Subtle card edge
  static const Color borderActive = Color(0xFF3A3A50); // Focused/active edge
  static const Color borderGlow = Color(0x40FF6B35); // Orange glow edge

  // ─── Primary — Electric Amber (Scanner / CTA) ─────────────────
  static const Color amber = Color(0xFFFF6B35); // Hero orange
  static const Color amberLight = Color(0xFFFF8C5A); // Hover tint
  static const Color amberDim = Color(0x1AFF6B35); // 10% tinted bg
  static const Color amberMid = Color(0x33FF6B35); // 20% tinted bg
  static const Color amberGlow = Color(0x60FF6B35); // Scanner glow

  // ─── Secondary — Violet AI ────────────────────────────────────
  static const Color violet = Color(0xFF7B61FF); // AI-generated purple
  static const Color violetLight = Color(0xFF9D88FF); // Light violet
  static const Color violetDim = Color(0x1A7B61FF); // Tinted bg
  static const Color violetGlow = Color(0x507B61FF); // AI element glow

  // ─── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF3ECF8E); // Correct / mastered
  static const Color successDim = Color(0x1A3ECF8E);
  static const Color error = Color(0xFFEF4444); // Wrong / hard
  static const Color errorDim = Color(0x1AEF4444);
  static const Color warning = Color(0xFFF59E0B); // Medium / almost
  static const Color warningDim = Color(0x1AF59E0B);

  // ─── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1EDE4); // Off-white warm
  static const Color textSecondary = Color(0xFF8A8A9A); // Muted labels
  static const Color textTertiary = Color(0xFF4A4A5A); // Ghost text
  static const Color textInverse = Color(0xFF09090C); // On bright surfaces

  // ─── Gradients ────────────────────────────────────────────────
  static const LinearGradient scannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
  );

  static const LinearGradient violetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B61FF), Color(0xFF9D88FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E28), Color(0xFF16161F)],
  );

  static const RadialGradient amberRadial = RadialGradient(
    colors: [Color(0x30FF6B35), Color(0x00FF6B35)],
    radius: 0.8,
  );

  static const RadialGradient violetRadial = RadialGradient(
    colors: [Color(0x307B61FF), Color(0x007B61FF)],
    radius: 0.8,
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> get amberShadow => [
    BoxShadow(
      color: amber.withOpacity(0.35),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get violetShadow => [
    BoxShadow(
      color: violet.withOpacity(0.30),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -6,
      offset: const Offset(0, 12),
    ),
  ];

  // ─── Scanner Overlay Colors ───────────────────────────────────
  static const Color scannerLine = Color(0xFFFF6B35);
  static const Color scannerFrame = Color(0xCCFF6B35);
  static const Color scannerOverlay = Color(0x40000000);
  static const Color scannerHighlight = Color(0x25FF6B35);
  static const Color scannerGlow = Color(0x60FF6B35);
}
