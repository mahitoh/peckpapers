// lib/core/settings/app_settings_scope.dart

import 'package:flutter/material.dart';
import 'app_settings.dart';

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError('AppSettingsScope not found in widget tree.');
    }
    return scope.notifier!;
  }
}
