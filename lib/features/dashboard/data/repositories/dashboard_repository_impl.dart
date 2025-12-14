import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/system_resource.dart';
import '../../domain/entities/router_interface.dart';
import '../../domain/entities/ip_address.dart';
import '../../domain/entities/firewall_rule.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, SystemResource>> getSystemResources() async {
    try {
      final result = await remoteDataSource.getSystemResources();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RouterInterface>>> getInterfaces() async {
    try {
      final result = await remoteDataSource.getInterfaces();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> enableInterface(String id) async {
    try {
      final result = await remoteDataSource.enableInterface(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> disableInterface(String id) async {
    try {
      final result = await remoteDataSource.disableInterface(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IpAddress>>> getIpAddresses() async {
    try {
      final result = await remoteDataSource.getIpAddresses();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addIpAddress(
        address: address,
        interfaceName: interfaceName,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateIpAddress({
    required String id,
    String? address,
    String? interfaceName,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.updateIpAddress(
        id: id,
        address: address,
        interfaceName: interfaceName,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeIpAddress(String id) async {
    try {
      final result = await remoteDataSource.removeIpAddress(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleIpAddress(String id, bool enable) async {
    try {
      final result = await remoteDataSource.toggleIpAddress(id, enable);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FirewallRule>>> getFirewallRules() async {
    try {
      final result = await remoteDataSource.getFirewallRules();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> enableFirewallRule(String id) async {
    try {
      final result = await remoteDataSource.enableFirewallRule(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> disableFirewallRule(String id) async {
    try {
      final result = await remoteDataSource.disableFirewallRule(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DhcpLease>>> getDhcpLeases() async {
    try {
      final result = await remoteDataSource.getDhcpLeases();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
