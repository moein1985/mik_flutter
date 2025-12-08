import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simple_queue.dart';
import '../repositories/queues_repository.dart';

/// Use case for getting all simple queues
class GetQueuesUseCase {
  final QueuesRepository repository;

  GetQueuesUseCase(this.repository);

  /// Execute get queues operation
  Future<Either<Failure, List<SimpleQueue>>> call() async {
    return await repository.getQueues();
  }
}