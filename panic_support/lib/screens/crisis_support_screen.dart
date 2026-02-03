import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app.dart';
import '../widgets/app_background.dart';

class CrisisSupportScreen extends StatelessWidget {
  const CrisisSupportScreen({super.key});

  Future<void> _callNumber(BuildContext context, String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        throw Exception('Launch returned false');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dial: $number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).settings;
    final emergencyNumber = settings.localEmergencyNumber?.trim();
    final crisisNumber = settings.crisisHotlineNumber?.trim();
    final crisisLabel = settings.crisisHotlineLabel?.trim();
    final contacts = settings.emergencyContacts;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Crisis Support'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'If you might hurt yourself or feel unsafe, contact emergency help now.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'These options use the local numbers saved in Settings. If they are empty, add them first.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (emergencyNumber != null && emergencyNumber.isNotEmpty)
                ElevatedButton(
                  onPressed: () => _callNumber(context, emergencyNumber),
                  child: Text('Call local emergency ($emergencyNumber)'),
                )
              else
                const Text('Local emergency number not set.'),
              const SizedBox(height: 12),
              if (crisisNumber != null && crisisNumber.isNotEmpty)
                OutlinedButton(
                  onPressed: () => _callNumber(context, crisisNumber),
                  child: Text(
                    crisisLabel?.isNotEmpty == true
                        ? 'Call $crisisLabel ($crisisNumber)'
                        : 'Call crisis line ($crisisNumber)',
                  ),
                )
              else
                const Text('Crisis line number not set.'),
              const SizedBox(height: 12),
            if (contacts.isNotEmpty)
              ...contacts.map(
                (contact) => TextButton(
                  onPressed: () => _callNumber(context, contact.phone),
                  child: Text(
                    'Call ${contact.name.isNotEmpty ? contact.name : 'contact'}',
                  ),
                ),
              )
            else
              const Text('Emergency contacts not set.'),
              const Spacer(),
              Text(
                'This app is not a replacement for professional care.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
