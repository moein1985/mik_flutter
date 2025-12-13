import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class LoadBackupsEvent extends BackupEvent {}

class CreateBackupEvent extends BackupEvent {
  final String name;
  final String? password;
  final bool dontEncrypt;

  const CreateBackupEvent({
    required this.name,
    this.password,
    this.dontEncrypt = true,
  });

  @override
  List<Object?> get props => [name, password, dontEncrypt];
}

class DeleteBackupEvent extends BackupEvent {
  final String name;

  const DeleteBackupEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class RestoreBackupEvent extends BackupEvent {
  final String name;
  final String? password;

  const RestoreBackupEvent({
    required this.name,
    this.password,
  });

  @override
  List<Object?> get props => [name, password];
}

class ExportConfigEvent extends BackupEvent {
  final String fileName;
  final bool compact;
  final bool showSensitive;

  const ExportConfigEvent({
    required this.fileName,
    this.compact = true,
    this.showSensitive = false,
  });

  @override
  List<Object?> get props => [fileName, compact, showSensitive];
}