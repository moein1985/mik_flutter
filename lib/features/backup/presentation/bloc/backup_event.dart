import 'package:equatable/equatable.dart';

abstract class BackupEvent extends Equatable {
  const BackupEvent();

  @override
  List<Object?> get props => [];
}

class LoadBackupsEvent extends BackupEvent {}

class CreateBackupEvent extends BackupEvent {
  final String name;

  const CreateBackupEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class DeleteBackupEvent extends BackupEvent {
  final String name;

  const DeleteBackupEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class RestoreBackupEvent extends BackupEvent {
  final String name;

  const RestoreBackupEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class DownloadBackupEvent extends BackupEvent {
  final String name;

  const DownloadBackupEvent(this.name);

  @override
  List<Object?> get props => [name];
}