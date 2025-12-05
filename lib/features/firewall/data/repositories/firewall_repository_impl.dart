import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/firewall_rule.dart';
import '../../domain/repositories/firewall_repository.dart';
import '../datasources/firewall_remote_data_source.dart';

class FirewallRepositoryImpl implements FirewallRepository {
  final FirewallRemoteDataSource remoteDataSource;

  FirewallRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<FirewallRule>>> getRules(FirewallRuleType type) async {
    try {
      final rules = await remoteDataSource.getRules(type);
      return Right(rules);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> enableRule(FirewallRuleType type, String id) async {
    try {
      final result = await remoteDataSource.enableRule(type, id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> disableRule(FirewallRuleType type, String id) async {
    try {
      final result = await remoteDataSource.disableRule(type, id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAddressListNames() async {
    try {
      final names = await remoteDataSource.getAddressListNames();
      return Right(names);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FirewallRule>>> getAddressListByName(String listName) async {
    try {
      final rules = await remoteDataSource.getAddressListByName(listName);
      return Right(rules);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
