import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/queues_repository.dart';

/// Use case for toggling queue state (enable/disable)
class ToggleQueueUseCase {
  final QueuesRepository repository;

  ToggleQueueUseCase(this.repository);

  /// Execute toggle queue operation
  Future<Either<Failure, void>> call(String queueId, bool enable) async {
    if (enable) {
      return await repository.enableQueue(queueId);
    } else {
      return await repository.disableQueue(queueId);
    }
  }
}