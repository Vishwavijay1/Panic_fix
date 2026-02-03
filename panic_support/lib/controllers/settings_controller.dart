import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController();

  static const _prefsKey = 'panic_support_settings_v2';

  AppSettings _settings = AppSettings.defaults();

  AppSettings get settings => _settings;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _settings = AppSettings.fromJson(raw);
      } catch (_) {
        _settings = AppSettings.defaults();
      }
    } else {
      _settings = AppSettings.defaults();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _settings.toJson());
  }

  Future<void> update(AppSettings settings) async {
    _settings = settings;
    notifyListeners();
    await _save();
  }

  Future<void> updateBreathing({
    required int inhale,
    required int exhale,
    required int pause,
  }) {
    return update(_settings.copyWith(
      inhaleSeconds: inhale,
      exhaleSeconds: exhale,
      pauseSeconds: pause,
    ));
  }

  Future<void> updateAudio(bool enabled) {
    return update(_settings.copyWith(audioEnabled: enabled));
  }

  Future<void> updateAudioVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0).toDouble();
    return update(_settings.copyWith(audioVolume: clamped));
  }

  Future<void> updateEarlyWarning({
    required bool enabled,
    required int seconds,
  }) {
    return update(_settings.copyWith(
      earlyWarningEnabled: enabled,
      earlyWarningSeconds: seconds,
    ));
  }

  Future<void> updateReflection(bool enabled) {
    return update(_settings.copyWith(reflectionEnabled: enabled));
  }

  Future<void> updateEmergencyNumbers({
    required String? localEmergency,
    required String? crisisLine,
    required String? crisisLabel,
  }) {
    String? clean(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    return update(_settings.copyWith(
      localEmergencyNumber: clean(localEmergency),
      crisisHotlineNumber: clean(crisisLine),
      crisisHotlineLabel: clean(crisisLabel),
    ));
  }

  Future<void> addEmergencyContact(EmergencyContact contact) {
    final updated = [..._settings.emergencyContacts, contact];
    return update(_settings.copyWith(emergencyContacts: updated));
  }

  Future<void> removeEmergencyContactAt(int index) {
    final updated = [..._settings.emergencyContacts];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
    }
    return update(_settings.copyWith(emergencyContacts: updated));
  }

  Future<void> clearEmergencyContacts() {
    return update(_settings.copyWith(emergencyContacts: []));
  }

  Future<void> updateThemePreference(ThemePreference preference) {
    return update(_settings.copyWith(themePreference: preference));
  }

  Future<void> addCustomGrounding(String statement) {
    final updated = [..._settings.customGroundingStatements, statement.trim()];
    return update(_settings.copyWith(customGroundingStatements: updated));
  }

  Future<void> removeCustomGroundingAt(int index) {
    final updated = [..._settings.customGroundingStatements];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
    }
    return update(_settings.copyWith(customGroundingStatements: updated));
  }
}
