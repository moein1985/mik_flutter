import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/routeros_client.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/dhcp_server_model.dart';
import '../models/dhcp_network_model.dart';
import '../models/dhcp_lease_model.dart';

final _log = AppLogger.tag('DhcpDataSource');

abstract class DhcpRemoteDataSource {
  // Servers
  Future<List<DhcpServerModel>> getServers();
  Future<bool> addServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  });
  Future<bool> editServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  });
  Future<bool> removeServer(String id);
  Future<bool> enableServer(String id);
  Future<bool> disableServer(String id);

  // Networks
  Future<List<DhcpNetworkModel>> getNetworks();
  Future<bool> addNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  });
  Future<bool> editNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  });
  Future<bool> removeNetwork(String id);

  // Leases
  Future<List<DhcpLeaseModel>> getLeases();
  Future<bool> addLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  });
  Future<bool> removeLease(String id);
  Future<bool> makeStatic(String id);
  Future<bool> enableLease(String id);
  Future<bool> disableLease(String id);

  // Helpers
  Future<List<Map<String, String>>> getIpPools();
  Future<List<Map<String, String>>> getInterfaces();
}

class DhcpRemoteDataSourceImpl implements DhcpRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  DhcpRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  // ==================== DHCP Servers ====================

  @override
  Future<List<DhcpServerModel>> getServers() async {
    try {
      _log.d('Getting DHCP servers...');
      final response = await client.sendCommand(['/ip/dhcp-server/print']);
      final servers = response
          .where((r) => r['type'] == 're')
          .map((r) => DhcpServerModel.fromMap(r))
          .toList();
      _log.i('Got ${servers.length} DHCP servers');
      return servers;
    } catch (e, stackTrace) {
      _log.e('Failed to get DHCP servers', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get DHCP servers: $e');
    }
  }

  @override
  Future<bool> addServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    try {
      _log.i('Adding DHCP server: $name on $interface');
      final commands = [
        '/ip/dhcp-server/add',
        '=name=$name',
        '=interface=$interface',
      ];

      if (addressPool != null) commands.add('=address-pool=$addressPool');
      if (leaseTime != null) commands.add('=lease-time=$leaseTime');
      if (authoritative != null) commands.add('=authoritative=${authoritative ? 'yes' : 'no'}');

      final response = await client.sendCommand(commands);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP server added successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to add DHCP server', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to add DHCP server: $e');
    }
  }

  @override
  Future<bool> editServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    try {
      _log.i('Editing DHCP server: $id');
      final commands = ['/ip/dhcp-server/set', '=.id=$id'];

      if (name != null) commands.add('=name=$name');
      if (interface != null) commands.add('=interface=$interface');
      if (addressPool != null) commands.add('=address-pool=$addressPool');
      if (leaseTime != null) commands.add('=lease-time=$leaseTime');
      if (authoritative != null) commands.add('=authoritative=${authoritative ? 'yes' : 'no'}');

      final response = await client.sendCommand(commands);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP server edited successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to edit DHCP server', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to edit DHCP server: $e');
    }
  }

  @override
  Future<bool> removeServer(String id) async {
    try {
      _log.i('Removing DHCP server: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/remove', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP server removed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to remove DHCP server', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to remove DHCP server: $e');
    }
  }

  @override
  Future<bool> enableServer(String id) async {
    try {
      _log.i('Enabling DHCP server: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/enable', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to enable DHCP server', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to enable DHCP server: $e');
    }
  }

  @override
  Future<bool> disableServer(String id) async {
    try {
      _log.i('Disabling DHCP server: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/disable', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to disable DHCP server', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to disable DHCP server: $e');
    }
  }

  // ==================== DHCP Networks ====================

  @override
  Future<List<DhcpNetworkModel>> getNetworks() async {
    try {
      _log.d('Getting DHCP networks...');
      final response = await client.sendCommand(['/ip/dhcp-server/network/print']);
      final networks = response
          .where((r) => r['type'] == 're')
          .map((r) => DhcpNetworkModel.fromMap(r))
          .toList();
      _log.i('Got ${networks.length} DHCP networks');
      return networks;
    } catch (e, stackTrace) {
      _log.e('Failed to get DHCP networks', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get DHCP networks: $e');
    }
  }

  @override
  Future<bool> addNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      _log.i('Adding DHCP network: $address');
      final commands = ['/ip/dhcp-server/network/add', '=address=$address'];

      if (gateway != null) commands.add('=gateway=$gateway');
      if (netmask != null) commands.add('=netmask=$netmask');
      if (dnsServer != null) commands.add('=dns-server=$dnsServer');
      if (domain != null) commands.add('=domain=$domain');
      if (comment != null) commands.add('=comment=$comment');

      final response = await client.sendCommand(commands);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP network added successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to add DHCP network', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to add DHCP network: $e');
    }
  }

  @override
  Future<bool> editNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    try {
      _log.i('Editing DHCP network: $id');
      final commands = ['/ip/dhcp-server/network/set', '=.id=$id'];

      if (address != null) commands.add('=address=$address');
      if (gateway != null) commands.add('=gateway=$gateway');
      if (netmask != null) commands.add('=netmask=$netmask');
      if (dnsServer != null) commands.add('=dns-server=$dnsServer');
      if (domain != null) commands.add('=domain=$domain');
      if (comment != null) commands.add('=comment=$comment');

      final response = await client.sendCommand(commands);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP network edited successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to edit DHCP network', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to edit DHCP network: $e');
    }
  }

  @override
  Future<bool> removeNetwork(String id) async {
    try {
      _log.i('Removing DHCP network: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/network/remove', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP network removed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to remove DHCP network', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to remove DHCP network: $e');
    }
  }

  // ==================== DHCP Leases ====================

  @override
  Future<List<DhcpLeaseModel>> getLeases() async {
    try {
      _log.d('Getting DHCP leases...');
      final response = await client.sendCommand(['/ip/dhcp-server/lease/print']);
      final leases = response
          .where((r) => r['type'] == 're')
          .map((r) => DhcpLeaseModel.fromMap(r))
          .toList();
      _log.i('Got ${leases.length} DHCP leases');
      return leases;
    } catch (e, stackTrace) {
      _log.e('Failed to get DHCP leases', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get DHCP leases: $e');
    }
  }

  @override
  Future<bool> addLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  }) async {
    try {
      _log.i('Adding DHCP lease: $address -> $macAddress');
      final commands = [
        '/ip/dhcp-server/lease/add',
        '=address=$address',
        '=mac-address=$macAddress',
      ];

      if (server != null) commands.add('=server=$server');
      if (comment != null) commands.add('=comment=$comment');

      final response = await client.sendCommand(commands);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP lease added successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to add DHCP lease', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to add DHCP lease: $e');
    }
  }

  @override
  Future<bool> removeLease(String id) async {
    try {
      _log.i('Removing DHCP lease: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/lease/remove', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('DHCP lease removed successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to remove DHCP lease', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to remove DHCP lease: $e');
    }
  }

  @override
  Future<bool> makeStatic(String id) async {
    try {
      _log.i('Making lease static: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/lease/make-static', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      _log.i('Lease made static successfully');
      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to make lease static', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to make lease static: $e');
    }
  }

  @override
  Future<bool> enableLease(String id) async {
    try {
      _log.i('Enabling DHCP lease: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/lease/enable', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to enable DHCP lease', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to enable DHCP lease: $e');
    }
  }

  @override
  Future<bool> disableLease(String id) async {
    try {
      _log.i('Disabling DHCP lease: $id');
      final response = await client.sendCommand(['/ip/dhcp-server/lease/disable', '=.id=$id']);
      
      final trap = response.firstWhere((r) => r['type'] == 'trap', orElse: () => {});
      if (trap.isNotEmpty) {
        throw ServerException(trap['message'] ?? 'Unknown error');
      }

      return true;
    } catch (e, stackTrace) {
      _log.e('Failed to disable DHCP lease', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to disable DHCP lease: $e');
    }
  }

  // ==================== Helpers ====================

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
  Future<List<Map<String, String>>> getInterfaces() async {
    try {
      _log.d('Getting interfaces...');
      final response = await client.getInterfaces();
      _log.i('Got ${response.length} interfaces');
      return response;
    } catch (e, stackTrace) {
      _log.e('Failed to get interfaces', error: e, stackTrace: stackTrace);
      throw ServerException('Failed to get interfaces: $e');
    }
  }
}
