import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/asterisk/data/repositories/mock/extension_repository_mock.dart';
import 'package:hsmik/features/asterisk/core/result.dart';

void main() {
  late ExtensionRepositoryMock repository;

  setUp(() {
    repository = ExtensionRepositoryMock();
  });

  group('ExtensionRepositoryMock', () {
    test('should return list of extensions', () async {
      // Act
      final result = await repository.getExtensions();

      // Assert
      expect(result, isA<Success>());
      final success = result as Success;
      expect(success.data, isNotEmpty);
    });

    test('should return extensions with required fields', () async {
      // Act
      final result = await repository.getExtensions();

      // Assert
      expect(result, isA<Success>());
      final extensions = (result as Success).data;
      for (final extension in extensions) {
        expect(extension.name, isNotEmpty);
        expect(extension.location, isNotNull);
        expect(extension.status, isNotEmpty);
      }
    });

    test('should simulate network delay', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.getExtensions();

      // Assert
      stopwatch.stop();
      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(300),
        reason: 'Should have at least 300ms network delay',
      );
    });

    test('should return different statuses on multiple calls', () async {
      // Act
      final result1 = await repository.getExtensions();
      final result2 = await repository.getExtensions();
      final result3 = await repository.getExtensions();

      // Assert
      expect(result1, isA<Success>());
      expect(result2, isA<Success>());
      expect(result3, isA<Success>());

      final extensions1 = (result1 as Success).data;
      final extensions2 = (result2 as Success).data;
      final extensions3 = (result3 as Success).data;

      final statuses1 = extensions1.map((e) => e.status).toList();
      final statuses2 = extensions2.map((e) => e.status).toList();
      final statuses3 = extensions3.map((e) => e.status).toList();

      // At least one call should have different statuses (due to random changes)
      expect(
        statuses1.toString() != statuses2.toString() ||
            statuses2.toString() != statuses3.toString(),
        true,
        reason: 'Mock should simulate dynamic status changes',
      );
    });

    test('should handle concurrent requests', () async {
      // Act
      final futures = List.generate(5, (_) => repository.getExtensions());
      final results = await Future.wait(futures);

      // Assert
      expect(results.length, 5);
      for (final result in results) {
        expect(result, isA<Success>());
        final extensions = (result as Success).data;
        expect(extensions, isNotEmpty);
      }
    });
  });
}
