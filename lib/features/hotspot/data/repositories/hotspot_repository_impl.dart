import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/hotspot_server.dart';
import '../../domain/entities/hotspot_user.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/hotspot_ip_binding.dart';
import '../../domain/entities/hotspot_host.dart';
import '../../domain/entities/walled_garden.dart';
import '../../domain/repositories/hotspot_repository.dart';
import '../datasources/hotspot_remote_data_source.dart';

class HotspotRepositoryImpl implements HotspotRepository {
  final HotspotRemoteDataSource remoteDataSource;

  HotspotRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<HotspotServer>>> getServers() async {
    try {
      final servers = await remoteDataSource.getServers();
      return Right(servers.map((model) => model).toList());
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
      return Right(users.map((model) => model).toList());
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
    // Limits
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final result = await remoteDataSource.addUser(
        name: name,
        password: password,
        profile: profile,
        server: server,
        comment: comment,
        limitUptime: limitUptime,
        limitBytesIn: limitBytesIn,
        limitBytesOut: limitBytesOut,
        limitBytesTotal: limitBytesTotal,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editUser({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? server,
    String? comment,
    // Limits
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final result = await remoteDataSource.editUser(
        id: id,
        name: name,
        password: password,
        profile: profile,
        server: server,
        comment: comment,
        limitUptime: limitUptime,
        limitBytesIn: limitBytesIn,
        limitBytesOut: limitBytesOut,
        limitBytesTotal: limitBytesTotal,
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
  Future<Either<Failure, bool>> resetUserCounters(String id) async {
    try {
      final result = await remoteDataSource.resetUserCounters(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<HotspotActiveUser>>> getActiveUsers() async {
    try {
      final users = await remoteDataSource.getActiveUsers();
      return Right(users.map((model) => model).toList());
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
      return Right(profiles.map((model) => model).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  }) async {
    try {
      final result = await remoteDataSource.setupHotspot(
        interface: interface,
        addressPool: addressPool,
        dnsName: dnsName,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isHotspotPackageEnabled() async {
    try {
      final result = await remoteDataSource.isHotspotPackageEnabled();
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
  Future<Either<Failure, bool>> addIpPool({required String name, required String ranges}) async {
    try {
      final result = await remoteDataSource.addIpPool(name: name, ranges: ranges);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== Profile CRUD ====================

  @override
  Future<Either<Failure, bool>> addProfile({
    required String name,
    String? sessionTimeout,
    String? idleTimeout,
    String? sharedUsers,
    String? rateLimit,
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final result = await remoteDataSource.addProfile(
        name: name,
        sessionTimeout: sessionTimeout,
        idleTimeout: idleTimeout,
        sharedUsers: sharedUsers,
        rateLimit: rateLimit,
        keepaliveTimeout: keepaliveTimeout,
        statusAutorefresh: statusAutorefresh,
        onLogin: onLogin,
        onLogout: onLogout,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editProfile({
    required String id,
    String? name,
    String? sessionTimeout,
    String? idleTimeout,
    String? sharedUsers,
    String? rateLimit,
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final result = await remoteDataSource.editProfile(
        id: id,
        name: name,
        sessionTimeout: sessionTimeout,
        idleTimeout: idleTimeout,
        sharedUsers: sharedUsers,
        rateLimit: rateLimit,
        keepaliveTimeout: keepaliveTimeout,
        statusAutorefresh: statusAutorefresh,
        onLogin: onLogin,
        onLogout: onLogout,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeProfile(String id) async {
    try {
      final result = await remoteDataSource.removeProfile(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== IP Binding ====================

  @override
  Future<Either<Failure, List<HotspotIpBinding>>> getIpBindings() async {
    try {
      final bindings = await remoteDataSource.getIpBindings();
      return Right(bindings.map((model) => model).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type = 'regular',
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addIpBinding(
        mac: mac,
        address: address,
        toAddress: toAddress,
        server: server,
        type: type,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.editIpBinding(
        id: id,
        mac: mac,
        address: address,
        toAddress: toAddress,
        server: server,
        type: type,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeIpBinding(String id) async {
    try {
      final result = await remoteDataSource.removeIpBinding(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableIpBinding(String id) async {
    try {
      final result = await remoteDataSource.enableIpBinding(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableIpBinding(String id) async {
    try {
      final result = await remoteDataSource.disableIpBinding(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== Hosts ====================

  @override
  Future<Either<Failure, List<HotspotHost>>> getHosts() async {
    try {
      final hosts = await remoteDataSource.getHosts();
      return Right(hosts.map((model) => model).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeHost(String id) async {
    try {
      final result = await remoteDataSource.removeHost(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> makeHostBinding({required String id, required String type}) async {
    try {
      final result = await remoteDataSource.makeHostBinding(id: id, type: type);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  // ==================== Walled Garden ====================

  @override
  Future<Either<Failure, List<WalledGarden>>> getWalledGarden() async {
    try {
      final entries = await remoteDataSource.getWalledGarden();
      return Right(entries.map((model) => model).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> addWalledGarden({
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String action = 'allow',
    String? method,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.addWalledGarden(
        server: server,
        srcAddress: srcAddress,
        dstAddress: dstAddress,
        dstHost: dstHost,
        dstPort: dstPort,
        path: path,
        action: action,
        method: method,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> editWalledGarden({
    required String id,
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String? action,
    String? method,
    String? comment,
  }) async {
    try {
      final result = await remoteDataSource.editWalledGarden(
        id: id,
        server: server,
        srcAddress: srcAddress,
        dstAddress: dstAddress,
        dstHost: dstHost,
        dstPort: dstPort,
        path: path,
        action: action,
        method: method,
        comment: comment,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> removeWalledGarden(String id) async {
    try {
      final result = await remoteDataSource.removeWalledGarden(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> enableWalledGarden(String id) async {
    try {
      final result = await remoteDataSource.enableWalledGarden(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> disableWalledGarden(String id) async {
    try {
      final result = await remoteDataSource.disableWalledGarden(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
