import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/core/utils/logger.dart';

void main() {
  group('AppLogger', () {
    test('should create logger with tag', () {
      final logger = AppLogger.tag('Test');
      expect(logger, isNotNull);
    });
  });
}