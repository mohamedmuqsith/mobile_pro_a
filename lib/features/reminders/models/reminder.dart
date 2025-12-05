enum ReminderFrequency {
  once,
  daily,
  weekly,
  custom,
}

class Reminder {
  final int? id;
  final String title;
  final String message;
  final int hour; // 0-23
  final int minute; // 0-59
  final ReminderFrequency frequency;
  final bool enabled;
  final String createdAt;

  Reminder({
    this.id,
    required this.title,
    required this.message,
    required this.hour,
    required this.minute,
    this.frequency = ReminderFrequency.daily,
    this.enabled = true,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  String get timeString {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }

  String get frequencyLabel {
    switch (frequency) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'hour': hour,
      'minute': minute,
      'frequency': frequency.toString(),
      'enabled': enabled ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      message: map['message'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.toString() == map['frequency'],
        orElse: () => ReminderFrequency.daily,
      ),
      enabled: map['enabled'] == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Reminder copyWith({
    int? id,
    String? title,
    String? message,
    int? hour,
    int? minute,
    ReminderFrequency? frequency,
    bool? enabled,
    String? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      frequency: frequency ?? this.frequency,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Default reminders
  static List<Reminder> getDefaultReminders() {
    return [
      Reminder(
        title: 'Morning Hydration 💧',
        message: 'Start your day with a glass of water!',
        hour: 8,
        minute: 0,
      ),
      Reminder(
        title: 'Mid-Morning Steps 🏃',
        message: 'Take a 10-minute walk break!',
        hour: 11,
        minute: 0,
      ),
      Reminder(
        title: 'Afternoon Hydration 💧',
        message: 'Stay hydrated! Drink some water.',
        hour: 14,
        minute: 0,
      ),
      Reminder(
        title: 'Evening Steps Check 📊',
        message: 'How many steps have you taken today?',
        hour: 17,
        minute: 0,
      ),
      Reminder(
        title: 'Log Your Health Data 📝',
        message: 'Don\'t forget to log your daily health metrics!',
        hour: 21,
        minute: 0,
      ),
    ];
  }
}
