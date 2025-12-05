class HealthAnalytics {
  final int? id;
  final String date;
  final int currentStreak;
  final int longestStreak;
  final int avgSteps7d;
  final int avgCalories7d;
  final int avgWater7d;
  final int totalRecords;

  HealthAnalytics({
    this.id,
    required this.date,
    required this.currentStreak,
    required this.longestStreak,
    required this.avgSteps7d,
    required this.avgCalories7d,
    required this.avgWater7d,
    required this.totalRecords,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'avg_steps_7d': avgSteps7d,
      'avg_calories_7d': avgCalories7d,
      'avg_water_7d': avgWater7d,
      'total_records': totalRecords,
    };
  }

  factory HealthAnalytics.fromMap(Map<String, dynamic> map) {
    return HealthAnalytics(
      id: map['id'] as int?,
      date: map['date'] as String,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      avgSteps7d: map['avg_steps_7d'] as int,
      avgCalories7d: map['avg_calories_7d'] as int,
      avgWater7d: map['avg_water_7d'] as int,
      totalRecords: map['total_records'] as int,
    );
  }

  factory HealthAnalytics.empty() {
    return HealthAnalytics(
      date: DateTime.now().toIso8601String(),
      currentStreak: 0,
      longestStreak: 0,
      avgSteps7d: 0,
      avgCalories7d: 0,
      avgWater7d: 0,
      totalRecords: 0,
    );
  }

  String get formattedWaterAverage {
    return '${(avgWater7d / 1000).toStringAsFixed(1)} L';
  }

  @override
  String toString() {
    return 'HealthAnalytics(streak: $currentStreak, avgSteps: $avgSteps7d, avgCalories: $avgCalories7d)';
  }
}
