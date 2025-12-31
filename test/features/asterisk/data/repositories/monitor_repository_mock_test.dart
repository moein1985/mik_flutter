import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/asterisk/data/repositories/mock/monitor_repository_mock.dart';
import 'package:hsmik/features/asterisk/core/result.dart';

void main() {
  late MonitorRepositoryMock repository;

  setUp(() {
    repository = MonitorRepositoryMock();
  });

  group('MonitorRepositoryMock - Active Calls', () {
    test('should return list of active calls', () async {
      // Act
      final result = await repository.getActiveCalls();

      // Assert
      expect(result, isA<Success>());
    });

    test('should filter out system channels', () async {
      // Act
      final result = await repository.getActiveCalls();

      // Assert
      expect(result, isA<Success>());
      final calls = (result as Success).data;
      for (final call in calls) {
        expect(call.channel.contains('Local@'), false);
        expect(call.channel.contains('VoiceMail'), false);
        expect(call.channel.contains('Parked'), false);
      }
    });

    test('should only return calls in Up state', () async {
      // Act
      final result = await repository.getActiveCalls();

      // Assert
      expect(result, isA<Success>());
      final calls = (result as Success).data;
      for (final call in calls) {
        expect(call.state, 'Up');
      }
    });

    test('should simulate network delay for active calls', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.getActiveCalls();

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(300));
    });
  });

  group('MonitorRepositoryMock - Queue Statuses', () {
    test('should return list of queue statuses', () async {
      // Act
      final result = await repository.getQueueStatuses();

      // Assert
      expect(result, isA<Success>());
    });

    test('should contain queue names', () async {
      // Act
      final result = await repository.getQueueStatuses();

      // Assert
      expect(result, isA<Success>());
      final queues = (result as Success).data;
      for (final queue in queues) {
        expect(queue.name, isNotEmpty);
      }
    });

    test('should simulate network delay for queue status', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.getQueueStatuses();

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(300));
    });
  });

  group('MonitorRepositoryMock - Call Control', () {
    test('should complete hangup operation', () async {
      // Act
      final result = await repository.hangup('SIP/1001-00000001');
      
      // Assert
      expect(result, isA<Success>());
    });

    test('should complete transfer operation', () async {
      // Act
      final result = await repository.transfer(
        channel: 'SIP/1001-00000001',
        destination: '1003',
        context: 'from-internal',
      );
      
      // Assert
      expect(result, isA<Success>());
    });

    test('should complete pause agent operation', () async {
      // Act
      final result = await repository.pauseAgent(
        queue: 'support',
        interface: 'SIP/1001',
        paused: true,
        reason: 'Lunch break',
      );
      
      // Assert
      expect(result, isA<Success>());
    });

    test('should simulate delay for call control operations', () async {
      // Arrange
      final stopwatch = Stopwatch()..start();

      // Act
      await repository.hangup('SIP/1001-00000001');

      // Assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });
  });
}
