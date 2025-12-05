import 'package:flutter/material.dart';
import '../models/app_event.dart';
import '../models/user_session.dart';
import '../models/health_analytics.dart';
import '../services/analytics_service.dart';
import '../services/health_analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  final HealthAnalyticsService _healthAnalyticsService = HealthAnalyticsService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  // Analytics Data
  Map<String, int> _eventCounts = {};
  Map<String, int> _screenViewCounts = {};
  List<UserSession> _recentSessions = [];
  HealthAnalytics _healthAnalytics = HealthAnalytics.empty();
  List<String> _insights = [];
  List<Map<String, dynamic>> _weeklyTrend = [];
  int _totalSessionDuration = 0;
  int _sessionCount = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get eventCounts => _eventCounts;
  Map<String, int> get screenViewCounts => _screenViewCounts;
  List<UserSession> get recentSessions => _recentSessions;
  HealthAnalytics get healthAnalytics => _healthAnalytics;
  List<String> get insights => _insights;
  List<Map<String, dynamic>> get weeklyTrend => _weeklyTrend;
  int get totalSessionDuration => _totalSessionDuration;
  int get sessionCount => _sessionCount;

  // Initialize
  Future<void> initialize() async {
    await loadAnalyticsData();
  }

  // Load all analytics data
  Future<void> loadAnalyticsData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load app analytics
      _eventCounts = await _analyticsService.getEventCountByType();
      _screenViewCounts = await _analyticsService.getScreenViewCounts();
      _recentSessions = await _analyticsService.getRecentSessions(7);
      _totalSessionDuration = await _analyticsService.getTotalSessionDuration();
      _sessionCount = await _analyticsService.getSessionCount();

      // Load health analytics
      _healthAnalytics = await _healthAnalyticsService.getComprehensiveAnalytics();
      _insights = await _healthAnalyticsService.generateInsights();
      _weeklyTrend = await _healthAnalyticsService.getWeeklyTrend();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load analytics: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Track events through provider
  Future<void> trackScreenView(String screenName) async {
    await _analyticsService.trackScreenView(screenName);
  }

  Future<void> trackButtonClick(String screenName, String buttonName) async {
    await _analyticsService.trackButtonClick(screenName, buttonName);
  }

  Future<void> trackRecordAdded() async {
    await _analyticsService.trackRecordAdded();
    await loadAnalyticsData(); // Refresh analytics
  }

  Future<void> trackRecordUpdated() async {
    await _analyticsService.trackRecordUpdated();
    await loadAnalyticsData();
  }

  Future<void> trackRecordDeleted() async {
    await _analyticsService.trackRecordDeleted();
    await loadAnalyticsData();
  }

  // Session management
  Future<void> startSession() async {
    await _analyticsService.startSession();
  }

  Future<void> endSession() async {
    await _analyticsService.endSession();
  }

  // Preferences
  Future<void> savePreference(String key, String value) async {
    await _analyticsService.savePreference(key, value);
    notifyListeners();
  }

  Future<String?> getPreference(String key) async {
    return await _analyticsService.getPreference(key);
  }

  Future<Map<String, String>> getAllPreferences() async {
    return await _analyticsService.getAllPreferences();
  }

  // Get formatted session duration
  String get formattedTotalDuration {
    if (_totalSessionDuration < 60) {
      return '${_totalSessionDuration}s';
    } else if (_totalSessionDuration < 3600) {
      final minutes = (_totalSessionDuration / 60).floor();
      return '${minutes}m';
    } else {
      final hours = (_totalSessionDuration / 3600).floor();
      final minutes = ((_totalSessionDuration % 3600) / 60).floor();
      return '${hours}h ${minutes}m';
    }
  }

  // Get most viewed screen
  String get mostViewedScreen {
    if (_screenViewCounts.isEmpty) return 'N/A';
    var sorted = _screenViewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
