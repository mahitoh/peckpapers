// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// PECKPAPERS Typography System
/// Display/Headings: Sora — geometric, confident, futuristic
/// Body/Labels:      DM Sans — clean, readable, friendly
class AppTextStyles {
  AppTextStyles._();

  static const String _display = 'Sora';
  static const String _body = 'DMSans';

  // ─── Display — Hero text, splash screens ──────────────────────
  static const TextStyle displayXL = TextStyle(
    fontFamily: _display,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -1.2,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: _display,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: _display,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ─── Headings — Screen titles, section headers ─────────────────
  static const TextStyle headingXL = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle headingLG = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static const TextStyle headingMD = TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static const TextStyle headingSM = TextStyle(
    fontFamily: _display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  // ─── Body — Paragraphs, descriptions ──────────────────────────
  static const TextStyle bodyLG = TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
    letterSpacing: 0.1,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyMDMedium = TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.05,
  );

  // ─── Labels — Chips, tags, tiny annotations ───────────────────
  static const TextStyle labelLG = TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    height: 1.3,
    letterSpacing: 0.8,
  );

  /// Uppercase micro-label — e.g. "QUESTION", "AI GENERATED"
  static const TextStyle labelCaps = TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 1.5,
  );

  // ─── Numbers — Stats, scores, counters ────────────────────────
  static const TextStyle statXL = TextStyle(
    fontFamily: _display,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -2.0,
  );

  static const TextStyle statLG = TextStyle(
    fontFamily: _display,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static const TextStyle statMD = TextStyle(
    fontFamily: _display,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.8,
  );

  // ─── Buttons ──────────────────────────────────────────────────
  static const TextStyle buttonLG = TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: _display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSM = TextStyle(
    fontFamily: _display,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0.2,
  );

  // ─── Scanner specific ─────────────────────────────────────────
  /// "Scan Your Question..." title on scanner screen
  static const TextStyle scannerTitle = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
    letterSpacing: -0.3,
  );

  /// The orange "Question..." highlight word
  static const TextStyle scannerAccent = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.amber,
    height: 1.2,
    letterSpacing: -0.3,
  );

  // ─── Flashcard specific ───────────────────────────────────────
  static const TextStyle flashcardQuestion = TextStyle(
    fontFamily: _display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static const TextStyle flashcardAnswer = TextStyle(
    fontFamily: _body,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textInverse,
    height: 1.55,
    letterSpacing: 0.1,
  );

  // ─── Utility: quick color overrides ───────────────────────────
  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);

  static TextStyle withOpacity(TextStyle base, double opacity) =>
      base.copyWith(color: base.color?.withOpacity(opacity));
}
