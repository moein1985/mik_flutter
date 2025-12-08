import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_backups_usecase.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/usecases/delete_backup_usecase.dart';
import '../../domain/usecases/restore_backup_usecase.dart';
import '../../domain/usecases/download_backup_usecase.dart';
import 'backup_event.dart';
import 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final GetBackupsUseCase getBackupsUseCase;
  final CreateBackupUseCase createBackupUseCase;
  final DeleteBackupUseCase deleteBackupUseCase;
  final RestoreBackupUseCase restoreBackupUseCase;
  final DownloadBackupUseCase downloadBackupUseCase;

  BackupBloc({
    required this.getBackupsUseCase,
    required this.createBackupUseCase,
    required this.deleteBackupUseCase,
    required this.restoreBackupUseCase,
    required this.downloadBackupUseCase,
  }) : super(BackupInitial()) {
    on<LoadBackupsEvent>(_onLoadBackups);
    on<CreateBackupEvent>(_onCreateBackup);
    on<DeleteBackupEvent>(_onDeleteBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<DownloadBackupEvent>(_onDownloadBackup);
  }

  Future<void> _onLoadBackups(
    LoadBackupsEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await getBackupsUseCase();
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (backups) => emit(BackupLoaded(backups)),
    );
  }

  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await createBackupUseCase(event.name);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (_) {
        emit(const BackupOperationSuccess('Backup created successfully'));
        add(LoadBackupsEvent()); // Reload the list
      },
    );
  }

  Future<void> _onDeleteBackup(
    DeleteBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await deleteBackupUseCase(event.name);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (_) {
        emit(const BackupOperationSuccess('Backup deleted successfully'));
        add(LoadBackupsEvent()); // Reload the list
      },
    );
  }

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await restoreBackupUseCase(event.name);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (_) => emit(const BackupOperationSuccess('Backup restored successfully')),
    );
  }

  Future<void> _onDownloadBackup(
    DownloadBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupLoading());
    final result = await downloadBackupUseCase(event.name);
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (_) => emit(const BackupOperationSuccess('Backup downloaded successfully')),
    );
  }
}