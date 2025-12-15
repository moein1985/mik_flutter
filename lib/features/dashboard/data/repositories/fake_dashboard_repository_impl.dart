import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/system_resource.dart';
import '../../domain/entities/router_interface.dart';
import '../../domain/entities/ip_address.dart';
import '../../domain/entities/firewall_rule.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Fake implementation of DashboardRepository for development without a real router
/// 
/// This repository generates realistic fake data and simulates network delays
/// to test the app without needing a physical MikroTik router
class FakeDashboardRepositoryImpl implements DashboardRepository {
  // In-memory storage for simulating state changes
  List<RouterInterface> _interfaces = [];
  List<IpAddress> _ipAddresses = [];
  List<FirewallRule> _firewallRules = [];
  List<DhcpLease> _dhcpLeases = [];
  
  FakeDashboardRepositoryImpl() {
    _initializeFakeData();
  }
  
  void _initializeFakeData() {
    _interfaces = FakeDataGenerator.generateInterfaces(count: 5);
    _ipAddresses = FakeDataGenerator.generateIpAddresses(count: 6);
    _firewallRules = FakeDataGenerator.generateFirewallRules(count: 10);
    _dhcpLeases = FakeDataGenerator.generateDhcpLeases(count: 8);
  }
  
  /// Simulate network delay
  Future<void> _simulateDelay() async {
    final delay = FakeDataGenerator.generateRandomDelay(
      AppConfig.fakeMinDelay,
      AppConfig.fakeMaxDelay,
    );
    await Future.delayed(delay);
  }
  
