// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const PeckPapersApp());
}

class PeckPapersApp extends StatefulWidget {
  const PeckPapersApp({super.key});

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
    return MaterialApp(
      title: 'PeckPapers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _onboardingDone
          ? const MainShell()
          : OnboardingScreen(onFinish: _finishOnboarding),
    );
  }
}
