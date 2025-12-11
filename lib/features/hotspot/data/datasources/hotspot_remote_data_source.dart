import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/hotspot_server_model.dart';
import '../models/hotspot_user_model.dart';
import '../models/hotspot_active_user_model.dart';
import '../models/hotspot_profile_model.dart';
import '../models/hotspot_ip_binding_model.dart';
import '../models/hotspot_host_model.dart';
import '../models/walled_garden_model.dart';

final _log = AppLogger.tag('HotspotDataSource');

abstract class HotspotRemoteDataSource {
  Future<List<HotspotServerModel>> getServers();
  Future<bool> enableServer(String id);
  Future<bool> disableServer(String id);
  
  Future<List<HotspotUserModel>> getUsers();
  Future<bool> addUser({
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
  Future<bool> editUser({
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
  Future<bool> removeUser(String id);
  Future<bool> enableUser(String id);
  Future<bool> disableUser(String id);
  Future<bool> resetUserCounters(String id);
  
  Future<List<HotspotActiveUserModel>> getActiveUsers();
  Future<bool> disconnectUser(String id);
  
  Future<List<HotspotProfileModel>> getProfiles();

  Future<bool> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  });

  /// Check if hotspot package is enabled on the router
  Future<bool> isHotspotPackageEnabled();

  /// Get list of interfaces for hotspot setup
  Future<List<Map<String, String>>> getInterfaces();

  /// Get list of IP pools for hotspot setup
  Future<List<Map<String, String>>> getIpPools();

  /// Get list of IP addresses for validation
  Future<List<Map<String, String>>> getIpAddresses();

  /// Add a new IP pool
  Future<bool> addIpPool({required String name, required String ranges});

  // ==================== IP Bindings ====================
  Future<List<HotspotIpBindingModel>> getIpBindings();
  Future<bool> addIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type,
    String? comment,
  });
  Future<bool> editIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  });
  Future<bool> removeIpBinding(String id);
  Future<bool> enableIpBinding(String id);
  Future<bool> disableIpBinding(String id);

  // ==================== Hosts ====================
  Future<List<HotspotHostModel>> getHosts();
  Future<bool> removeHost(String id);
  Future<bool> makeHostBinding({required String id, required String type});

  // ==================== Walled Garden ====================
  Future<List<WalledGardenModel>> getWalledGarden();
  Future<bool> addWalledGarden({
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
  Future<bool> editWalledGarden({
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
  Future<bool> removeWalledGarden(String id);
  Future<bool> enableWalledGarden(String id);
  Future<bool> disableWalledGarden(String id);

  // ==================== User Profiles (CRUD) ====================
  Future<bool> addProfile({
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
  Future<bool> editProfile({
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
  Future<bool> removeProfile(String id);

  // ==================== Reset HotSpot ====================
  Future<bool> resetHotspot({
    bool deleteUsers = true,
    bool deleteProfiles = true,
    bool deleteIpBindings = true,
    bool deleteWalledGarden = true,
    bool deleteServers = true,
    bool deleteServerProfiles = true,
    bool deleteIpPools = false,
  });
}

class HotspotRemoteDataSourceImpl implements HotspotRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  HotspotRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<List<HotspotServerModel>> getServers() async {
    try {
      _log.d('Getting hotspot servers...');
      final response = await client.getHotspotServers();
      _log.d('Raw response: $response');
      _log.i('Got ${response.length} hotspot servers');
      
      return response.map((item) => HotspotServerModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get hotspot servers', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get hotspot servers: $e');
    }
  }

  @override
  Future<bool> enableServer(String id) async {
    try {
      return await client.enableHotspotServer(id);
    } catch (e) {
      throw ServerException('Failed to enable hotspot server: $e');
    }
  }

  @override
  Future<bool> disableServer(String id) async {
    try {
      return await client.disableHotspotServer(id);
    } catch (e) {
      throw ServerException('Failed to disable hotspot server: $e');
    }
  }

  @override
  Future<List<HotspotUserModel>> getUsers() async {
    try {
      _log.d('Getting hotspot users...');
      final response = await client.getHotspotUsers();
      _log.d('Raw response: $response');
      _log.i('Got ${response.length} hotspot users');
      
      return response.map((item) => HotspotUserModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get hotspot users', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get hotspot users: $e');
    }
  }

  @override
  Future<bool> addUser({
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
      return await client.addHotspotUser(
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
    } catch (e) {
      throw ServerException('Failed to add hotspot user: $e');
    }
  }

  @override
  Future<bool> editUser({
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
      return await client.editHotspotUser(
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
    } catch (e) {
      throw ServerException('Failed to edit hotspot user: $e');
    }
  }

  @override
  Future<bool> removeUser(String id) async {
    try {
      return await client.removeHotspotUser(id);
    } catch (e) {
      throw ServerException('Failed to remove hotspot user: $e');
    }
  }

  @override
  Future<bool> enableUser(String id) async {
    try {
      return await client.enableHotspotUser(id);
    } catch (e) {
      throw ServerException('Failed to enable hotspot user: $e');
    }
  }

  @override
  Future<bool> disableUser(String id) async {
    try {
      return await client.disableHotspotUser(id);
    } catch (e) {
      throw ServerException('Failed to disable hotspot user: $e');
    }
  }

  @override
  Future<bool> resetUserCounters(String id) async {
    try {
      _log.i('Resetting counters for user: $id');
      return await client.resetHotspotUserCounters(id);
    } catch (e) {
      throw ServerException('Failed to reset user counters: $e');
    }
  }

  @override
  Future<List<HotspotActiveUserModel>> getActiveUsers() async {
    try {
      _log.d('Getting active hotspot users...');
      final response = await client.getHotspotActiveUsers();
      _log.d('Raw response: $response');
      _log.i('Got ${response.length} active hotspot users');
      
      return response.map((item) => HotspotActiveUserModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get active hotspot users', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get active hotspot users: $e');
    }
  }

  @override
  Future<bool> disconnectUser(String id) async {
    try {
      return await client.disconnectHotspotUser(id);
    } catch (e) {
      throw ServerException('Failed to disconnect hotspot user: $e');
    }
  }

  @override
  Future<List<HotspotProfileModel>> getProfiles() async {
    try {
      _log.d('Getting hotspot profiles...');
      final response = await client.getHotspotProfiles();
      _log.d('Raw response: $response');
      _log.i('Got ${response.length} hotspot profiles');
      
      return response.map((item) => HotspotProfileModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get hotspot profiles', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get hotspot profiles: $e');
    }
  }

  @override
  Future<bool> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  }) async {
    try {
      _log.i('Setting up hotspot on interface: $interface');
      final result = await client.setupHotspot(
        interface: interface,
        addressPool: addressPool,
        dnsName: dnsName,
      );
      _log.i('Hotspot setup result: $result');
      if (!result) {
        throw ServerException('HotSpot setup failed. Please check logs for details.');
      }
      return result;
    } catch (e, stackTrace) {
      _log.e('Failed to setup hotspot', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to setup hotspot: $e');
    }
  }

  @override
  Future<bool> isHotspotPackageEnabled() async {
    try {
      _log.d('Checking if hotspot package is enabled...');
      final result = await client.isHotspotPackageEnabled();
      _log.i('Hotspot package enabled: $result');
      return result;
    } catch (e, stackTrace) {
      _log.e('Failed to check hotspot package', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to check hotspot package: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getInterfaces() async {
    try {
      _log.d('Getting interfaces for hotspot setup...');
      final response = await client.getInterfaces();
      _log.i('Got ${response.length} interfaces');
      return response;
    } catch (e, stackTrace) {
      _log.e('Failed to get interfaces', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get interfaces: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getIpAddresses() async {
    try {
      _log.d('Getting IP addresses for validation...');
      final response = await client.getIpAddresses();
      _log.i('Got ${response.length} IP addresses');
      return response;
    } catch (e, stackTrace) {
      _log.e('Failed to get IP addresses', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get IP addresses: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getIpPools() async {
    try {
      _log.d('Getting IP pools...');
      final response = await client.getIpPools();
      _log.i('Got ${response.length} IP pools');
      return response;
    } catch (e, stackTrace) {
      _log.e('Failed to get IP pools', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get IP pools: $e');
    }
  }

  @override
  Future<bool> addIpPool({required String name, required String ranges}) async {
    try {
      _log.i('Adding IP pool: $name with ranges: $ranges');
      final result = await client.addIpPool(name: name, ranges: ranges);
      _log.i('Add IP pool result: $result');
      return result;
    } catch (e, stackTrace) {
      _log.e('Failed to add IP pool', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to add IP pool: $e');
    }
  }

  // ==================== IP Bindings ====================

  @override
  Future<List<HotspotIpBindingModel>> getIpBindings() async {
    try {
      _log.d('Getting IP bindings...');
      final response = await client.getHotspotIpBindings();
      _log.i('Got ${response.length} IP bindings');
      return response.map((item) => HotspotIpBindingModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get IP bindings', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get IP bindings: $e');
    }
  }

  @override
  Future<bool> addIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type = 'regular',
    String? comment,
  }) async {
    try {
      _log.i('Adding IP binding: $mac -> $address');
      return await client.addHotspotIpBinding(
        mac: mac,
        address: address,
        toAddress: toAddress,
        server: server,
        type: type,
        comment: comment,
      );
    } catch (e) {
      throw ServerException('Failed to add IP binding: $e');
    }
  }

  @override
  Future<bool> editIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  }) async {
    try {
      return await client.editHotspotIpBinding(
        id: id,
        mac: mac,
        address: address,
        toAddress: toAddress,
        server: server,
        type: type,
        comment: comment,
      );
    } catch (e) {
      throw ServerException('Failed to edit IP binding: $e');
    }
  }

  @override
  Future<bool> removeIpBinding(String id) async {
    try {
      return await client.removeHotspotIpBinding(id);
    } catch (e) {
      throw ServerException('Failed to remove IP binding: $e');
    }
  }

  @override
  Future<bool> enableIpBinding(String id) async {
    try {
      return await client.enableHotspotIpBinding(id);
    } catch (e) {
      throw ServerException('Failed to enable IP binding: $e');
    }
  }

  @override
  Future<bool> disableIpBinding(String id) async {
    try {
      return await client.disableHotspotIpBinding(id);
    } catch (e) {
      throw ServerException('Failed to disable IP binding: $e');
    }
  }

  // ==================== Hosts ====================

  @override
  Future<List<HotspotHostModel>> getHosts() async {
    try {
      _log.d('Getting hotspot hosts...');
      final response = await client.getHotspotHosts();
      _log.i('Got ${response.length} hotspot hosts');
      return response.map((item) => HotspotHostModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get hotspot hosts', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get hotspot hosts: $e');
    }
  }

  @override
  Future<bool> removeHost(String id) async {
    try {
      return await client.removeHotspotHost(id);
    } catch (e) {
      throw ServerException('Failed to remove host: $e');
    }
  }

  @override
  Future<bool> makeHostBinding({required String id, required String type}) async {
    try {
      _log.i('Making host binding: $id -> $type');
      return await client.makeHotspotHostBinding(id: id, type: type);
    } catch (e) {
      throw ServerException('Failed to make host binding: $e');
    }
  }

  // ==================== Walled Garden ====================

  @override
  Future<List<WalledGardenModel>> getWalledGarden() async {
    try {
      _log.d('Getting walled garden entries...');
      final response = await client.getWalledGarden();
      _log.i('Got ${response.length} walled garden entries');
      return response.map((item) => WalledGardenModel.fromMap(item)).toList();
    } catch (e, stackTrace) {
      _log.e('Failed to get walled garden', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get walled garden: $e');
    }
  }

  @override
  Future<bool> addWalledGarden({
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
      _log.i('Adding walled garden entry: $dstHost');
      return await client.addWalledGarden(
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
    } catch (e) {
      throw ServerException('Failed to add walled garden: $e');
    }
  }

  @override
  Future<bool> editWalledGarden({
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
      return await client.editWalledGarden(
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
    } catch (e) {
      throw ServerException('Failed to edit walled garden: $e');
    }
  }

  @override
  Future<bool> removeWalledGarden(String id) async {
    try {
      return await client.removeWalledGarden(id);
    } catch (e) {
      throw ServerException('Failed to remove walled garden: $e');
    }
  }

  @override
  Future<bool> enableWalledGarden(String id) async {
    try {
      return await client.enableWalledGarden(id);
    } catch (e) {
      throw ServerException('Failed to enable walled garden: $e');
    }
  }

  @override
  Future<bool> disableWalledGarden(String id) async {
    try {
      return await client.disableWalledGarden(id);
    } catch (e) {
      throw ServerException('Failed to disable walled garden: $e');
    }
  }

  // ==================== User Profiles (CRUD) ====================

  @override
  Future<bool> addProfile({
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
      _log.i('Adding hotspot profile: $name');
      return await client.addHotspotProfile(
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
    } catch (e) {
      throw ServerException('Failed to add profile: $e');
    }
  }

  @override
  Future<bool> editProfile({
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
      return await client.editHotspotProfile(
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
    } catch (e) {
      throw ServerException('Failed to edit profile: $e');
    }
  }

  @override
  Future<bool> removeProfile(String id) async {
    try {
      return await client.removeHotspotProfile(id);
    } catch (e) {
      throw ServerException('Failed to remove profile: $e');
    }
  }

  // ==================== Reset HotSpot ====================

  @override
  Future<bool> resetHotspot({
    bool deleteUsers = true,
    bool deleteProfiles = true,
    bool deleteIpBindings = true,
    bool deleteWalledGarden = true,
    bool deleteServers = true,
    bool deleteServerProfiles = true,
    bool deleteIpPools = false,
  }) async {
    try {
      _log.i('Starting HotSpot reset...');
      return await client.resetHotspot(
        deleteUsers: deleteUsers,
        deleteProfiles: deleteProfiles,
        deleteIpBindings: deleteIpBindings,
        deleteWalledGarden: deleteWalledGarden,
        deleteServers: deleteServers,
        deleteServerProfiles: deleteServerProfiles,
        deleteIpPools: deleteIpPools,
      );
    } catch (e, stackTrace) {
      _log.e('Failed to reset hotspot', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to reset hotspot: $e');
    }
  }
}
