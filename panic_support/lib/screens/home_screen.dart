import 'package:flutter/material.dart';

import '../app.dart';
import '../widgets/app_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    final theme = Theme.of(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Anchor',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Immediate support for panic and acute anxiety.',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/panic'),
                  child: const Text('Enter Panic Mode'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: settings.earlyWarningEnabled
                      ? () => Navigator.pushNamed(context, '/early')
                      : null,
                  child: Text(
                    settings.earlyWarningEnabled
                        ? 'Early Warning Session'
                        : 'Early Warning (Enable in Settings)',
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  child: const Text('Settings'),
                ),
                const Spacer(),
                const Divider(height: 24),
                Text(
                  'This app is not a replacement for professional care.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/crisis'),
                  child: const Text('Crisis Support'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
