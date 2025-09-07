class AppSettingsDB {
  final String mediumAlertTone;
  final String loudAlertTone;
  final bool batteryUnrestricted;

  AppSettingsDB({
    required this.mediumAlertTone,
    required this.loudAlertTone,
    required this.batteryUnrestricted,
  });

  factory AppSettingsDB.defaults() => AppSettingsDB(
        mediumAlertTone: '',
        loudAlertTone: '',
        batteryUnrestricted: false,
      );

  factory AppSettingsDB.fromMap(Map<String, Object?> m) => AppSettingsDB(
        mediumAlertTone: (m['medium_alert_tone'] as String?) ?? '',
        loudAlertTone: (m['loud_alert_tone'] as String?) ?? '',
        batteryUnrestricted: ((m['battery_unrestricted'] as int?) ?? 0) == 1,
      );

  Map<String, Object?> toMap() => {
        'medium_alert_tone': mediumAlertTone,
        'loud_alert_tone': loudAlertTone,
        'battery_unrestricted': batteryUnrestricted ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      };

  AppSettingsDB copyWith({
    String? mediumAlertTone,
    String? loudAlertTone,
    bool? batteryUnrestricted,
  }) =>
      AppSettingsDB(
        mediumAlertTone: mediumAlertTone ?? this.mediumAlertTone,
        loudAlertTone: loudAlertTone ?? this.loudAlertTone,
        batteryUnrestricted: batteryUnrestricted ?? this.batteryUnrestricted,
      );
}
