import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/cloud_status.dart';
import '../../domain/repositories/cloud_repository.dart';

/// Fake implementation of CloudRepository for development without a real router
class FakeCloudRepositoryImpl implements CloudRepository {
  // In-memory cloud status
  CloudStatus _cloudStatus = const CloudStatus(
    ddnsEnabled: true,
    ddnsUpdateInterval: '00:10:00',
    updateTime: true,
    publicAddress: '203.0.113.45',
    dnsName: 'abc123def456.sn.mynetname.net',
    status: 'updated',
    isSupported: true,
  );

  Future<void> _simulateDelay() => Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  @override
  Future<Either<Failure, CloudStatus>> getCloudStatus() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load cloud status'));
    }
    return Right(_cloudStatus);
  }

  @override
  Future<Either<Failure, bool>> enableDdns() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable DDNS'));
    }

    _cloudStatus = _cloudStatus.copyWith(
      ddnsEnabled: true,
      status: 'updating',
    );

    // Simulate status update after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _cloudStatus = _cloudStatus.copyWith(status: 'updated');
    });

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableDdns() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable DDNS'));
    }

    _cloudStatus = _cloudStatus.copyWith(
      ddnsEnabled: false,
      status: 'disabled',
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> forceUpdate() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to force update'));
    }

    if (!_cloudStatus.ddnsEnabled) {
      return const Left(ServerFailure('DDNS is not enabled'));
    }

    _cloudStatus = _cloudStatus.copyWith(status: 'updating');

    // Simulate status update after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _cloudStatus = _cloudStatus.copyWith(
        status: 'updated',
        publicAddress: '203.0.113.${46 + DateTime.now().second % 10}',
      );
    });

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> setUpdateInterval(String interval) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to set update interval'));
    }

    // Validate interval format (should be HH:MM:SS)
    final parts = interval.split(':');
    if (parts.length != 3) {
      return const Left(ServerFailure('Invalid interval format (use HH:MM:SS)'));
    }

    _cloudStatus = _cloudStatus.copyWith(ddnsUpdateInterval: interval);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> setUpdateTime(bool enabled) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to set update time'));
    }

    _cloudStatus = _cloudStatus.copyWith(updateTime: enabled);
    return const Right(true);
  }
}
