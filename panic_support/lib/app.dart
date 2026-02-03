import 'package:flutter/material.dart';

import 'controllers/settings_controller.dart';
import 'models/panic_phase.dart';
import 'models/settings.dart';
import 'screens/crisis_support_screen.dart';
import 'screens/home_screen.dart';
import 'screens/session_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required Widget child,
  }) : super(notifier: controller, child: child);

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    if (scope == null) {
      throw FlutterError('SettingsScope not found in widget tree');
    }
    return scope.notifier!;
  }
}

class PanicSupportApp extends StatelessWidget {
  final SettingsController settingsController;

  const PanicSupportApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: settingsController,
      child: AnimatedBuilder(
        animation: settingsController,
        builder: (context, _) {
          final preference = settingsController.settings.themePreference;
          ThemeMode mode;
          if (preference == ThemePreference.day) {
            mode = ThemeMode.light;
          } else if (preference == ThemePreference.night) {
            mode = ThemeMode.dark;
          } else {
            mode = ThemeMode.system;
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Anchor',
            theme: AppTheme.day(),
            darkTheme: AppTheme.night(),
            themeMode: mode,
            routes: {
              '/': (_) => const HomeScreen(),
              '/panic': (_) => const SessionScreen(mode: SessionMode.panic),
              '/early': (_) => const SessionScreen(mode: SessionMode.earlyWarning),
              '/settings': (_) => const SettingsScreen(),
              '/crisis': (_) => const CrisisSupportScreen(),
            },
          );
        },
      ),
    );
  }
}
