import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/backup_repository.dart';

class ExportConfigParams {
  final String fileName;
  final bool compact;
  final bool showSensitive;

  const ExportConfigParams({
    required this.fileName,
    this.compact = true,
    this.showSensitive = false,
  });
}

class ExportConfigUseCase {
  final BackupRepository repository;

  ExportConfigUseCase(this.repository);

  Future<Either<Failure, bool>> call(ExportConfigParams params) async {
    return await repository.exportConfig(
      fileName: params.fileName,
      compact: params.compact,
      showSensitive: params.showSensitive,
    );
  }
}
