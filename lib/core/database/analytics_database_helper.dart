import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import '../../features/analytics/models/app_event.dart';
import '../../features/analytics/models/user_session.dart';
import '../../features/analytics/models/user_preference.dart';

class AnalyticsDatabaseHelper {
  static final AnalyticsDatabaseHelper instance = AnalyticsDatabaseHelper._init();
  static Database? _database;

  AnalyticsDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('analytics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathStr = path_helper.join(dbPath, filePath);

    return await openDatabase(
      pathStr,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';

    // App Events Table
    await db.execute('''
      CREATE TABLE app_events (
        id $idType,
        event_type $textType,
        screen_name $textType,
        action_name $textType,
        timestamp $textType,
        metadata $textNullable
      )
    ''');

    // User Sessions Table
    await db.execute('''
      CREATE TABLE user_sessions (
        id $idType,
        start_time $textType,
        end_time $textNullable,
        duration $integerType,
        screens_visited $textNullable
      )
    ''');

    // User Preferences Table
    await db.execute('''
      CREATE TABLE user_preferences (
        id $idType,
        key $textType,
        value $textType,
        changed_at $textType
      )
    ''');

    // Health Analytics Table
    await db.execute('''
      CREATE TABLE health_analytics (
        id $idType,
        date $textType,
        current_streak $integerType,
        longest_streak $integerType,
        avg_steps_7d $integerType,
        avg_calories_7d $integerType,
        avg_water_7d $integerType,
        total_records $integerType
      )
    ''');
  }

  // ============ APP EVENTS ============
  
  Future<int> insertEvent(AppEvent event) async {
    final db = await database;
    return await db.insert('app_events', event.toMap());
  }

  Future<List<AppEvent>> getAllEvents() async {
    final db = await database;
    final result = await db.query('app_events', orderBy: 'timestamp DESC');
    return result.map((json) => AppEvent.fromMap(json)).toList();
  }

  Future<List<AppEvent>> getEventsByType(String eventType) async {
    final db = await database;
    final result = await db.query(
      'app_events',
      where: 'event_type = ?',
      whereArgs: [eventType],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => AppEvent.fromMap(json)).toList();
  }

  Future<List<AppEvent>> getEventsByDateRange(String startDate, String endDate) async {
    final db = await database;
    final result = await db.query(
      'app_events',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => AppEvent.fromMap(json)).toList();
  }

  // ============ USER SESSIONS ============
  
  Future<int> insertSession(UserSession session) async {
    final db = await database;
    return await db.insert('user_sessions', session.toMap());
  }

  Future<int> updateSession(UserSession session) async {
    final db = await database;
    return await db.update(
      'user_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<List<UserSession>> getAllSessions() async {
    final db = await database;
    final result = await db.query('user_sessions', orderBy: 'start_time DESC');
    return result.map((json) => UserSession.fromMap(json)).toList();
  }

  Future<UserSession?> getLatestSession() async {
    final db = await database;
    final result = await db.query(
      'user_sessions',
      orderBy: 'start_time DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return UserSession.fromMap(result.first);
    }
    return null;
  }

  Future<List<UserSession>> getSessionsByDateRange(String startDate, String endDate) async {
    final db = await database;
    final result = await db.query(
      'user_sessions',
      where: 'start_time BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'start_time DESC',
    );
    return result.map((json) => UserSession.fromMap(json)).toList();
  }

  // ============ USER PREFERENCES ============
  
  Future<int> insertPreference(UserPreference preference) async {
    final db = await database;
    return await db.insert('user_preferences', preference.toMap());
  }

  Future<int> updatePreference(UserPreference preference) async {
    final db = await database;
    return await db.update(
      'user_preferences',
      preference.toMap(),
      where: 'key = ?',
      whereArgs: [preference.key],
    );
  }

  Future<UserPreference?> getPreferenceByKey(String key) async {
    final db = await database;
    final result = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return UserPreference.fromMap(result.first);
    }
    return null;
  }

  Future<List<UserPreference>> getAllPreferences() async {
    final db = await database;
    final result = await db.query('user_preferences');
    return result.map((json) => UserPreference.fromMap(json)).toList();
  }

  // ============ ANALYTICS QUERIES ============
  
  Future<Map<String, int>> getEventCountByType() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT event_type, COUNT(*) as count
      FROM app_events
      GROUP BY event_type
    ''');
    
    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['event_type'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<Map<String, int>> getScreenViewCounts() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT screen_name, COUNT(*) as count
      FROM app_events
      WHERE event_type = 'screen_view'
      GROUP BY screen_name
      ORDER BY count DESC
    ''');
    
    Map<String, int> counts = {};
    for (var row in result) {
      counts[row['screen_name'] as String] = row['count'] as int;
    }
    return counts;
  }

  Future<int> getTotalSessionDuration() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(duration) as total
      FROM user_sessions
      WHERE end_time IS NOT NULL
    ''');
    return result.isNotEmpty ? (result.first['total'] as int?) ?? 0 : 0;
  }

  Future<int> getSessionCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM user_sessions');
    return result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;
  }

  // ============ CLEANUP ============
  
  Future<int> deleteOldEvents(String beforeDate) async {
    final db = await database;
    return await db.delete(
      'app_events',
      where: 'timestamp < ?',
      whereArgs: [beforeDate],
    );
  }

  Future<int> deleteOldSessions(String beforeDate) async {
    final db = await database;
    return await db.delete(
      'user_sessions',
      where: 'start_time < ?',
      whereArgs: [beforeDate],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
