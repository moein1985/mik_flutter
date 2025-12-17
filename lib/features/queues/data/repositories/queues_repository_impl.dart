import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/simple_queue.dart';
import '../../domain/repositories/queues_repository.dart';
import '../../../../core/network/routeros_client.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/simple_queue_model.dart';

/// Implementation of QueuesRepository
class QueuesRepositoryImpl implements QueuesRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  QueuesRepositoryImpl({required this.authRemoteDataSource});

  RouterOSClient get _client {
    if (authRemoteDataSource.legacyClient == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.legacyClient!;
  }

  @override
  Future<Either<Failure, List<SimpleQueue>>> getQueues() async {
    try {
      final response = await _client.getSimpleQueues();
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
      final response = await _client.getSimpleQueues();
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
      await _client.addSimpleQueue(
        name: model.name,
        target: model.target,
        maxLimit: model.maxLimit.isNotEmpty ? model.maxLimit : null,
        limitAt: model.limitAt.isNotEmpty ? model.limitAt : null,
        priority: model.priority,
        comment: model.comment.isNotEmpty ? model.comment : null,
        disabled: model.disabled,
      );
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to add queue'));
    }
  }

  @override
  Future<Either<Failure, void>> updateQueue(SimpleQueue queue) async {
    try {
      final model = SimpleQueueModel.fromEntity(queue);
      await _client.updateSimpleQueue(
        id: model.id,
        name: model.name.isNotEmpty ? model.name : null,
        target: model.target.isNotEmpty ? model.target : null,
        maxLimit: model.maxLimit.isNotEmpty ? model.maxLimit : null,
        limitAt: model.limitAt.isNotEmpty ? model.limitAt : null,
        priority: model.priority,
        comment: model.comment.isNotEmpty ? model.comment : null,
        disabled: model.disabled,
      );
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to update queue'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQueue(String queueId) async {
    try {
      await _client.deleteSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to delete queue'));
    }
  }

  @override
  Future<Either<Failure, void>> enableQueue(String queueId) async {
    try {
      await _client.enableSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to enable queue'));
    }
  }

  @override
  Future<Either<Failure, void>> disableQueue(String queueId) async {
    try {
      await _client.disableSimpleQueue(queueId);
      return const Right(null);
    } on ServerException {
      return Left(const ServerFailure('Failed to disable queue'));
    }
  }
}