import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/backup/domain/usecases/get_backups_usecase.dart';
import 'package:hsmik/features/backup/domain/usecases/create_backup_usecase.dart';
import 'package:hsmik/features/backup/domain/usecases/delete_backup_usecase.dart';
import 'package:hsmik/features/backup/domain/usecases/restore_backup_usecase.dart';
import 'package:hsmik/features/backup/domain/usecases/export_config_usecase.dart';

class MockGetBackupsUseCase extends Mock implements GetBackupsUseCase {}

class MockCreateBackupUseCase extends Mock implements CreateBackupUseCase {}

class MockDeleteBackupUseCase extends Mock implements DeleteBackupUseCase {}

class MockRestoreBackupUseCase extends Mock implements RestoreBackupUseCase {}

class MockExportConfigUseCase extends Mock implements ExportConfigUseCase {}
