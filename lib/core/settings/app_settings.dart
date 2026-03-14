// lib/core/settings/app_settings.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class AppSettings extends ChangeNotifier {
  AppSettings();

  static const _keyTheme = 'themeMode';
  static const _keyNotifyEnabled = 'notifyEnabled';
  static const _keyDailyTime = 'dailyNotifyTime';
  static const _keyStudyReminder = 'studyReminderEnabled';
  static const _keyStudyMinutes = 'studyMinutes';

  ThemeMode _themeMode = ThemeMode.light;
  bool _notifyEnabled = true;
  TimeOfDay _dailyNotifyTime = const TimeOfDay(hour: 19, minute: 0);
  bool _studyReminderEnabled = true;
  int _studyMinutes = 45;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get notifyEnabled => _notifyEnabled;
  TimeOfDay get dailyNotifyTime => _dailyNotifyTime;
  bool get studyReminderEnabled => _studyReminderEnabled;
  int get studyMinutes => _studyMinutes;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_keyTheme);
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    _notifyEnabled = prefs.getBool(_keyNotifyEnabled) ?? true;
    _studyReminderEnabled = prefs.getBool(_keyStudyReminder) ?? true;
    _studyMinutes = prefs.getInt(_keyStudyMinutes) ?? 45;

    final timeValue = prefs.getInt(_keyDailyTime);
    if (timeValue != null) {
      final hour = timeValue ~/ 60;
      final minute = timeValue % 60;
      _dailyNotifyTime = TimeOfDay(hour: hour, minute: minute);
    }

    AppColors.useDark(isDark);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    AppColors.useDark(isDark);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, isDark ? 'dark' : 'light');
  }

  Future<void> setNotifyEnabled(bool value) async {
    _notifyEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifyEnabled, value);
  }

  Future<void> setDailyNotifyTime(TimeOfDay value) async {
    _dailyNotifyTime = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyDailyTime, value.hour * 60 + value.minute);
  }

  Future<void> setStudyReminderEnabled(bool value) async {
    _studyReminderEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStudyReminder, value);
  }

  Future<void> setStudyMinutes(int value) async {
    _studyMinutes = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStudyMinutes, value);
  }
}
