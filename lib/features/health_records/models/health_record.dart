import 'package:intl/intl.dart';

class HealthRecord {
  final int? id;
  final String date;
  final int steps;
  final int calories;
  final int water; // in ml

  HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  // Convert HealthRecord to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }

  // Create HealthRecord from Map (database query result)
  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      steps: map['steps'] as int,
      calories: map['calories'] as int,
      water: map['water'] as int,
    );
  }

  // Create a copy with updated fields
  HealthRecord copyWith({
    int? id,
    String? date,
    int? steps,
    int? calories,
    int? water,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
    );
  }

  // Format date for display (e.g., "Nov 24, 2025")
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Format date for short display (e.g., "Nov 24")
  String get shortFormattedDate {
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('MMM dd').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  // Format water intake for display (e.g., "2.0 L")
  String get formattedWater {
    return '${(water / 1000).toStringAsFixed(1)} L';
  }

  // Validation methods
  bool get isValid {
    return steps >= 0 && calories >= 0 && water >= 0 && date.isNotEmpty;
  }

  String? validate() {
    if (date.isEmpty) {
      return 'Date is required';
    }
    if (steps < 0) {
      return 'Steps must be a positive number';
    }
    if (calories < 0) {
      return 'Calories must be a positive number';
    }
    if (water < 0) {
      return 'Water intake must be a positive number';
    }
    return null; // No errors
  }

  @override
  String toString() {
    return 'HealthRecord(id: $id, date: $date, steps: $steps, calories: $calories, water: $water ml)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HealthRecord &&
        other.id == id &&
        other.date == date &&
        other.steps == steps &&
        other.calories == calories &&
        other.water == water;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        steps.hashCode ^
        calories.hashCode ^
        water.hashCode;
  }
}
