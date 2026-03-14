// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/settings/app_settings.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();
  await settings.load();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(PeckPapersApp(settings: settings));
}

class PeckPapersApp extends StatefulWidget {
  const PeckPapersApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<PeckPapersApp> createState() => _PeckPapersAppState();
}

class _PeckPapersAppState extends State<PeckPapersApp> {
  bool _onboardingDone = false;

  void _finishOnboarding() {
    setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: widget.settings,
      child: AnimatedBuilder(
        animation: widget.settings,
        builder: (context, _) => MaterialApp(
          title: 'PeckPapers',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(isDark: widget.settings.isDark),
          home: _onboardingDone
              ? const MainShell()
              : OnboardingScreen(onFinish: _finishOnboarding),
        ),
      ),
    );
  }
}
