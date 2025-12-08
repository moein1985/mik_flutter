import '../../domain/entities/backup_file.dart';

class BackupFileModel extends BackupFile {
  const BackupFileModel({
    required super.name,
    required super.size,
    required super.created,
    required super.type,
  });

  factory BackupFileModel.fromMap(Map<String, dynamic> map) {
    return BackupFileModel(
      name: map['name'] ?? '',
      size: map['size'] ?? '0',
      created: DateTime.tryParse(map['creation-time'] ?? '') ?? DateTime.now(),
      type: map['type'] ?? 'backup',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'size': size,
      'creation-time': created.toIso8601String(),
      'type': type,
    };
  }
}