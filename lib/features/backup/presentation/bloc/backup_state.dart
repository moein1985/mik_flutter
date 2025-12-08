import 'package:equatable/equatable.dart';
import '../../domain/entities/backup_file.dart';

abstract class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class BackupLoading extends BackupState {}

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