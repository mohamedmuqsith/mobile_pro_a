import '../models/recommendation.dart';
import '../../health_records/models/health_record.dart';
import '../../../core/database/database_helper.dart';
import '../../auth/models/user.dart' show User;

class RecommendationService {
  static final RecommendationService instance = RecommendationService._init();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  RecommendationService._init();

  // Health standards/targets
  static const int TARGET_STEPS = 10000;
  static const int TARGET_WATER = 2000; // ml
  static const int TARGET_CALORIES = 300;
  static const int MIN_STEPS = 5000;
  static const int MIN_WATER = 1500;
  static const int MIN_CALORIES = 200;

  /// Generate AI-powered recommendations based on user's health data
  Future<List<Recommendation>> generateRecommendations({User? user}) async {
    List<Recommendation> recommendations = [];

    // Get last 7 days of health records
    final records = await _dbHelper.getAllRecords();
    if (records.isEmpty) {
      return _getWelcomeRecommendations();
    }

    // Get recent records (last 7 days)
    final now = DateTime.now();
    final last7Days = records.where((record) {
      final recordDate = DateTime.parse(record.date);
      return now.difference(recordDate).inDays < 7;
    }).toList();

    if (last7Days.isEmpty) {
      return _getInactiveUserRecommendations();
    }

    // Calculate averages
    final avgSteps = _calculateAverage(last7Days.map((r) => r.steps).toList());
    final avgWater = _calculateAverage(last7Days.map((r) => r.water).toList());
    final avgCalories = _calculateAverage(last7Days.map((r) => r.calories).toList());

    // Get today's record
    final today = _formatDate(DateTime.now());
    final todayRecord = records.firstWhere(
      (r) => r.date == today,
      orElse: () => HealthRecord(date: today, steps: 0, calories: 0, water: 0),
    );

    // Generate recommendations based on data
    recommendations.addAll(_analyzeHydration(avgWater, todayRecord.water));
    recommendations.addAll(_analyzeActivity(avgSteps, todayRecord.steps));
    recommendations.addAll(_analyzeNutrition(avgCalories, todayRecord.calories));
    recommendations.addAll(_analyzeStreak(last7Days));
    recommendations.addAll(_analyzeGoals(avgSteps, avgWater, avgCalories, user));

    // Sort by priority
    recommendations.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return recommendations;
  }

  List<Recommendation> _analyzeHydration(int avgWater, int todayWater) {
    List<Recommendation> recs = [];

    if (avgWater < MIN_WATER) {
      recs.add(Recommendation(
        title: 'Increase Water Intake',
        description: 'Your average water intake is ${avgWater}ml. Try to drink at least ${TARGET_WATER}ml daily for optimal hydration.',
        category: RecommendationCategory.hydration,
        priority: RecommendationPriority.high,
      ));
    } else if (avgWater < TARGET_WATER) {
      recs.add(Recommendation(
        title: 'Almost There!',
        description: 'You\'re drinking ${avgWater}ml on average. Add ${TARGET_WATER - avgWater}ml more to reach the ideal goal!',
        category: RecommendationCategory.hydration,
        priority: RecommendationPriority.medium,
      ));
    } else {
      recs.add(Recommendation(
        title: 'Excellent Hydration! 💧',
        description: 'You\'re averaging ${avgWater}ml of water daily. Keep up the great work!',
        category: RecommendationCategory.hydration,
        priority: RecommendationPriority.low,
      ));
    }

    if (todayWater < 1000) {
      recs.add(Recommendation(
        title: 'Drink Water Now!',
        description: 'You\'ve only logged ${todayWater}ml today. Stay hydrated!',
        category: RecommendationCategory.hydration,
        priority: RecommendationPriority.high,
      ));
    }

    return recs;
  }

  List<Recommendation> _analyzeActivity(int avgSteps, int todaySteps) {
    List<Recommendation> recs = [];

    if (avgSteps < MIN_STEPS) {
      recs.add(Recommendation(
        title: 'Increase Daily Activity',
        description: 'Your average is ${avgSteps} steps. Aim for at least ${TARGET_STEPS} steps daily for better health.',
        category: RecommendationCategory.activity,
        priority: RecommendationPriority.high,
      ));
    } else if (avgSteps < TARGET_STEPS) {
      final gap = TARGET_STEPS - avgSteps;
      recs.add(Recommendation(
        title: 'Keep Moving!',
        description: 'You\'re averaging ${avgSteps} steps. Just $gap more steps to reach ${TARGET_STEPS}!',
        category: RecommendationCategory.activity,
        priority: RecommendationPriority.medium,
      ));
    } else {
      recs.add(Recommendation(
        title: 'Amazing Activity Level! 🏃',
        description: 'You\'re averaging ${avgSteps} steps daily. You\'re exceeding the recommended goal!',
        category: RecommendationCategory.activity,
        priority: RecommendationPriority.low,
      ));
    }

    return recs;
  }

