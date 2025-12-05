import 'package:flutter/material.dart';

enum RecommendationCategory {
  hydration,
  activity,
  nutrition,
  goals,
  general,
}

enum RecommendationPriority {
  high,
  medium,
  low,
}

class Recommendation {
  final int? id;
  final String title;
  final String description;
  final RecommendationCategory category;
  final RecommendationPriority priority;
  final String timestamp;
  final IconData icon;
  final Color color;

  Recommendation({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    String? timestamp,
  })  : timestamp = timestamp ?? DateTime.now().toIso8601String(),
        icon = _getIconForCategory(category),
        color = _getColorForCategory(category);

  static IconData _getIconForCategory(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.hydration:
        return Icons.water_drop;
      case RecommendationCategory.activity:
        return Icons.directions_run;
      case RecommendationCategory.nutrition:
        return Icons.local_fire_department;
      case RecommendationCategory.goals:
        return Icons.emoji_events;
      case RecommendationCategory.general:
        return Icons.lightbulb;
    }
  }

  static Color _getColorForCategory(RecommendationCategory category) {
    switch (category) {
      case RecommendationCategory.hydration:
        return Colors.blue;
      case RecommendationCategory.activity:
        return Colors.green;
      case RecommendationCategory.nutrition:
        return Colors.orange;
      case RecommendationCategory.goals:
        return Colors.amber;
      case RecommendationCategory.general:
        return Colors.purple;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case RecommendationPriority.high:
        return Colors.red;
      case RecommendationPriority.medium:
        return Colors.orange;
      case RecommendationPriority.low:
        return Colors.blue;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case RecommendationPriority.high:
        return 'HIGH PRIORITY';
      case RecommendationPriority.medium:
        return 'MEDIUM PRIORITY';
      case RecommendationPriority.low:
        return 'LOW PRIORITY';
    }
  }

  String get categoryLabel {
    switch (category) {
      case RecommendationCategory.hydration:
        return 'Hydration';
      case RecommendationCategory.activity:
        return 'Activity';
      case RecommendationCategory.nutrition:
        return 'Nutrition';
      case RecommendationCategory.goals:
        return 'Goals';
      case RecommendationCategory.general:
        return 'General';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.toString(),
      'priority': priority.toString(),
      'timestamp': timestamp,
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: RecommendationCategory.values.firstWhere(
        (e) => e.toString() == map['category'],
        orElse: () => RecommendationCategory.general,
      ),
      priority: RecommendationPriority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => RecommendationPriority.low,
      ),
      timestamp: map['timestamp'] as String,
    );
  }
}
