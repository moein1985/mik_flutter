import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/simple_queue.dart';

/// Abstract repository for queue operations
abstract class QueuesRepository {
  /// Get all simple queues
  Future<Either<Failure, List<SimpleQueue>>> getQueues();

  /// Get a specific queue by ID
  Future<Either<Failure, SimpleQueue>> getQueueById(String queueId);

  /// Add a new simple queue
  Future<Either<Failure, void>> addQueue(SimpleQueue queue);

  /// Update an existing simple queue
  Future<Either<Failure, void>> updateQueue(SimpleQueue queue);

  /// Delete a simple queue by ID
  Future<Either<Failure, void>> deleteQueue(String queueId);

  /// Enable a simple queue
  Future<Either<Failure, void>> enableQueue(String queueId);

  /// Disable a simple queue
  Future<Either<Failure, void>> disableQueue(String queueId);
}