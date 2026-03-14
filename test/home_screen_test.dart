import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peckpapers/core/settings/app_settings.dart';
import 'package:peckpapers/core/settings/app_settings_scope.dart';
import 'package:peckpapers/features/home/home_screen.dart';

void main() {
  testWidgets('Home screen shows stats carousel and tasks', (WidgetTester tester) async {
    final settings = AppSettings();
    await settings.load();

    await tester.pumpWidget(
      AppSettingsScope(
        settings: settings,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.text('Due Today'), findsOneWidget);
    expect(find.textContaining('Calculus'), findsOneWidget);
  });
}
