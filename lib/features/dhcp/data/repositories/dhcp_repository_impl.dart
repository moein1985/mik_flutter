import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dhcp_server.dart';
import '../../domain/entities/dhcp_network.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../../domain/repositories/dhcp_repository.dart';
import '../datasources/dhcp_remote_data_source.dart';

class DhcpRepositoryImpl implements DhcpRepository {
  final DhcpRemoteDataSource remoteDataSource;

  DhcpRepositoryImpl({required this.remoteDataSource});

  // ==================== DHCP Servers ====================

  @override
  Future<Either<Failure, List<DhcpServer>>> getServers() async {
    try {
      final result = await remoteDataSource.getServers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    try {
      final result = await remoteDataSource.addServer(
        name: name,
        interface: interface,
        addressPool: addressPool,
        leaseTime: leaseTime,
        authoritative: authoritative,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    try {
      final result = await remoteDataSource.editServer(
        id: id,
        name: name,
        interface: interface,
        addressPool: addressPool,
        leaseTime: leaseTime,
        authoritative: authoritative,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeServer(String id) async {
    try {
      final result = await remoteDataSource.removeServer(id);
      return Right(result);
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

  // ==================== DHCP Networks ====================

  @override
  Future<Either<Failure, List<DhcpNetwork>>> getNetworks() async {
    try {
      final result = await remoteDataSource.getNetworks();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addNetwork(
        address: address,
        gateway: gateway,
        netmask: netmask,
        dnsServer: dnsServer,
        domain: domain,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.editNetwork(
        id: id,
        address: address,
        gateway: gateway,
        netmask: netmask,
        dnsServer: dnsServer,
        domain: domain,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeNetwork(String id) async {
    try {
      final result = await remoteDataSource.removeNetwork(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== DHCP Leases ====================

  @override
  Future<Either<Failure, List<DhcpLease>>> getLeases() async {
    try {
      final result = await remoteDataSource.getLeases();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addLease(
        address: address,
        macAddress: macAddress,
        server: server,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeLease(String id) async {
    try {
      final result = await remoteDataSource.removeLease(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> makeStatic(String id) async {
    try {
      final result = await remoteDataSource.makeStatic(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableLease(String id) async {
    try {
      final result = await remoteDataSource.enableLease(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableLease(String id) async {
    try {
      final result = await remoteDataSource.disableLease(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== Helpers ====================

  @override
  Future<Either<Failure, List<Map<String, String>>>> getIpPools() async {
    try {
      final result = await remoteDataSource.getIpPools();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getInterfaces() async {
    try {
      final result = await remoteDataSource.getInterfaces();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
