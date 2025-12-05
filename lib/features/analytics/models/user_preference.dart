class UserPreference {
  final int? id;
  final String key;
  final String value;
  final String changedAt;

  UserPreference({
    this.id,
    required this.key,
    required this.value,
    required this.changedAt,
  });

  // Preference Keys
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String dailyStepsGoal = 'daily_steps_goal';
  static const String dailyCaloriesGoal = 'daily_calories_goal';
  static const String dailyWaterGoal = 'daily_water_goal';
  static const String reminderTime = 'reminder_time';
  static const String useMetricUnits = 'use_metric_units';
  static const String autoBackup = 'auto_backup';
  static const String defaultScreen = 'default_screen';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'changed_at': changedAt,
    };
  }

  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
      changedAt: map['changed_at'] as String,
    );
  }

  factory UserPreference.create(String key, String value) {
    return UserPreference(
      key: key,
      value: value,
      changedAt: DateTime.now().toIso8601String(),
    );
  }

  UserPreference copyWith({
    int? id,
    String? key,
    String? value,
    String? changedAt,
  }) {
    return UserPreference(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  String toString() {
    return 'UserPreference(key: $key, value: $value, changed: $changedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserPreference &&
        other.id == id &&
        other.key == key &&
        other.value == value;
  }

  @override
  int get hashCode {
    return id.hashCode ^ key.hashCode ^ value.hashCode;
  }
}
