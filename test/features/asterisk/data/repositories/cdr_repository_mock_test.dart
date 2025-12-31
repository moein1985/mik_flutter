import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/asterisk/data/repositories/mock/cdr_repository_mock.dart';
import 'package:hsmik/features/asterisk/core/result.dart';

void main() {
  late CdrRepositoryMock repository;

  setUp(() {
    repository = CdrRepositoryMock();
  });

  group('CdrRepositoryMock', () {
    test('should return list of CDR records', () async {
      // Act
      final result = await repository.getCdrRecords();

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      expect(records, isNotEmpty);
    });

    test('should return CDR records with required fields', () async {
      // Act
      final result = await repository.getCdrRecords();

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.callDate, isNotNull);
        expect(record.src, isNotEmpty);
        expect(record.dst, isNotEmpty);
        expect(record.duration, isNotNull);
        expect(record.billsec, isNotNull);
        expect(record.disposition, isNotEmpty);
      }
    });

    test('should filter by source extension', () async {
      // Act
      final result = await repository.getCdrRecords(src: '1001');

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.src, '1001');
      }
    });

    test('should filter by destination extension', () async {
      // Act
      final result = await repository.getCdrRecords(dst: '1002');

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.dst, '1002');
      }
    });

    test('should filter by disposition', () async {
      // Act
      final result = await repository.getCdrRecords(disposition: 'ANSWERED');

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.disposition, 'ANSWERED');
      }
    });

    test('should filter by date range', () async {
      // Arrange
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(hours: 5));
      final endDate = now;

      // Act
      final result = await repository.getCdrRecords(
        startDate: startDate,
        endDate: endDate,
      );

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.callDate.isAfter(startDate), true);
        expect(record.callDate.isBefore(endDate), true);
      }
    });

    test('should respect limit parameter', () async {
      // Act
      final result = await repository.getCdrRecords(limit: 2);

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      expect(records.length, lessThanOrEqualTo(2));
    });

    test('should support multiple filters simultaneously', () async {
      // Act
      final result = await repository.getCdrRecords(
        src: '1001',
        disposition: 'ANSWERED',
        limit: 10,
      );

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      for (final record in records) {
        expect(record.src, '1001');
        expect(record.disposition, 'ANSWERED');
      }
      expect(records.length, lessThanOrEqualTo(10));
    });

    test('should simulate network delay', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.getCdrRecords();

      // Assert
      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(300),
        reason: 'Should have at least 300ms network delay',
      );
    });

    test('should return empty list when no records match filters', () async {
      // Act
      final result = await repository.getCdrRecords(src: 'nonexistent');

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      expect(records, isEmpty);
    });

    test('should include both internal and external calls', () async {
      // Act
      final result = await repository.getCdrRecords();

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      final hasInternal = records.any((r) => r.context == 'from-internal');
      final hasExternal = records.any((r) => r.context == 'from-external');

      expect(hasInternal, true, reason: 'Should have internal calls');
      expect(hasExternal, true, reason: 'Should have external calls');
    });

    test('should include various dispositions', () async {
      // Act
      final result = await repository.getCdrRecords();

      // Assert
      expect(result, isA<Success>());
      final records = (result as Success).data;
      final dispositions = records.map((r) => r.disposition).toSet();
      
      expect(
        dispositions.length,
        greaterThan(1),
        reason: 'Should have multiple disposition types',
      );
    });
  });
}
