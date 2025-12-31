import 'dart:math';
import '../../../domain/entities/active_call.dart';
import '../../../domain/entities/queue_status.dart';
import '../../../domain/entities/queue_member.dart';
import '../../../domain/repositories/imonitor_repository.dart';
import '../../../core/result.dart';
import 'mock_data.dart';

/// Mock implementation of Monitor Repository for testing
/// 
/// This is a simplified version that returns mock data without
/// requiring full domain/data layer implementation.
class MonitorRepositoryMock implements IMonitorRepository {
  @override
  Future<Result<List<ActiveCall>>> getActiveCalls() async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

      final activeCalls = <ActiveCall>[];

      for (final channelString in MockData.mockActiveChannels) {
        // Filter system channels
        if (_isSystemChannel(channelString)) continue;

        // Parse channel string to map
        final lines = channelString.split(RegExp(r'\r\n|\n'));

        // Only real calls (Up state and has ConnectedLineNum)
        if (_isRealCall(channelString)) {
          activeCalls.add(ActiveCall(
            channel: _valueForPrefix(lines, 'Channel: '),
            caller: _valueForPrefix(lines, 'CallerIDNum: '),
            callee: _valueForPrefix(lines, 'ConnectedLineNum: '),
            duration: _valueForPrefix(lines, 'Duration: '),
          ));
        }
      }

      return Success(activeCalls);
    } catch (e) {
      return Failure('Failed to fetch active calls: $e');
    }
  }

  @override
  Future<Result<List<QueueStatus>>> getQueueStatuses() async {
    try {
      // Simulate network delay
      await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(200)));

      // Group events by Queue
      final queueEvents = <String, List<String>>{};

      for (final event in MockData.mockQueueStatus) {
        final lines = event.split(RegExp(r'\r\n|\n'));
        final queue = _valueForPrefix(lines, 'Queue: ');
        if (queue.isNotEmpty) {
          queueEvents.putIfAbsent(queue, () => []).add(event);
        }
      }

      final queueStatuses = <QueueStatus>[];
      for (final entry in queueEvents.entries) {
        int calls = 0;
        int holdTime = 0;
        int talkTime = 0;
        int completed = 0;
        final members = <QueueMember>[];

        for (final event in entry.value) {
          final lines = event.split(RegExp(r'\r\n|\n')).where((l) => l.isNotEmpty).toList();
          final type = _valueForPrefix(lines, 'Event: ');
          if (type == 'QueueParams') {
            calls = int.tryParse(_valueForPrefix(lines, 'Calls: ')) ?? 0;
            holdTime = int.tryParse(_valueForPrefix(lines, 'Holdtime: ')) ?? 0;
            talkTime = int.tryParse(_valueForPrefix(lines, 'TalkTime: ')) ?? 0;
            completed = int.tryParse(_valueForPrefix(lines, 'Completed: ')) ?? 0;
          } else if (type == 'QueueMember') {
            final name = _valueForPrefix(lines, 'Name: ');
            final location = _valueForPrefix(lines, 'Location: ');
            final paused = _valueForPrefix(lines, 'Paused: ') == '1';
            final statusCode = int.tryParse(_valueForPrefix(lines, 'Status: ')) ?? 0;
            final callsTaken = int.tryParse(_valueForPrefix(lines, 'CallsTaken: ')) ?? 0;
            final lastCall = int.tryParse(_valueForPrefix(lines, 'LastCall: ')) ?? 0;
            members.add(QueueMember(
              name: name.isNotEmpty ? name : location,
              interface: location,
              state: _mapStatus(statusCode, paused),
              paused: paused,
              callsTaken: callsTaken,
              lastCall: lastCall,
            ));
          }
        }

        queueStatuses.add(QueueStatus(
          queue: entry.key,
          calls: calls,
          holdTime: holdTime,
          talkTime: talkTime,
          completed: completed,
          members: members,
        ));
      }

      return Success(queueStatuses);
    } catch (e) {
      return Failure('Failed to fetch queue statuses: $e');
    }
  }

  @override
  Future<Result<void>> hangup(String channel) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const Success(null);
  }

  @override
  Future<Result<void>> originate({
    required String from,
    required String to,
    required String context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const Success(null);
  }

  @override
  Future<Result<void>> transfer({
    required String channel,
    required String destination,
    required String context,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const Success(null);
  }

  @override
  Future<Result<void>> pauseAgent({
    required String queue,
    required String interface,
    required bool paused,
    String? reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const Success(null);
  }

  bool _isSystemChannel(String channelString) {
    final lines = channelString.split(RegExp(r'\r\n|\n'));
    final channel = _valueForPrefix(lines, 'Channel: ');
    return channel.contains('Local@') ||
           channel.contains('VoiceMail') ||
           channel.contains('Parked') ||
           channel.contains('ConfBridge') ||
           channel.contains('MeetMe') ||
           channel.contains('Agent/') ||
           channel.isEmpty;
  }

  bool _isRealCall(String channelString) {
    final lines = channelString.split(RegExp(r'\r\n|\n'));
    final state = _valueForPrefix(lines, 'ChannelStateDesc: ');
    final connectedLine = _valueForPrefix(lines, 'ConnectedLineNum: ');
    return state == 'Up' && connectedLine.isNotEmpty;
  }

  String _valueForPrefix(List<String> lines, String prefix) {
    for (final line in lines) {
      if (line.startsWith(prefix)) {
        return line.substring(prefix.length).trim();
      }
    }
    return '';
  }

  static String _mapStatus(int code, bool paused) {
    if (paused) return 'Paused';
    switch (code) {
      case 1:
        return 'Ready';
      case 2:
        return 'In Use';
      case 3:
        return 'Busy';
      case 4:
        return 'Unavailable';
      case 5:
        return 'Ringing';
      case 6:
        return 'On Hold';
      default:
        return 'Unknown';
    }
  }
}
