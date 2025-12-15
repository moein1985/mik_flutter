import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/simple_queue.dart';
import '../../domain/repositories/queues_repository.dart';

/// Fake implementation of QueuesRepository for development without a real router
class FakeQueuesRepositoryImpl implements QueuesRepository {
  // In-memory storage
  final List<SimpleQueue> _queues = [];
  int _idCounter = 1;

  FakeQueuesRepositoryImpl() {
    _initializeFakeData();
  }

  void _initializeFakeData() {
    _queues.addAll([
      SimpleQueue(
        id: '*${_idCounter++}',
        name: 'Guest Network',
        target: '192.168.88.0/24',
        maxLimitDownload: '5M',
        maxLimitUpload: '1M',
        comment: 'Bandwidth limit for guest network',
        disabled: false,
        priority: 7,
      ),
      SimpleQueue(
        id: '*${_idCounter++}',
        name: 'VoIP Traffic',
        target: '192.168.10.0/24',
        maxLimitDownload: '2M',
        maxLimitUpload: '512k',
        comment: 'Priority queue for VoIP',
        disabled: false,
        priority: 1,
      ),
      SimpleQueue(
        id: '*${_idCounter++}',
        name: 'Manager PC',
        target: '192.168.88.100/32',
        maxLimitDownload: '20M',
        maxLimitUpload: '10M',
        comment: 'High priority for manager',
        disabled: false,
        priority: 3,
      ),
      SimpleQueue(
        id: '*${_idCounter++}',
        name: 'Downloads Server',
        target: '192.168.88.50/32',
        maxLimitDownload: '50M',
        maxLimitUpload: '5M',
        burstLimitDownload: '100M',
        burstThresholdDownload: '40M',
        burstTimeDownload: '10s',
        comment: 'Server with burst capability',
        disabled: true,
        priority: 8,
      ),
    ]);
  }

  Future<void> _simulateDelay() async {
    final delay = FakeDataGenerator.generateRandomDelay(
      AppConfig.fakeMinDelay,
      AppConfig.fakeMaxDelay,
    );
    await Future.delayed(delay);
  }

  bool _shouldSimulateError() {
    return FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);
  }

  @override
  Future<Either<Failure, List<SimpleQueue>>> getQueues() async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch queues'));
    }

    return Right(List.from(_queues));
  }

  @override
  Future<Either<Failure, SimpleQueue>> getQueueById(String queueId) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch queue'));
    }

    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index == -1) {
      return Left(ServerFailure('Queue not found'));
    }

    return Right(_queues[index]);
  }

  @override
  Future<Either<Failure, void>> addQueue(SimpleQueue queue) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to add queue'));
    }

    // Validate required fields
    if (queue.name.isEmpty) {
      return Left(ServerFailure('Queue name is required'));
    }
    if (queue.target.isEmpty) {
      return Left(ServerFailure('Target is required'));
    }

    // Check for duplicate name
    if (_queues.any((q) => q.name == queue.name)) {
      return Left(ServerFailure('Queue with this name already exists'));
    }

    // Add with new ID
    final newQueue = queue.copyWith(id: '*${_idCounter++}');
    _queues.add(newQueue);

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateQueue(SimpleQueue queue) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to update queue'));
    }

    final index = _queues.indexWhere((q) => q.id == queue.id);
    if (index == -1) {
      return Left(ServerFailure('Queue not found'));
    }

    // Check for duplicate name (excluding current queue)
    if (_queues.any((q) => q.name == queue.name && q.id != queue.id)) {
      return Left(ServerFailure('Queue with this name already exists'));
    }

    _queues[index] = queue;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteQueue(String queueId) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to delete queue'));
    }

    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index == -1) {
      return Left(ServerFailure('Queue not found'));
    }

    _queues.removeAt(index);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> enableQueue(String queueId) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to enable queue'));
    }

    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index == -1) {
      return Left(ServerFailure('Queue not found'));
    }

    _queues[index] = _queues[index].copyWith(disabled: false);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> disableQueue(String queueId) async {
    await _simulateDelay();

    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to disable queue'));
    }

    final index = _queues.indexWhere((q) => q.id == queueId);
    if (index == -1) {
      return Left(ServerFailure('Queue not found'));
    }

    _queues[index] = _queues[index].copyWith(disabled: true);
    return const Right(null);
  }
}
