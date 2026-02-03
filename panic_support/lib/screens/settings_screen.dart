import 'package:flutter/material.dart';

import '../app.dart';
import '../controllers/settings_controller.dart';
import '../models/settings.dart';
import '../widgets/app_background.dart';
import '../widgets/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _customStatementController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _crisisNumberController = TextEditingController();
  final _crisisLabelController = TextEditingController();

  bool _initialized = false;
  double _inhaleValue = 4;
  double _exhaleValue = 6;
  double _pauseValue = 2;
  double _earlyWarningValue = 90;
  double _audioVolumeValue = 0.22;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = SettingsScope.of(context).settings;
    _emergencyNumberController.text = settings.localEmergencyNumber ?? '';
    _crisisNumberController.text = settings.crisisHotlineNumber ?? '';
    _crisisLabelController.text = settings.crisisHotlineLabel ?? '';
    _inhaleValue = settings.inhaleSeconds.toDouble();
    _exhaleValue = settings.exhaleSeconds.toDouble();
    _pauseValue = settings.pauseSeconds.toDouble();
    _earlyWarningValue = settings.earlyWarningSeconds.toDouble();
    _audioVolumeValue = settings.audioVolume;
    _initialized = true;
  }

  bool _isPhoneValid(String phone) {
    final pattern = RegExp(r'^[0-9+()\-\s]+$');
    if (!pattern.hasMatch(phone)) return false;
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.length >= 7 && digitsOnly.length <= 15;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addContact(SettingsController controller) {
    final name = _contactNameController.text.trim();
    final phone = _contactPhoneController.text.trim();

    if (phone.isEmpty) {
      _showError('Enter a phone number.');
      return;
    }
    if (!_isPhoneValid(phone)) {
      _showError('Enter a valid phone number.');
      return;
    }

    controller.addEmergencyContact(
      EmergencyContact(name: name, phone: phone),
    );
    _contactNameController.clear();
    _contactPhoneController.clear();
  }

  @override
  void dispose() {
    _customStatementController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _emergencyNumberController.dispose();
    _crisisNumberController.dispose();
    _crisisLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SettingsScope.of(context);
    final settings = controller.settings;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SectionHeader('Breathing'),
            _SliderRow(
              label: 'Inhale (seconds)',
              value: _inhaleValue,
              min: 3,
              max: 8,
              onChanged: (value) => setState(() => _inhaleValue = value),
              onChangeEnd: (value) => controller.updateBreathing(
                inhale: value.round(),
                exhale: settings.exhaleSeconds,
                pause: settings.pauseSeconds,
              ),
            ),
            _SliderRow(
              label: 'Exhale (seconds)',
              value: _exhaleValue,
              min: 4,
              max: 10,
              onChanged: (value) => setState(() => _exhaleValue = value),
              onChangeEnd: (value) => controller.updateBreathing(
                inhale: settings.inhaleSeconds,
                exhale: value.round(),
                pause: settings.pauseSeconds,
              ),
            ),
            _SliderRow(
              label: 'Pause (seconds)',
              value: _pauseValue,
              min: 0,
              max: 4,
              onChanged: (value) => setState(() => _pauseValue = value),
              onChangeEnd: (value) => controller.updateBreathing(
                inhale: settings.inhaleSeconds,
                exhale: settings.exhaleSeconds,
                pause: value.round(),
              ),
            ),
          SwitchListTile(
            title: const Text('Audio cues in sessions'),
            value: settings.audioEnabled,
            onChanged: (value) => controller.updateAudio(value),
          ),
          if (settings.audioEnabled)
            _SliderRow(
              label: 'Audio volume',
              value: _audioVolumeValue,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              onChanged: (value) => setState(() => _audioVolumeValue = value),
              onChangeEnd: (value) => controller.updateAudioVolume(value),
            ),
          const SectionHeader('Early Warning'),
          SwitchListTile(
            title: const Text('Enable early warning mode'),
            value: settings.earlyWarningEnabled,
            onChanged: (value) => controller.updateEarlyWarning(
              enabled: value,
              seconds: settings.earlyWarningSeconds,
            ),
          ),
          const SectionHeader('Appearance'),
          RadioListTile<ThemePreference>(
            value: ThemePreference.system,
            groupValue: settings.themePreference,
            title: const Text('System default'),
            onChanged: (value) {
              if (value != null) controller.updateThemePreference(value);
            },
          ),
          RadioListTile<ThemePreference>(
            value: ThemePreference.day,
            groupValue: settings.themePreference,
            title: const Text('Always day'),
            onChanged: (value) {
              if (value != null) controller.updateThemePreference(value);
            },
          ),
          RadioListTile<ThemePreference>(
            value: ThemePreference.night,
            groupValue: settings.themePreference,
            title: const Text('Always night'),
            onChanged: (value) {
              if (value != null) controller.updateThemePreference(value);
            },
          ),
          _SliderRow(
            label: 'Early warning breathing (seconds)',
            value: _earlyWarningValue,
            min: 45,
              max: 180,
              onChanged: (value) => setState(() => _earlyWarningValue = value),
              onChangeEnd: (value) => controller.updateEarlyWarning(
                enabled: settings.earlyWarningEnabled,
                seconds: value.round(),
              ),
            ),
            const SectionHeader('Grounding Statements'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customStatementController,
                    decoration: const InputDecoration(
                      hintText: 'Add a personal grounding line',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final text = _customStatementController.text.trim();
                    if (text.isEmpty) return;
                    controller.addCustomGrounding(text);
                    _customStatementController.clear();
                  },
                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (settings.customGroundingStatements.isEmpty)
              const Text('No custom statements added yet.'),
            if (settings.customGroundingStatements.isNotEmpty)
              ...settings.customGroundingStatements.asMap().entries.map(
                    (entry) => ListTile(
                      title: Text(entry.value),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            controller.removeCustomGroundingAt(entry.key),
                      ),
                    ),
                  ),
          const SectionHeader('Emergency Contacts'),
          TextField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact phone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addContact(controller),
              child: const Text('Add contact'),
            ),
          ),
          const SizedBox(height: 12),
          if (settings.emergencyContacts.isEmpty)
            const Text('No emergency contacts added yet.'),
          if (settings.emergencyContacts.isNotEmpty)
            ...settings.emergencyContacts.asMap().entries.map(
                  (entry) => ListTile(
                    title: Text(
                      entry.value.name.isNotEmpty
                          ? entry.value.name
                          : 'Emergency contact',
                    ),
                    subtitle: Text(entry.value.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          controller.removeEmergencyContactAt(entry.key),
                    ),
                  ),
                ),
            const SectionHeader('Crisis Support'),
            Text(
              'Set local numbers so the crisis screen can open the right number.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emergencyNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Local emergency number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _crisisLabelController,
              decoration: const InputDecoration(
                labelText: 'Crisis line label',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _crisisNumberController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Crisis line number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateEmergencyNumbers(
                  localEmergency: _emergencyNumberController.text.trim(),
                  crisisLine: _crisisNumberController.text.trim(),
                  crisisLabel: _crisisLabelController.text.trim(),
                ),
                child: const Text('Save crisis numbers'),
              ),
            ),
            const SectionHeader('Reflection'),
            SwitchListTile(
              title: const Text('Offer a brief reflection prompt after sessions'),
              value: settings.reflectionEnabled,
              onChanged: (value) => controller.updateReflection(value),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app does not replace professional care. If you are in immediate danger, call your local emergency number.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).round(),
          label: value.round().toString(),
          onChanged: onChanged,
          onChangeEnd: onChangeEnd,
        ),
      ],
    );
  }
}
