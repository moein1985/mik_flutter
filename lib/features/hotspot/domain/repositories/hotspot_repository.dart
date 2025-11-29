import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_server.dart';
import '../entities/hotspot_user.dart';
import '../entities/hotspot_active_user.dart';
import '../entities/hotspot_profile.dart';

abstract class HotspotRepository {
  // Server Management
  Future<Either<Failure, List<HotspotServer>>> getServers();
  Future<Either<Failure, bool>> enableServer(String id);
  Future<Either<Failure, bool>> disableServer(String id);

  // User Management
  Future<Either<Failure, List<HotspotUser>>> getUsers();
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
  });
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
  });
  Future<Either<Failure, bool>> removeUser(String id);
  Future<Either<Failure, bool>> enableUser(String id);
  Future<Either<Failure, bool>> disableUser(String id);
  Future<Either<Failure, bool>> resetUserCounters(String id);

  // Active Users
  Future<Either<Failure, List<HotspotActiveUser>>> getActiveUsers();
  Future<Either<Failure, bool>> disconnectUser(String id);

  // Profile Management
  Future<Either<Failure, List<HotspotProfile>>> getProfiles();

  // Setup
  Future<Either<Failure, bool>> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  });

  // Package & Setup Helpers
  Future<Either<Failure, bool>> isHotspotPackageEnabled();
  Future<Either<Failure, List<Map<String, String>>>> getInterfaces();
  Future<Either<Failure, List<Map<String, String>>>> getIpPools();
  Future<Either<Failure, bool>> addIpPool({required String name, required String ranges});
}
