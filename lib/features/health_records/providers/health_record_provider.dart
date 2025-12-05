import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../../../core/database/database_helper.dart';
import '../../analytics/services/analytics_service.dart';

class HealthRecordProvider extends ChangeNotifier {
  List<HealthRecord> _records = [];
  List<HealthRecord> _filteredRecords = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _todaySummary = {
    'steps': 0,
    'calories': 0,
    'water': 0,
  };

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Getters
  List<HealthRecord> get records => _filteredRecords.isEmpty && _searchDate == null
      ? _records
      : _filteredRecords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get todaySummary => _todaySummary;
  
  String? _searchDate;
  String? get searchDate => _searchDate;

  // Initialize and load data
  Future<void> initialize() async {
    await loadRecords();
    await loadTodaySummary();
  }

  // Load all records from database
  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _dbHelper.getAllRecords();
      _filteredRecords = [];
      _searchDate = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load records: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load today's summary
  Future<void> loadTodaySummary() async {
    try {
      final today = _formatDate(DateTime.now());
      _todaySummary = await _dbHelper.getTodaySummary(today);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load summary: $e';
      notifyListeners();
    }
  }

  // Add a new record
  Future<bool> addRecord(HealthRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate the record
      final validationError = record.validate();
      if (validationError != null) {
        _errorMessage = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.insertRecord(record);
      await loadRecords();
      await loadTodaySummary();
      
      // Track analytics
      AnalyticsService.instance.trackRecordAdded(metadata: {
        'steps': record.steps,
        'calories': record.calories,
        'water': record.water,
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing record
  Future<bool> updateRecord(HealthRecord record) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate the record
      final validationError = record.validate();
      if (validationError != null) {
        _errorMessage = validationError;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _dbHelper.updateRecord(record);
      await loadRecords();
      await loadTodaySummary();
      
      // Track analytics
      AnalyticsService.instance.trackRecordUpdated(metadata: {
        'record_id': record.id,
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a record
  Future<bool> deleteRecord(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _dbHelper.deleteRecord(id);
      await loadRecords();
      await loadTodaySummary();
      
      // Track analytics
      AnalyticsService.instance.trackRecordDeleted(metadata: {
        'record_id': id,
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete record: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Search/filter records by date
  Future<void> searchByDate(String? date) async {
    _searchDate = date;
    
    if (date == null || date.isEmpty) {
      _filteredRecords = [];
      notifyListeners();
      return;
    }

    try {
      _filteredRecords = await _dbHelper.getRecordsByDate(date);
      
      // Track search analytics
      AnalyticsService.instance.trackSearch(date, metadata: {
        'results_count': _filteredRecords.length,
      });
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to search records: $e';
      notifyListeners();
    }
  }

  // Clear search filter
  void clearSearch() {
    _searchDate = null;
    _filteredRecords = [];
    notifyListeners();
  }

  // Get records for the past N days
  Future<List<HealthRecord>> getRecentRecords(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    return await _dbHelper.getRecordsByDateRange(
      _formatDate(startDate),
      _formatDate(endDate),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Insert dummy data (for testing)
  Future<void> insertDummyData() async {
    try {
      await _dbHelper.insertDummyData();
      await loadRecords();
      await loadTodaySummary();
    } catch (e) {
      _errorMessage = 'Failed to insert dummy data: $e';
      notifyListeners();
    }
  }
}
