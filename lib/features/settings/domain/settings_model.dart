class SettingsModel {
  final bool notificationsEnabled;
  final String theme; // 'light' or 'dark'
  final String language; // 'ja', 'en'

  SettingsModel({
    required this.notificationsEnabled,
    required this.theme,
    required this.language,
  });

  Map<String, dynamic> toMap() => {
    'notificationsEnabled': notificationsEnabled,
    'theme': theme,
    'language': language,
  };

  factory SettingsModel.fromMap(Map<String, dynamic> map) => SettingsModel(
    notificationsEnabled: map['notificationsEnabled'] ?? true,
    theme: map['theme'] ?? 'light',
    language: map['language'] ?? 'ja',
  );
}
