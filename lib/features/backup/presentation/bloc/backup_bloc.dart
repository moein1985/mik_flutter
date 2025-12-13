import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_backups_usecase.dart';
import '../../domain/usecases/create_backup_usecase.dart';
import '../../domain/usecases/delete_backup_usecase.dart';
import '../../domain/usecases/restore_backup_usecase.dart';
import '../../domain/usecases/export_config_usecase.dart';
import 'backup_event.dart';
import 'backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final GetBackupsUseCase getBackupsUseCase;
  final CreateBackupUseCase createBackupUseCase;
  final DeleteBackupUseCase deleteBackupUseCase;
  final RestoreBackupUseCase restoreBackupUseCase;
  final ExportConfigUseCase exportConfigUseCase;

  BackupBloc({
    required this.getBackupsUseCase,
    required this.createBackupUseCase,
    required this.deleteBackupUseCase,
    required this.restoreBackupUseCase,
    required this.exportConfigUseCase,
  }) : super(BackupInitial()) {
    on<LoadBackupsEvent>(_onLoadBackups);
    on<CreateBackupEvent>(_onCreateBackup);
    on<DeleteBackupEvent>(_onDeleteBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<ExportConfigEvent>(_onExportConfig);
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
    emit(BackupCreating(event.name));
    final result = await createBackupUseCase(CreateBackupParams(
      name: event.name,
      password: event.password,
      dontEncrypt: event.dontEncrypt,
    ));
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (success) {
        if (success) {
          emit(const BackupOperationSuccess('Backup created successfully'));
          add(LoadBackupsEvent()); // Reload the list
        } else {
          emit(const BackupError('Failed to create backup'));
        }
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
      (success) {
        if (success) {
          emit(const BackupOperationSuccess('Backup deleted successfully'));
          add(LoadBackupsEvent()); // Reload the list
        } else {
          emit(const BackupError('Failed to delete backup'));
        }
      },
    );
  }

  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupRestoring(event.name));
    final result = await restoreBackupUseCase(RestoreBackupParams(
      name: event.name,
      password: event.password,
    ));
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (success) {
        if (success) {
          emit(const BackupOperationSuccess('Backup restore initiated. Router will reboot.'));
        } else {
          emit(const BackupError('Failed to restore backup'));
        }
      },
    );
  }

  Future<void> _onExportConfig(
    ExportConfigEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(BackupExporting(event.fileName));
    final result = await exportConfigUseCase(ExportConfigParams(
      fileName: event.fileName,
      compact: event.compact,
      showSensitive: event.showSensitive,
    ));
    result.fold(
      (failure) => emit(BackupError(failure.message)),
      (success) {
        if (success) {
          emit(const BackupOperationSuccess('Config exported successfully'));
          add(LoadBackupsEvent()); // Reload to show new .rsc file
        } else {
          emit(const BackupError('Failed to export config'));
        }
      },
    );
  }
}