  /// Check if we should simulate an error
  bool _shouldSimulateError() {
    return FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);
  }
  
  @override
  Future<Either<Failure, SystemResource>> getSystemResources() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to connect to router'));
    }
    
    final resource = FakeDataGenerator.generateSystemResource();
    return Right(resource);
  }
  
  @override
  Future<Either<Failure, List<RouterInterface>>> getInterfaces() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch interfaces'));
    }
    
    return Right(List.from(_interfaces));
  }
  
  @override
  Future<Either<Failure, bool>> enableInterface(String id) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to enable interface'));
    }
    
    final index = _interfaces.indexWhere((i) => i.id == id);
    if (index == -1) {
      return Left(ServerFailure('Interface not found'));
    }
    
    // Update interface state
    final interface = _interfaces[index];
    _interfaces[index] = RouterInterface(
      id: interface.id,
      name: interface.name,
      type: interface.type,
      running: true,
      disabled: false,
      comment: interface.comment,
      macAddress: interface.macAddress,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, bool>> disableInterface(String id) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to disable interface'));
    }
    
    final index = _interfaces.indexWhere((i) => i.id == id);
    if (index == -1) {
      return Left(ServerFailure('Interface not found'));
    }
    
    // Update interface state
    final interface = _interfaces[index];
    _interfaces[index] = RouterInterface(
      id: interface.id,
      name: interface.name,
      type: interface.type,
      running: false,
      disabled: true,
      comment: interface.comment,
      macAddress: interface.macAddress,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, List<IpAddress>>> getIpAddresses() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch IP addresses'));
    }
    
    return Right(List.from(_ipAddresses));
  }
  
  @override
  Future<Either<Failure, bool>> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to add IP address'));
    }
    
    // Validate IP format (basic)
    if (!address.contains('/')) {
      return Left(ServerFailure('Invalid IP address format. Use CIDR notation (e.g., 192.168.1.1/24)'));
    }
    
    final parts = address.split('/');
    final ipParts = parts[0].split('.');
    if (ipParts.length != 4) {
      return Left(ServerFailure('Invalid IP address'));
    }
    
    // Calculate network address (simplified)
    final network = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.0';
    
    // Create new IP address
    final newIp = IpAddress(
      id: '*${_ipAddresses.length + 1}',
      address: address,
      network: network,
      interfaceName: interfaceName,
      disabled: false,
      invalid: false,
      dynamic: false,
      comment: comment,
    );
    
    _ipAddresses.add(newIp);
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, bool>> updateIpAddress({
    required String id,
    String? address,
    String? interfaceName,
    String? comment,
  }) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to update IP address'));
    }
    
    final index = _ipAddresses.indexWhere((ip) => ip.id == id);
    if (index == -1) {
      return Left(ServerFailure('IP address not found'));
    }
    
    final oldIp = _ipAddresses[index];
    
    // Calculate new network if address changed
    String? newNetwork;
    if (address != null && address.contains('/')) {
      final ipParts = address.split('/')[0].split('.');
      if (ipParts.length == 4) {
        newNetwork = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.0';
      }
    }
    
    _ipAddresses[index] = IpAddress(
      id: oldIp.id,
      address: address ?? oldIp.address,
      network: newNetwork ?? oldIp.network,
      interfaceName: interfaceName ?? oldIp.interfaceName,
      disabled: oldIp.disabled,
      invalid: oldIp.invalid,
      dynamic: oldIp.dynamic,
      comment: comment ?? oldIp.comment,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, bool>> removeIpAddress(String id) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to remove IP address'));
    }
    
    final index = _ipAddresses.indexWhere((ip) => ip.id == id);
    if (index == -1) {
      return Left(ServerFailure('IP address not found'));
    }
    
    _ipAddresses.removeAt(index);
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, bool>> toggleIpAddress(String id, bool enable) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to toggle IP address'));
    }
    
    final index = _ipAddresses.indexWhere((ip) => ip.id == id);
    if (index == -1) {
      return Left(ServerFailure('IP address not found'));
    }
    
    final oldIp = _ipAddresses[index];
    _ipAddresses[index] = IpAddress(
      id: oldIp.id,
      address: oldIp.address,
      network: oldIp.network,
      interfaceName: oldIp.interfaceName,
      disabled: !enable,
      invalid: oldIp.invalid,
      dynamic: oldIp.dynamic,
      comment: oldIp.comment,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, List<FirewallRule>>> getFirewallRules() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch firewall rules'));
    }
    
    return Right(List.from(_firewallRules));
  }
  
  @override
  Future<Either<Failure, bool>> enableFirewallRule(String id) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to enable firewall rule'));
    }
    
    final index = _firewallRules.indexWhere((rule) => rule.id == id);
    if (index == -1) {
      return Left(ServerFailure('Firewall rule not found'));
    }
    
    final rule = _firewallRules[index];
    _firewallRules[index] = FirewallRule(
      id: rule.id,
      chain: rule.chain,
      action: rule.action,
      disabled: false,
      invalid: rule.invalid,
      dynamic: rule.dynamic,
      srcAddress: rule.srcAddress,
      dstAddress: rule.dstAddress,
      protocol: rule.protocol,
      dstPort: rule.dstPort,
      comment: rule.comment,
      bytes: rule.bytes,
      packets: rule.packets,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, bool>> disableFirewallRule(String id) async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to disable firewall rule'));
    }
    
    final index = _firewallRules.indexWhere((rule) => rule.id == id);
    if (index == -1) {
      return Left(ServerFailure('Firewall rule not found'));
    }
    
    final rule = _firewallRules[index];
    _firewallRules[index] = FirewallRule(
      id: rule.id,
      chain: rule.chain,
      action: rule.action,
      disabled: true,
      invalid: rule.invalid,
      dynamic: rule.dynamic,
      srcAddress: rule.srcAddress,
      dstAddress: rule.dstAddress,
      protocol: rule.protocol,
      dstPort: rule.dstPort,
      comment: rule.comment,
      bytes: rule.bytes,
      packets: rule.packets,
    );
    
    return const Right(true);
  }
  
  @override
  Future<Either<Failure, List<DhcpLease>>> getDhcpLeases() async {
    await _simulateDelay();
    
    if (_shouldSimulateError()) {
      return Left(ServerFailure('Failed to fetch DHCP leases'));
    }
    
    return Right(List.from(_dhcpLeases));
  }
}
