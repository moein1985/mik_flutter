import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/hotspot_server_model.dart';
import '../models/hotspot_user_model.dart';
import '../models/hotspot_active_user_model.dart';
import '../models/hotspot_profile_model.dart';

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

  /// Add a new IP pool
  Future<bool> addIpPool({required String name, required String ranges});
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
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} hotspot servers');
      
      return data.map((item) => HotspotServerModel.fromMap(item)).toList();
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
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} hotspot users');
      
      return data.map((item) => HotspotUserModel.fromMap(item)).toList();
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
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} active hotspot users');
      
      return data.map((item) => HotspotActiveUserModel.fromMap(item)).toList();
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
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} hotspot profiles');
      
      return data.map((item) => HotspotProfileModel.fromMap(item)).toList();
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
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} interfaces');
      return data;
    } catch (e, stackTrace) {
      _log.e('Failed to get interfaces', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get interfaces: $e');
    }
  }

  @override
  Future<List<Map<String, String>>> getIpPools() async {
    try {
      _log.d('Getting IP pools...');
      final response = await client.getIpPools();
      final data = response.where((r) => r['type'] != 'done').toList();
      _log.i('Got ${data.length} IP pools');
      return data;
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
}
