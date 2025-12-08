import '../../domain/entities/log_entry.dart';

class LogEntryModel extends LogEntry {
  const LogEntryModel({
    super.id,
    super.time,
    super.topics,
    super.message,
    super.level,
  });

  factory LogEntryModel.fromJson(Map<String, dynamic> json) {
    return LogEntryModel(
      id: json['.id'] as String?,
      time: json['time'] as String?,
      topics: json['topics'] as String?,
      message: json['message'] as String?,
      level: LogLevelExtension.fromString(json['level'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '.id': id,
      if (time != null) 'time': time,
      if (topics != null) 'topics': topics,
      if (message != null) 'message': message,
      if (level != null) 'level': level!.name,
    };
  }

  factory LogEntryModel.fromEntity(LogEntry entity) {
    return LogEntryModel(
      id: entity.id,
      time: entity.time,
      topics: entity.topics,
      message: entity.message,
      level: entity.level,
    );
  }

  LogEntry toEntity() {
    return LogEntry(
      id: id,
      time: time,
      topics: topics,
      message: message,
      level: level,
    );
  }
}