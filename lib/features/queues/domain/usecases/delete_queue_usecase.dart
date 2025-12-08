import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/queues_repository.dart';

/// Use case for deleting a simple queue
class DeleteQueueUseCase {
  final QueuesRepository repository;

  DeleteQueueUseCase(this.repository);

  /// Execute delete queue operation
  Future<Either<Failure, void>> call(String queueId) async {
    return await repository.deleteQueue(queueId);
  }
}