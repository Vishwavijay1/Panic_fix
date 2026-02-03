import 'dart:convert';

enum ThemePreference { system, day, night }

class EmergencyContact {
  final String name;
  final String phone;

  const EmergencyContact({required this.name, required this.phone});

  EmergencyContact copyWith({String? name, String? phone}) {
    return EmergencyContact(
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
      };

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      name: (map['name'] as String?)?.trim() ?? '',
      phone: (map['phone'] as String?)?.trim() ?? '',
    );
  }
}

class AppSettings {
  final int inhaleSeconds;
  final int exhaleSeconds;
  final int pauseSeconds;
  final bool audioEnabled;
  final bool earlyWarningEnabled;
  final int earlyWarningSeconds;
  final bool reflectionEnabled;
  final List<String> customGroundingStatements;
  final EmergencyContact? emergencyContact;
  final String? localEmergencyNumber;
  final String? crisisHotlineNumber;
  final String? crisisHotlineLabel;
  final ThemePreference themePreference;

  const AppSettings({
    required this.inhaleSeconds,
    required this.exhaleSeconds,
    required this.pauseSeconds,
    required this.audioEnabled,
    required this.earlyWarningEnabled,
    required this.earlyWarningSeconds,
    required this.reflectionEnabled,
    required this.customGroundingStatements,
    required this.emergencyContact,
    required this.localEmergencyNumber,
    required this.crisisHotlineNumber,
    required this.crisisHotlineLabel,
    required this.themePreference,
  });

  AppSettings copyWith({
    int? inhaleSeconds,
    int? exhaleSeconds,
    int? pauseSeconds,
    bool? audioEnabled,
    bool? earlyWarningEnabled,
    int? earlyWarningSeconds,
    bool? reflectionEnabled,
    List<String>? customGroundingStatements,
    EmergencyContact? emergencyContact,
    String? localEmergencyNumber,
    String? crisisHotlineNumber,
    String? crisisHotlineLabel,
    ThemePreference? themePreference,
  }) {
    return AppSettings(
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      pauseSeconds: pauseSeconds ?? this.pauseSeconds,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      earlyWarningEnabled: earlyWarningEnabled ?? this.earlyWarningEnabled,
      earlyWarningSeconds: earlyWarningSeconds ?? this.earlyWarningSeconds,
      reflectionEnabled: reflectionEnabled ?? this.reflectionEnabled,
      customGroundingStatements:
          customGroundingStatements ?? this.customGroundingStatements,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      localEmergencyNumber: localEmergencyNumber ?? this.localEmergencyNumber,
      crisisHotlineNumber: crisisHotlineNumber ?? this.crisisHotlineNumber,
      crisisHotlineLabel: crisisHotlineLabel ?? this.crisisHotlineLabel,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  Map<String, dynamic> toMap() => {
        'inhaleSeconds': inhaleSeconds,
        'exhaleSeconds': exhaleSeconds,
        'pauseSeconds': pauseSeconds,
        'audioEnabled': audioEnabled,
        'earlyWarningEnabled': earlyWarningEnabled,
        'earlyWarningSeconds': earlyWarningSeconds,
        'reflectionEnabled': reflectionEnabled,
        'customGroundingStatements': customGroundingStatements,
        'emergencyContact': emergencyContact?.toMap(),
        'localEmergencyNumber': localEmergencyNumber,
        'crisisHotlineNumber': crisisHotlineNumber,
        'crisisHotlineLabel': crisisHotlineLabel,
        'themePreference': themePreference.name,
      };

  String toJson() => jsonEncode(toMap());

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final rawCustom = map['customGroundingStatements'];
    final customList = rawCustom is List
        ? rawCustom.whereType<String>().map((e) => e.trim()).toList()
        : <String>[];
    final emergencyMap = map['emergencyContact'];

    EmergencyContact? contact;
    if (emergencyMap is Map<String, dynamic>) {
      contact = EmergencyContact.fromMap(emergencyMap);
      if (contact.name.isEmpty && contact.phone.isEmpty) {
        contact = null;
      }
    }

    final rawTheme = map['themePreference'] as String?;
    final themePreference = ThemePreference.values.firstWhere(
      (value) => value.name == rawTheme,
      orElse: () => ThemePreference.system,
    );

    return AppSettings(
      inhaleSeconds: (map['inhaleSeconds'] as num?)?.toInt() ?? 4,
      exhaleSeconds: (map['exhaleSeconds'] as num?)?.toInt() ?? 6,
      pauseSeconds: (map['pauseSeconds'] as num?)?.toInt() ?? 2,
      audioEnabled: map['audioEnabled'] as bool? ?? false,
      earlyWarningEnabled: map['earlyWarningEnabled'] as bool? ?? true,
      earlyWarningSeconds: (map['earlyWarningSeconds'] as num?)?.toInt() ?? 60,
      reflectionEnabled: map['reflectionEnabled'] as bool? ?? false,
      customGroundingStatements: customList,
      emergencyContact: contact,
      localEmergencyNumber: map['localEmergencyNumber'] as String?,
      crisisHotlineNumber: map['crisisHotlineNumber'] as String?,
      crisisHotlineLabel: map['crisisHotlineLabel'] as String?,
      themePreference: themePreference,
    );
  }

  factory AppSettings.fromJson(String source) {
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    return AppSettings.fromMap(decoded);
  }

  factory AppSettings.defaults() {
    return const AppSettings(
      inhaleSeconds: 4,
      exhaleSeconds: 6,
      pauseSeconds: 2,
      audioEnabled: false,
      earlyWarningEnabled: true,
      earlyWarningSeconds: 60,
      reflectionEnabled: false,
      customGroundingStatements: [],
      emergencyContact: null,
      localEmergencyNumber: '112',
      crisisHotlineNumber: '+91 9152987821',
      crisisHotlineLabel: 'iCall Helpline Service',
      themePreference: ThemePreference.system,
    );
  }
}
