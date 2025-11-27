import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/hotspot_server.dart';
import '../../domain/entities/hotspot_user.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/repositories/hotspot_repository.dart';
import '../datasources/hotspot_remote_data_source.dart';

class HotspotRepositoryImpl implements HotspotRepository {
  final HotspotRemoteDataSource remoteDataSource;

  HotspotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HotspotServer>>> getServers() async {
    try {
      final servers = await remoteDataSource.getServers();
      return Right(servers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableServer(String id) async {
    try {
      final result = await remoteDataSource.enableServer(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableServer(String id) async {
    try {
      final result = await remoteDataSource.disableServer(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HotspotUser>>> getUsers() async {
    try {
      final users = await remoteDataSource.getUsers();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addUser({
    required String name,
    required String password,
    String? profile,
    String? server,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addUser(
        name: name,
        password: password,
        profile: profile,
        server: server,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeUser(String id) async {
    try {
      final result = await remoteDataSource.removeUser(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableUser(String id) async {
    try {
      final result = await remoteDataSource.enableUser(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableUser(String id) async {
    try {
      final result = await remoteDataSource.disableUser(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HotspotActiveUser>>> getActiveUsers() async {
    try {
      final users = await remoteDataSource.getActiveUsers();
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectUser(String id) async {
    try {
      final result = await remoteDataSource.disconnectUser(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HotspotProfile>>> getProfiles() async {
    try {
      final profiles = await remoteDataSource.getProfiles();
      return Right(profiles);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
