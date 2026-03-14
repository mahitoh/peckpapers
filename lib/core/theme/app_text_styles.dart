// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _display = 'Sora';
  static const String _body = 'DMSans';

  static TextStyle get displayXL => TextStyle(
    fontFamily: _display,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -1.2,
  );

  static TextStyle get displayLG => TextStyle(
    fontFamily: _display,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static TextStyle get displayMD => TextStyle(
    fontFamily: _display,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get headingXL => TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle get headingLG => TextStyle(
    fontFamily: _display,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static TextStyle get headingMD => TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static TextStyle get headingSM => TextStyle(
    fontFamily: _display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: 0,
  );

  static TextStyle get bodyLG => TextStyle(
    fontFamily: _body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMD => TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
    letterSpacing: 0.1,
  );

  static TextStyle get bodySM => TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyMDMedium => TextStyle(
    fontFamily: _body,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
    letterSpacing: 0.05,
  );

  static TextStyle get labelLG => TextStyle(
    fontFamily: _body,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.2,
  );

  static TextStyle get labelMD => TextStyle(
    fontFamily: _body,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.4,
    letterSpacing: 0.4,
  );

  static TextStyle get labelSM => TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    height: 1.3,
    letterSpacing: 0.8,
  );

  static TextStyle get labelCaps => TextStyle(
    fontFamily: _body,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    height: 1.3,
    letterSpacing: 1.5,
  );

  static TextStyle get statXL => TextStyle(
    fontFamily: _display,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -2.0,
  );

  static TextStyle get statLG => TextStyle(
    fontFamily: _display,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static TextStyle get statMD => TextStyle(
    fontFamily: _display,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.1,
    letterSpacing: -0.8,
  );

  static TextStyle get buttonLG => TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonMD => TextStyle(
    fontFamily: _display,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textInverse,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static TextStyle get buttonSM => TextStyle(
    fontFamily: _display,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: 0.2,
  );

  static TextStyle get scannerTitle => TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get scannerAccent => TextStyle(
    fontFamily: _display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.amber,
    height: 1.2,
    letterSpacing: -0.3,
  );

  static TextStyle get flashcardQuestion => TextStyle(
    fontFamily: _display,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.2,
  );

  static TextStyle get flashcardAnswer => TextStyle(
    fontFamily: _body,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textInverse,
    height: 1.55,
    letterSpacing: 0.1,
  );

  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);

  static TextStyle withOpacity(TextStyle base, double opacity) =>
      base.copyWith(color: base.color?.withOpacity(opacity));
}
