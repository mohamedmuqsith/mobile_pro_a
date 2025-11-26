import 'package:flutter_test/flutter_test.dart';
import 'package:healthmatrecent/features/health_records/models/health_record.dart';

void main() {
  group('HealthRecord Model Tests', () {
    test('Create HealthRecord with valid data', () {
      final record = HealthRecord(
        id: 1,
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      expect(record.id, 1);
      expect(record.date, '2025-11-24');
      expect(record.steps, 10000);
      expect(record.calories, 450);
      expect(record.water, 2000);
    });

    test('toMap converts HealthRecord to Map correctly', () {
      final record = HealthRecord(
        id: 1,
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      final map = record.toMap();

      expect(map['id'], 1);
      expect(map['date'], '2025-11-24');
      expect(map['steps'], 10000);
      expect(map['calories'], 450);
      expect(map['water'], 2000);
    });

    test('fromMap creates HealthRecord from Map correctly', () {
      final map = {
        'id': 1,
        'date': '2025-11-24',
        'steps': 10000,
        'calories': 450,
        'water': 2000,
      };

      final record = HealthRecord.fromMap(map);

      expect(record.id, 1);
      expect(record.date, '2025-11-24');
      expect(record.steps, 10000);
      expect(record.calories, 450);
      expect(record.water, 2000);
    });

    test('validate returns null for valid record', () {
      final record = HealthRecord(
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      expect(record.validate(), null);
    });

    test('validate returns error for negative steps', () {
      final record = HealthRecord(
        date: '2025-11-24',
        steps: -100,
        calories: 450,
        water: 2000,
      );

      expect(record.validate(), isNotNull);
    });

    test('validate returns error for empty date', () {
      final record = HealthRecord(
        date: '',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      expect(record.validate(), 'Date is required');
    });

    test('formattedWater displays water in liters correctly', () {
      final record = HealthRecord(
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2500,
      );

      expect(record.formattedWater, '2.5 L');
    });

    test('copyWith creates a copy with updated values', () {
      final record = HealthRecord(
        id: 1,
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      final updated = record.copyWith(steps: 12000, calories: 500);

      expect(updated.id, 1);
      expect(updated.date, '2025-11-24');
      expect(updated.steps, 12000);
      expect(updated.calories, 500);
      expect(updated.water, 2000);
    });

    test('isValid returns true for valid record', () {
      final record = HealthRecord(
        date: '2025-11-24',
        steps: 10000,
        calories: 450,
        water: 2000,
      );

      expect(record.isValid, true);
    });

    test('isValid returns false for invalid record', () {
      final record = HealthRecord(
        date: '2025-11-24',
        steps: -100,
        calories: 450,
        water: 2000,
      );

      expect(record.isValid, false);
    });
  });
}
