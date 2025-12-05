import 'package:intl/intl.dart';
import '../models/health_analytics.dart';
import '../../health_records/models/health_record.dart';
import '../../../core/database/database_helper.dart';

class HealthAnalyticsService {
  static final HealthAnalyticsService instance = HealthAnalyticsService._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  HealthAnalyticsService._init();

  // ============ STREAK CALCULATION ============
  
  Future<Map<String, int>> calculateStreaks() async {
    final records = await _dbHelper.getAllRecords();
    
    if (records.isEmpty) {
      return {
        'current_streak': 0,
        'longest_streak': 0,
      };
    }

    // Sort by date descending
    records.sort((a, b) => b.date.compareTo(a.date));

    // Get unique dates
    final uniqueDates = records.map((r) => r.date).toSet().toList();
    uniqueDates.sort((a, b) => b.compareTo(a));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    final today = _formatDate(DateTime.now());
    final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));

    // Calculate current streak
    if (uniqueDates.contains(today)) {
      currentStreak = 1;
      DateTime checkDate = DateTime.now().subtract(const Duration(days: 1));
      
      while (uniqueDates.contains(_formatDate(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    } else if (uniqueDates.contains(yesterday)) {
      currentStreak = 1;
      DateTime checkDate = DateTime.now().subtract(const Duration(days: 2));
      
      while (uniqueDates.contains(_formatDate(checkDate))) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    // Calculate longest streak
    for (int i = 0; i < uniqueDates.length; i++) {
      if (i == 0) {
        tempStreak = 1;
      } else {
        final currentDate = DateTime.parse(uniqueDates[i]);
        final previousDate = DateTime.parse(uniqueDates[i - 1]);
        final difference = previousDate.difference(currentDate).inDays;

        if (difference == 1) {
          tempStreak++;
        } else {
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
        }
      }
    }
    
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
  }

  // ============ AVERAGES ============
  
  Future<Map<String, int>> calculate7DayAverages() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 7));
    
    final records = await _dbHelper.getRecordsByDateRange(
      _formatDate(startDate),
      _formatDate(endDate),
    );

    if (records.isEmpty) {
      return {
        'avg_steps': 0,
        'avg_calories': 0,
        'avg_water': 0,
      };
    }

    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    final count = records.length;

    return {
      'avg_steps': (totalSteps / count).round(),
      'avg_calories': (totalCalories / count).round(),
      'avg_water': (totalWater / count).round(),
    };
  }

  Future<Map<String, int>> calculate30DayAverages() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    final records = await _dbHelper.getRecordsByDateRange(
      _formatDate(startDate),
      _formatDate(endDate),
    );

    if (records.isEmpty) {
      return {
        'avg_steps': 0,
        'avg_calories': 0,
        'avg_water': 0,
      };
    }

    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    final count = records.length;

    return {
      'avg_steps': (totalSteps / count).round(),
      'avg_calories': (totalCalories / count).round(),
      'avg_water': (totalWater / count).round(),
    };
  }

  // ============ PERSONAL RECORDS ============
  
  Future<Map<String, int>> getPersonalRecords() async {
    final records = await _dbHelper.getAllRecords();

    if (records.isEmpty) {
      return {
        'max_steps': 0,
        'max_calories': 0,
        'max_water': 0,
      };
    }

    int maxSteps = 0;
    int maxCalories = 0;
    int maxWater = 0;

    for (var record in records) {
      if (record.steps > maxSteps) maxSteps = record.steps;
      if (record.calories > maxCalories) maxCalories = record.calories;
      if (record.water > maxWater) maxWater = record.water;
    }

    return {
      'max_steps': maxSteps,
      'max_calories': maxCalories,
      'max_water': maxWater,
    };
  }

  // ============ TRENDS ============
  
  Future<List<Map<String, dynamic>>> getWeeklyTrend() async {
    final List<Map<String, dynamic>> weeklyData = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final records = await _dbHelper.getRecordsByDate(dateStr);

      int dailySteps = 0;
      int dailyCalories = 0;
      int dailyWater = 0;

      for (var record in records) {
        dailySteps += record.steps;
        dailyCalories += record.calories;
        dailyWater += record.water;
      }

      weeklyData.add({
        'date': dateStr,
        'day': DateFormat('EEE').format(date),
        'steps': dailySteps,
        'calories': dailyCalories,
        'water': dailyWater,
      });
    }

    return weeklyData;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrend() async {
    final List<Map<String, dynamic>> monthlyData = [];
    
    for (int i = 29; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final records = await _dbHelper.getRecordsByDate(dateStr);

      int dailySteps = 0;
      int dailyCalories = 0;
      int dailyWater = 0;

      for (var record in records) {
        dailySteps += record.steps;
        dailyCalories += record.calories;
        dailyWater += record.water;
      }

      monthlyData.add({
        'date': dateStr,
        'day': DateFormat('MMM d').format(date),
        'steps': dailySteps,
        'calories': dailyCalories,
        'water': dailyWater,
      });
    }

    return monthlyData;
  }

  // ============ COMPREHENSIVE ANALYTICS ============
  
  Future<HealthAnalytics> getComprehensiveAnalytics() async {
    final streaks = await calculateStreaks();
    final averages = await calculate7DayAverages();
    final allRecords = await _dbHelper.getAllRecords();

    return HealthAnalytics(
      date: DateTime.now().toIso8601String(),
      currentStreak: streaks['current_streak']!,
      longestStreak: streaks['longest_streak']!,
      avgSteps7d: averages['avg_steps']!,
      avgCalories7d: averages['avg_calories']!,
      avgWater7d: averages['avg_water']!,
      totalRecords: allRecords.length,
    );
  }

  // ============ INSIGHTS ============
  
  Future<List<String>> generateInsights() async {
    final List<String> insights = [];
    final streaks = await calculateStreaks();
    final averages = await calculate7DayAverages();
    final personalRecords = await getPersonalRecords();

    // Streak insights
    final currentStreak = streaks['current_streak']!;
    if (currentStreak >= 7) {
      insights.add('🔥 Amazing! You\'re on a $currentStreak day streak!');
    } else if (currentStreak >= 3) {
      insights.add('💪 Great job! Keep the $currentStreak day streak going!');
    } else if (currentStreak == 0) {
      insights.add('📈 Start a new streak today!');
    }

    // Steps insights
    final avgSteps = averages['avg_steps']!;
    if (avgSteps >= 10000) {
      insights.add('👟 Excellent! You\'re averaging over 10,000 steps!');
    } else if (avgSteps >= 7000) {
      insights.add('🚶 Good progress! Try to reach 10,000 steps daily.');
    }

    // Water insights
    final avgWater = averages['avg_water']!;
    if (avgWater >= 2000) {
      insights.add('💧 Great hydration! Keep it up!');
    } else if (avgWater > 0 && avgWater < 2000) {
      insights.add('💦 Try to drink at least 2L of water daily.');
    }

    // Personal records
    final maxSteps = personalRecords['max_steps']!;
    if (maxSteps > 0) {
      insights.add('🏆 Your personal best: $maxSteps steps in a day!');
    }

    return insights;
  }

  // ============ UTILITY ============
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
