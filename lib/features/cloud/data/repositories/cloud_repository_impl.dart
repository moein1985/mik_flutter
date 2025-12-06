import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cloud_status.dart';
import '../../domain/repositories/cloud_repository.dart';
import '../datasources/cloud_remote_data_source.dart';

class CloudRepositoryImpl implements CloudRepository {
  final CloudRemoteDataSource remoteDataSource;

  CloudRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CloudStatus>> getCloudStatus() async {
    try {
      final result = await remoteDataSource.getCloudStatus();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableDdns() async {
    try {
      final result = await remoteDataSource.enableDdns();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableDdns() async {
    try {
      final result = await remoteDataSource.disableDdns();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> forceUpdate() async {
    try {
      final result = await remoteDataSource.forceUpdate();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> setUpdateInterval(String interval) async {
    try {
      final result = await remoteDataSource.setUpdateInterval(interval);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> setUpdateTime(bool enabled) async {
    try {
      final result = await remoteDataSource.setUpdateTime(enabled);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
