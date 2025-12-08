import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/simple_queue.dart';
import '../../domain/repositories/queues_repository.dart';
import '../../../../core/network/routeros_client.dart';
import '../models/simple_queue_model.dart';

/// Implementation of QueuesRepository
class QueuesRepositoryImpl implements QueuesRepository {
  final RouterOSClient routerOsClient;

  QueuesRepositoryImpl({required this.routerOsClient});

  @override
  Future<Either<Failure, List<SimpleQueue>>> getQueues() async {
    try {
      final response = await routerOsClient.getSimpleQueues();
      final models = SimpleQueueModel.fromRouterOSList(response);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ServerException {
      return Left(const ServerFailure('Failed to load queues'));
    }
  }

  @override
  Future<Either<Failure, SimpleQueue>> getQueueById(String queueId) async {
    try {
      final response = await routerOsClient.getSimpleQueues();
      final models = SimpleQueueModel.fromRouterOSList(response);
      final model = models.firstWhere(
        (queue) => queue.id == queueId,
        orElse: () => throw ServerException('Queue not found'),
      );
      return Right(model.toEntity());
    } on ServerException {
      return Left(const ServerFailure('Failed to load queue'));
    }
  }

  @override
  Future<Either<Failure, void>> addQueue(SimpleQueue queue) async {
    try {
      final model = SimpleQueueModel.fromEntity(queue);
      final params = model.toRouterOSParams();
      await routerOsClient.addSimpleQueue(params);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to add queue'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQueue(SimpleQueue queue) async {
    try {
      final params = SimpleQueueModel.fromEntity(queue).toRouterOSParams();
      await routerOsClient.updateSimpleQueue(queue.id, params);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to update queue'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQueue(String queueId) async {
    try {
      await routerOsClient.deleteSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to delete queue'));
    }
  }

  @override
  Future<Either<Failure, void>> enableQueue(String queueId) async {
    try {
      await routerOsClient.enableSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to enable queue'));
    }
  }

  @override
  Future<Either<Failure, void>> disableQueue(String queueId) async {
    try {
      await routerOsClient.disableSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to disable queue'));
    }
  }
}