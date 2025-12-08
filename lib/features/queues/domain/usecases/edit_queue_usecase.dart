import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simple_queue.dart';
import '../repositories/queues_repository.dart';

/// Use case for editing an existing simple queue
class EditQueueUseCase {
  final QueuesRepository repository;

  EditQueueUseCase(this.repository);

  /// Execute edit queue operation
  Future<Either<Failure, void>> call(String queueId, Map<String, dynamic> queueData) async {
    // Convert map to SimpleQueue entity
    final queue = SimpleQueue(
      id: queueId,
      name: queueData['name'] ?? '',
      target: queueData['target'] ?? '',
      maxLimit: queueData['max-limit'] ?? '',
      burstLimit: queueData['burst-limit'] ?? '',
      burstThreshold: queueData['burst-threshold'] ?? '',
      burstTime: queueData['burst-time'] ?? '',
      priority: int.tryParse(queueData['priority']?.toString() ?? '8') ?? 8,
      comment: queueData['comment'] ?? '',
    );
    return await repository.updateQueue(queue).then((result) => result.map((_) => null));
  }
}