import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_helper;
import '../../../features/health_records/models/health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('healthmate.db');
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

    await db.execute('''
      CREATE TABLE health_records (
        id $idType,
        date $textType,
        steps $integerType,
        calories $integerType,
        water $integerType
      )
    ''');
  }

  // Create - Insert a new health record
  Future<int> insertRecord(HealthRecord record) async {
    final db = await database;
    return await db.insert('health_records', record.toMap());
  }

  // Read - Get all health records
  Future<List<HealthRecord>> getAllRecords() async {
    final db = await database;
    final result = await db.query(
      'health_records',
      orderBy: 'date DESC',
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // Read - Get records by date
  Future<List<HealthRecord>> getRecordsByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // Read - Get records within date range
  Future<List<HealthRecord>> getRecordsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  // Read - Get today's summary
  Future<Map<String, int>> getTodaySummary(String today) async {
    final records = await getRecordsByDate(today);
    
    int totalSteps = 0;
    int totalCalories = 0;
    int totalWater = 0;

    for (var record in records) {
      totalSteps += record.steps;
      totalCalories += record.calories;
      totalWater += record.water;
    }

    return {
      'steps': totalSteps,
      'calories': totalCalories,
      'water': totalWater,
    };
  }

  // Read - Get record by ID
  Future<HealthRecord?> getRecordById(int id) async {
    final db = await database;
    final result = await db.query(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return HealthRecord.fromMap(result.first);
    }
    return null;
  }

  // Update - Update an existing health record
  Future<int> updateRecord(HealthRecord record) async {
    final db = await database;
    return await db.update(
      'health_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Delete - Delete a health record
  Future<int> deleteRecord(int id) async {
    final db = await database;
    return await db.delete(
      'health_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all records (for testing)
  Future<int> deleteAllRecords() async {
    final db = await database;
    return await db.delete('health_records');
  }

  // Insert dummy/sample data for testing
  Future<void> insertDummyData() async {
    final db = await database;
    
    // Check if data already exists
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM health_records'),
    );
    
    if (count != null && count > 0) {
      return; // Data already exists, don't insert again
    }

    // Insert sample data for the past 7 days
    final today = DateTime.now();
    
    final dummyRecords = [
      HealthRecord(
        date: _formatDate(today),
        steps: 8500,
        calories: 320,
        water: 2000,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 1))),
        steps: 10000,
        calories: 450,
        water: 2500,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 2))),
        steps: 7200,
        calories: 280,
        water: 1800,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 3))),
        steps: 9500,
        calories: 380,
        water: 2200,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 4))),
        steps: 6800,
        calories: 250,
        water: 1600,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 5))),
        steps: 11200,
        calories: 520,
        water: 2800,
      ),
      HealthRecord(
        date: _formatDate(today.subtract(const Duration(days: 6))),
        steps: 8900,
        calories: 340,
        water: 2100,
      ),
    ];

    for (var record in dummyRecords) {
      await insertRecord(record);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Close the database
  Future close() async {
    final db = await database;
    db.close();
  }
}
