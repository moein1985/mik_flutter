import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import 'base_routeros_client.dart';

class SystemRouterOSClient extends BaseRouterOSClient {
  SystemRouterOSClient(super.client);

  /// Get system resources
  Future<Either<Failure, Map<String, String>>> getSystemResources() async {
    final result = await executeCommand(['/system/resource/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data.isEmpty) {
          return Left(ServerFailure('No system resources data received'));
        }
        return Right(data.first);
      },
    );
  }

  /// Get system identity
  Future<Either<Failure, Map<String, String>>> getSystemIdentity() async {
    final result = await executeCommand(['/system/identity/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data.isEmpty) {
          return Left(ServerFailure('No system identity data received'));
        }
        return Right(data.first);
      },
    );
  }

  /// Get routerboard info
  Future<Either<Failure, Map<String, String>>> getRouterboardInfo() async {
    final result = await executeCommand(['/system/routerboard/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data.isEmpty) {
          return Left(ServerFailure('No routerboard data received'));
        }
        return Right(data.first);
      },
    );
  }

  /// Get system clock
  Future<Either<Failure, Map<String, String>>> getSystemClock() async {
    final result = await executeCommand(['/system/clock/print']);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        if (data.isEmpty) {
          return Left(ServerFailure('No system clock data received'));
        }
        return Right(data.first);
      },
    );
  }
}