  List<Recommendation> _analyzeNutrition(int avgCalories, int todayCalories) {
    List<Recommendation> recs = [];

    if (avgCalories < MIN_CALORIES) {
      recs.add(Recommendation(
        title: 'Increase Activity for Calorie Burn',
        description: 'You\'re averaging ${avgCalories} calories burned. Aim for ${TARGET_CALORIES}+ through exercise.',
        category: RecommendationCategory.nutrition,
        priority: RecommendationPriority.medium,
      ));
    } else if (avgCalories >= MIN_CALORIES && avgCalories < TARGET_CALORIES) {
      recs.add(Recommendation(
        title: 'Good Calorie Burn',
        description: 'Averaging ${avgCalories} calories burned. Keep being active!',
        category: RecommendationCategory.nutrition,
        priority: RecommendationPriority.low,
      ));
    } else {
      recs.add(Recommendation(
        title: 'Excellent Calorie Management! 🔥',
        description: 'You\'re burning ${avgCalories} calories on average. Fantastic work!',
        category: RecommendationCategory.nutrition,
        priority: RecommendationPriority.low,
      ));
    }

    return recs;
  }

  List<Recommendation> _analyzeStreak(List<HealthRecord> last7Days) {
    List<Recommendation> recs = [];

    if (last7Days.length >= 7) {
      recs.add(Recommendation(
        title: 'Perfect Week! 🎉',
        description: 'You\'ve logged health data for 7 consecutive days! You\'re building a great habit.',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.low,
      ));
    } else if (last7Days.length >= 3) {
      recs.add(Recommendation(
        title: '${last7Days.length}-Day Streak!',
        description: 'Keep logging daily to maintain your streak and track progress!',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.medium,
      ));
    }

    return recs;
  }

  List<Recommendation> _analyzeGoals(int avgSteps, int avgWater, int avgCalories, User? user) {
    List<Recommendation> recs = [];

    // Comprehensive health score
    int score = 0;
    if (avgSteps >= TARGET_STEPS) score++;
    if (avgWater >= TARGET_WATER) score++;
    if (avgCalories >= TARGET_CALORIES) score++;

    if (score == 3) {
      recs.add(Recommendation(
        title: 'Health Champion! 🏆',
        description: 'You\'re meeting all your health goals! You\'re doing amazing!',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.low,
      ));
    } else if (score == 0) {
      recs.add(Recommendation(
        title: 'Start Small, Dream Big',
        description: 'Set achievable daily goals: 8,000 steps, 1,500ml water, 250 calories burned.',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.high,
      ));
    }

    // User-specific recommendations
    if (user != null && user.age > 0) {
      if (user.age > 50) {
        recs.add(Recommendation(
          title: 'Age-Appropriate Exercise',
          description: 'Focus on low-impact activities like walking, swimming, or yoga for joint health.',
          category: RecommendationCategory.general,
          priority: RecommendationPriority.medium,
        ));
      } else if (user.age < 30) {
        recs.add(Recommendation(
          title: 'Build Healthy Habits Early',
          description: 'Your 20s are perfect for establishing lifelong fitness routines!',
          category: RecommendationCategory.general,
          priority: RecommendationPriority.low,
        ));
      }
    }

    return recs;
  }

  List<Recommendation> _getWelcomeRecommendations() {
    return [
      Recommendation(
        title: 'Welcome to HealthMate! 👋',
        description: 'Start logging your daily health data to get personalized AI recommendations.',
        category: RecommendationCategory.general,
        priority: RecommendationPriority.high,
      ),
      Recommendation(
        title: 'Set Your Goals',
        description: 'Aim for 10,000 steps, 2,000ml water, and 300+ calories burned daily.',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.medium,
      ),
    ];
  }

  List<Recommendation> _getInactiveUserRecommendations() {
    return [
      Recommendation(
        title: 'We Miss You! 👋',
        description: 'You haven\'t logged health data recently. Start tracking again to get personalized insights!',
        category: RecommendationCategory.general,
        priority: RecommendationPriority.high,
      ),
      Recommendation(
        title: 'Consistency is Key',
        description: 'Log your health data daily to track progress and build healthy habits.',
        category: RecommendationCategory.goals,
        priority: RecommendationPriority.medium,
      ),
    ];
  }

  int _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) ~/ values.length;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
