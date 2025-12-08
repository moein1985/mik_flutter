import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simple_queue.dart';
import '../repositories/queues_repository.dart';

/// Use case for adding a new simple queue
class AddQueueUseCase {
  final QueuesRepository repository;

  AddQueueUseCase(this.repository);

  /// Execute add queue operation
  Future<Either<Failure, void>> call(Map<String, dynamic> queueData) async {
    // Convert map to SimpleQueue entity
    final queue = SimpleQueue(
      id: '', // Will be set by RouterOS
      name: queueData['name'] ?? '',
      target: queueData['target'] ?? '',
      maxLimit: queueData['max-limit'] ?? '',
      burstLimit: queueData['burst-limit'] ?? '',
      burstThreshold: queueData['burst-threshold'] ?? '',
      burstTime: queueData['burst-time'] ?? '',
      priority: int.tryParse(queueData['priority']?.toString() ?? '8') ?? 8,
      comment: queueData['comment'] ?? '',
    );
    return await repository.addQueue(queue).then((result) => result.map((_) => null));
  }
}