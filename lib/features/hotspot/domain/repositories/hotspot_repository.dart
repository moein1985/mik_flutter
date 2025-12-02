import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/hotspot_server.dart';
import '../entities/hotspot_user.dart';
import '../entities/hotspot_active_user.dart';
import '../entities/hotspot_profile.dart';
import '../entities/hotspot_ip_binding.dart';
import '../entities/hotspot_host.dart';
import '../entities/walled_garden.dart';

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
  });
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
  });
  Future<Either<Failure, bool>> removeProfile(String id);

  // IP Binding Management
  Future<Either<Failure, List<HotspotIpBinding>>> getIpBindings();
  Future<Either<Failure, bool>> addIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type,
    String? comment,
  });
  Future<Either<Failure, bool>> editIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  });
  Future<Either<Failure, bool>> removeIpBinding(String id);
  Future<Either<Failure, bool>> enableIpBinding(String id);
  Future<Either<Failure, bool>> disableIpBinding(String id);

  // Hosts Management
  Future<Either<Failure, List<HotspotHost>>> getHosts();
  Future<Either<Failure, bool>> removeHost(String id);
  Future<Either<Failure, bool>> makeHostBinding({required String id, required String type});

  // Walled Garden Management
  Future<Either<Failure, List<WalledGarden>>> getWalledGarden();
  Future<Either<Failure, bool>> addWalledGarden({
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String action,
    String? method,
    String? comment,
  });
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
  });
  Future<Either<Failure, bool>> removeWalledGarden(String id);
  Future<Either<Failure, bool>> enableWalledGarden(String id);
  Future<Either<Failure, bool>> disableWalledGarden(String id);

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
