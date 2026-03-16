// lib/main.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/settings/app_settings.dart';
import 'core/settings/app_settings_scope.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/local_auth.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();

  SystemChrome.setPreferredOrientations([
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

  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    try {
      await widget.settings.load();
      await LocalAuth.ensureAdmin();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('App bootstrap failed: $error');
      }
    }
  }

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
          home: _DeviceBanner(
            child: _onboardingDone
                ? const MainShell()
                : OnboardingScreen(onFinish: _finishOnboarding),
          ),
        ),
      ),
    );
  }
}

class _DeviceBanner extends StatelessWidget {
  const _DeviceBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deviceLabel = _deviceLabel();
    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(179, 0, 0, 0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                deviceLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _deviceLabel() {
    if (kIsWeb) {
      return 'WEB BROWSER';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ANDROID EMULATOR/DEVICE';
      case TargetPlatform.iOS:
        return 'iOS SIMULATOR/DEVICE';
      case TargetPlatform.windows:
        return 'WINDOWS DESKTOP';
      case TargetPlatform.macOS:
        return 'MAC DESKTOP';
      case TargetPlatform.linux:
        return 'LINUX DESKTOP';
      case TargetPlatform.fuchsia:
        return 'FUCHSIA';
    }
  }
}

