import '../models/app_event.dart';
import '../models/user_session.dart';
import '../models/user_preference.dart';
import '../../../core/database/analytics_database_helper.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._init();
  final AnalyticsDatabaseHelper _dbHelper = AnalyticsDatabaseHelper.instance;
  
  UserSession? _currentSession;
  final Set<String> _visitedScreens = {};

  AnalyticsService._init();

  // ============ SESSION MANAGEMENT ============
  
  Future<void> startSession() async {
    _currentSession = UserSession.start();
    final id = await _dbHelper.insertSession(_currentSession!);
    _currentSession = _currentSession!.copyWith(id: id);
    _visitedScreens.clear();
  }

  Future<void> endSession() async {
    if (_currentSession != null) {
      final updatedSession = _currentSession!.end();
      await _dbHelper.updateSession(updatedSession);
      _currentSession = null;
      _visitedScreens.clear();
    }
  }

  Future<void> updateSession() async {
    if (_currentSession != null) {
      await _dbHelper.updateSession(_currentSession!);
    }
  }

  // ============ EVENT TRACKING ============
  
  Future<void> trackEvent(AppEvent event) async {
    await _dbHelper.insertEvent(event);
  }

  Future<void> trackScreenView(String screenName, {Map<String, dynamic>? metadata}) async {
    final event = AppEvent.screenView(screenName, metadata: metadata);
    await trackEvent(event);
    
    // Update current session
    if (_currentSession != null && !_visitedScreens.contains(screenName)) {
      _visitedScreens.add(screenName);
      _currentSession = _currentSession!.addScreen(screenName);
      await updateSession();
    }
  }

  Future<void> trackButtonClick(String screenName, String buttonName, {Map<String, dynamic>? metadata}) async {
    final event = AppEvent.buttonClick(screenName, buttonName, metadata: metadata);
    await trackEvent(event);
  }

  Future<void> trackRecordAdded({Map<String, dynamic>? metadata}) async {
    final event = AppEvent.recordAction(
      AppEvent.eventRecordAdded,
      'AddRecordScreen',
      metadata: metadata,
    );
    await trackEvent(event);
  }

  Future<void> trackRecordUpdated({Map<String, dynamic>? metadata}) async {
    final event = AppEvent.recordAction(
      AppEvent.eventRecordUpdated,
      'AddRecordScreen',
      metadata: metadata,
    );
    await trackEvent(event);
  }

  Future<void> trackRecordDeleted({Map<String, dynamic>? metadata}) async {
    final event = AppEvent.recordAction(
      AppEvent.eventRecordDeleted,
      'RecordsListScreen',
      metadata: metadata,
    );
    await trackEvent(event);
  }

  Future<void> trackSearch(String searchQuery, {Map<String, dynamic>? metadata}) async {
    final event = AppEvent(
      eventType: AppEvent.eventSearchPerformed,
      screenName: 'RecordsListScreen',
      actionName: 'search',
      timestamp: DateTime.now().toIso8601String(),
      metadata: {...?metadata, 'query': searchQuery},
    );
    await trackEvent(event);
  }

  Future<void> trackNavigation(String destination) async {
    final event = AppEvent(
      eventType: AppEvent.eventNavigationTap,
      screenName: 'Navigation',
      actionName: destination,
      timestamp: DateTime.now().toIso8601String(),
    );
    await trackEvent(event);
  }

  // ============ PREFERENCES ============
  
  Future<void> savePreference(String key, String value) async {
    final existing = await _dbHelper.getPreferenceByKey(key);
    final preference = UserPreference.create(key, value);
    
    if (existing != null) {
      await _dbHelper.updatePreference(preference);
    } else {
      await _dbHelper.insertPreference(preference);
    }
  }

  Future<String?> getPreference(String key) async {
    final preference = await _dbHelper.getPreferenceByKey(key);
    return preference?.value;
  }

  Future<Map<String, String>> getAllPreferences() async {
    final preferences = await _dbHelper.getAllPreferences();
    return Map.fromEntries(
      preferences.map((p) => MapEntry(p.key, p.value)),
    );
  }

  // ============ ANALYTICS QUERIES ============
  
  Future<List<AppEvent>> getAllEvents() async {
    return await _dbHelper.getAllEvents();
  }

  Future<List<AppEvent>> getEventsByType(String eventType) async {
    return await _dbHelper.getEventsByType(eventType);
  }

  Future<Map<String, int>> getEventCountByType() async {
    return await _dbHelper.getEventCountByType();
  }

  Future<Map<String, int>> getScreenViewCounts() async {
    return await _dbHelper.getScreenViewCounts();
  }

  Future<List<UserSession>> getAllSessions() async {
    return await _dbHelper.getAllSessions();
  }

  Future<int> getTotalSessionDuration() async {
    return await _dbHelper.getTotalSessionDuration();
  }

  Future<int> getSessionCount() async {
    return await _dbHelper.getSessionCount();
  }

  Future<List<UserSession>> getRecentSessions(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    return await _dbHelper.getSessionsByDateRange(
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    );
  }

  // ============ CLEANUP ============
  
  Future<void> cleanupOldData({int daysToKeep = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final cutoffString = cutoffDate.toIso8601String();
    
    await _dbHelper.deleteOldEvents(cutoffString);
    await _dbHelper.deleteOldSessions(cutoffString);
  }

  // ============ UTILITY ============
  
  String get currentSessionId => _currentSession?.id?.toString() ?? 'no_session';
  bool get hasActiveSession => _currentSession != null;
}
