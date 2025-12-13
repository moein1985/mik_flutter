import 'package:equatable/equatable.dart';
import '../../domain/entities/backup_file.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

class BackupCreating extends BackupState {
  final String name;

  const BackupCreating(this.name);

  @override
  List<Object?> get props => [name];
}

class BackupRestoring extends BackupState {
  final String name;

  const BackupRestoring(this.name);

  @override
  List<Object?> get props => [name];
}

class BackupExporting extends BackupState {
  final String fileName;

  const BackupExporting(this.fileName);

  @override
  List<Object?> get props => [fileName];
}

class BackupLoaded extends BackupState {
  final List<BackupFile> backups;

  const BackupLoaded(this.backups);

  @override
  List<Object?> get props => [backups];
}

class BackupOperationSuccess extends BackupState {
  final String message;

  const BackupOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);

  @override
  List<Object?> get props => [message];
}