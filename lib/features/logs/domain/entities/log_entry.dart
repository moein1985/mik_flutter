import 'package:equatable/equatable.dart';

class LogEntry extends Equatable {
  final String? id;
  final String? time;
  final String? topics;
  final String? message;
  final LogLevel? level;

  const LogEntry({
    this.id,
    this.time,
    this.topics,
    this.message,
    this.level,
  });

  @override
  List<Object?> get props => [id, time, topics, message, level];
}

enum LogLevel {
  info,
  warning,
  error,
  critical,
  debug,
  unknown,
}

extension LogLevelExtension on LogLevel {
  String get displayName {
    switch (this) {
      case LogLevel.info:
        return 'Info';
      case LogLevel.warning:
        return 'Warning';
      case LogLevel.error:
        return 'Error';
      case LogLevel.critical:
        return 'Critical';
      case LogLevel.debug:
        return 'Debug';
      case LogLevel.unknown:
        return 'Unknown';
    }
  }

  static LogLevel fromString(String? level) {
    if (level == null) return LogLevel.unknown;

    final lowerLevel = level.toLowerCase();
    switch (lowerLevel) {
      case 'info':
        return LogLevel.info;
      case 'warning':
      case 'warn':
        return LogLevel.warning;
      case 'error':
      case 'err':
        return LogLevel.error;
      case 'critical':
      case 'crit':
        return LogLevel.critical;
      case 'debug':
        return LogLevel.debug;
      default:
        return LogLevel.unknown;
    }
  }
}