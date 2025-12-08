import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simple_queue.dart';
import '../repositories/queues_repository.dart';

class GetQueueByIdUseCase {
  final QueuesRepository repository;

  GetQueueByIdUseCase(this.repository);

  Future<Either<Failure, SimpleQueue>> call(String queueId) async {
    return await repository.getQueueById(queueId);
  }
}