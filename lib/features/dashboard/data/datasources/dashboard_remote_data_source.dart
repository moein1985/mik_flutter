import '../../../../core/network/routeros_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../models/system_resource_model.dart';
import '../models/router_interface_model.dart';
import '../models/ip_address_model.dart';
import '../models/firewall_rule_model.dart';
import '../models/dhcp_lease_model.dart';

abstract class DashboardRemoteDataSource {
  Future<SystemResourceModel> getSystemResources();
  Future<List<RouterInterfaceModel>> getInterfaces();
  Future<bool> enableInterface(String id);
  Future<bool> disableInterface(String id);
  Future<List<IpAddressModel>> getIpAddresses();
  Future<bool> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  });
  Future<bool> removeIpAddress(String id);
  Future<List<FirewallRuleModel>> getFirewallRules();
  Future<bool> enableFirewallRule(String id);
  Future<bool> disableFirewallRule(String id);
  Future<List<DhcpLeaseModel>> getDhcpLeases();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final AuthRemoteDataSource authRemoteDataSource;

  DashboardRemoteDataSourceImpl({required this.authRemoteDataSource});

  RouterOSClient get client {
    if (authRemoteDataSource.client == null) {
      throw ServerException('Not connected to router');
    }
    return authRemoteDataSource.client!;
  }

  @override
  Future<SystemResourceModel> getSystemResources() async {
    try {
      final response = await client.getSystemResources();
      
      if (response.isEmpty) {
        throw ServerException('No system resource data received');
      }
      
      return SystemResourceModel.fromMap(response.first);
    } catch (e) {
      throw ServerException('Failed to get system resources: $e');
    }
  }

  @override
  Future<List<RouterInterfaceModel>> getInterfaces() async {
    try {
      final response = await client.getInterfaces();
      
      return response.map((item) => RouterInterfaceModel.fromMap(item)).toList();
    } catch (e) {
      throw ServerException('Failed to get interfaces: $e');
    }
  }

  @override
  Future<bool> enableInterface(String id) async {
    try {
      return await client.enableInterface(id);
    } catch (e) {
      throw ServerException('Failed to enable interface: $e');
    }
  }

  @override
  Future<bool> disableInterface(String id) async {
    try {
      return await client.disableInterface(id);
    } catch (e) {
      throw ServerException('Failed to disable interface: $e');
    }
  }

  @override
  Future<List<IpAddressModel>> getIpAddresses() async {
    try {
      final response = await client.getIpAddresses();
      
      return response.map((item) => IpAddressModel.fromMap(item)).toList();
    } catch (e) {
      throw ServerException('Failed to get IP addresses: $e');
    }
  }

  @override
  Future<bool> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    try {
      return await client.addIpAddress(
        address: address,
        interfaceName: interfaceName,
        comment: comment,
      );
    } catch (e) {
      throw ServerException('Failed to add IP address: $e');
    }
  }

  @override
  Future<bool> removeIpAddress(String id) async {
    try {
      return await client.removeIpAddress(id);
    } catch (e) {
      throw ServerException('Failed to remove IP address: $e');
    }
  }

  @override
  Future<List<FirewallRuleModel>> getFirewallRules() async {
    try {
      // Dashboard uses filter rules by default
      final response = await client.getFirewallRules('/ip/firewall/filter');
      
      return response.map((item) => FirewallRuleModel.fromMap(item)).toList();
    } catch (e) {
      throw ServerException('Failed to get firewall rules: $e');
    }
  }

  @override
  Future<bool> enableFirewallRule(String id) async {
    try {
      return await client.enableFirewallRule('/ip/firewall/filter', id);
    } catch (e) {
      throw ServerException('Failed to enable firewall rule: $e');
    }
  }

  @override
  Future<bool> disableFirewallRule(String id) async {
    try {
      return await client.disableFirewallRule('/ip/firewall/filter', id);
    } catch (e) {
      throw ServerException('Failed to disable firewall rule: $e');
    }
  }

  @override
  Future<List<DhcpLeaseModel>> getDhcpLeases() async {
    try {
      final response = await client.getDhcpLeases();
      
      return response.map((item) => DhcpLeaseModel.fromMap(item)).toList();
    } catch (e) {
      throw ServerException('Failed to get DHCP leases: $e');
    }
  }
}
