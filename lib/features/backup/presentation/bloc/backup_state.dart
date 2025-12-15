import 'package:equatable/equatable.dart';
import '../../domain/entities/backup_file.dart';

sealed class BackupState extends Equatable {
  const BackupState();

  @override
  List<Object?> get props => [];
}

final class BackupInitial extends BackupState {
  const BackupInitial();
}

final class BackupLoading extends BackupState {
  const BackupLoading();
}

final class BackupCreating extends BackupState {
  final String name;

  const BackupCreating(this.name);

  @override
  List<Object?> get props => [name];
}

final class BackupRestoring extends BackupState {
  final String name;

  const BackupRestoring(this.name);

  @override
  List<Object?> get props => [name];
}

final class BackupExporting extends BackupState {
  final String fileName;

  const BackupExporting(this.fileName);

  @override
  List<Object?> get props => [fileName];
}

final class BackupLoaded extends BackupState {
  final List<BackupFile> backups;

  const BackupLoaded(this.backups);

  @override
  List<Object?> get props => [backups];
}

final class BackupOperationSuccess extends BackupState {
  final String message;

  const BackupOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

final class BackupError extends BackupState {
  final String message;

  const BackupError(this.message);

  @override
  List<Object?> get props => [message];
}