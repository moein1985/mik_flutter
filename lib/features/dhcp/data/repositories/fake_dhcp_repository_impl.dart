import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/dhcp_server.dart';
import '../../domain/entities/dhcp_network.dart';
import '../../domain/entities/dhcp_lease.dart';
import '../../domain/repositories/dhcp_repository.dart';

/// Fake implementation of DhcpRepository for development without a real router
class FakeDhcpRepositoryImpl implements DhcpRepository {
  // In-memory data stores
  final List<DhcpServer> _servers = [
    DhcpServer(
      id: '1',
      name: 'dhcp-server1',
      interface: 'bridge',
      addressPool: 'dhcp_pool',
      leaseTime: '10m',
      authoritative: true,
      disabled: false,
      invalid: false,
    ),
  ];

  final List<DhcpNetwork> _networks = [
    DhcpNetwork(
      id: '1',
      address: '192.168.88.0/24',
      gateway: '192.168.88.1',
      netmask: '24',
      dnsServer: '192.168.88.1',
      domain: 'local',
      comment: 'Main network',
    ),
  ];

  final List<DhcpLease> _leases = [];

  FakeDhcpRepositoryImpl() {
    // Generate 8 fake leases (2 static, 6 dynamic)
    _leases.addAll([
      DhcpLease(
        id: '1',
        address: '192.168.88.50',
        macAddress: 'AA:BB:CC:DD:EE:01',
        hostName: 'admin-pc',
        server: 'dhcp-server1',
        status: 'bound',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        comment: 'Static lease for admin',
        dynamic: false,
        disabled: false,
        blocked: false,
      ),
      DhcpLease(
        id: '2',
        address: '192.168.88.51',
        macAddress: 'AA:BB:CC:DD:EE:02',
        hostName: 'server-01',
        server: 'dhcp-server1',
        status: 'bound',
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        comment: 'Static lease for server',
        dynamic: false,
        disabled: false,
        blocked: false,
      ),
      ...List.generate(6, (i) => DhcpLease(
        id: (i + 3).toString(),
        address: '192.168.88.${100 + i}',
        macAddress: 'AA:BB:CC:DD:EE:${(i + 10).toRadixString(16).padLeft(2, '0').toUpperCase()}',
        hostName: 'device-${i + 1}',
        server: 'dhcp-server1',
        status: 'bound',
        expiresAfter: '${9 - i}m${30 - (i * 5)}s',
        lastSeen: DateTime.now().subtract(Duration(seconds: 30 + i * 10)).toIso8601String(),
        dynamic: true,
        disabled: false,
        blocked: false,
      )),
    ]);
  }

  Future<void> _simulateDelay() => 
      Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() => 
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  // ==================== DHCP Servers ====================

  @override
  Future<Either<Failure, List<DhcpServer>>> getServers() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load DHCP servers'));
    }
    return Right(List.from(_servers));
  }

  @override
  Future<Either<Failure, bool>> addServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add DHCP server'));
    }

    // Check for duplicate name
    if (_servers.any((s) => s.name == name)) {
      return const Left(ServerFailure('Server with this name already exists'));
    }

    final server = DhcpServer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      interface: interface,
      addressPool: addressPool,
      leaseTime: leaseTime ?? '10m',
      authoritative: authoritative ?? false,
      disabled: false,
      invalid: false,
    );

    _servers.add(server);
    return const Right(true);
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit DHCP server'));
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Server not found'));
    }

    final server = _servers[index];
    _servers[index] = DhcpServer(
      id: server.id,
      name: name ?? server.name,
      interface: interface ?? server.interface,
      addressPool: addressPool ?? server.addressPool,
      leaseTime: leaseTime ?? server.leaseTime,
      authoritative: authoritative ?? server.authoritative,
      disabled: server.disabled,
      invalid: server.invalid,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeServer(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove DHCP server'));
    }

    _servers.removeWhere((s) => s.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> enableServer(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable DHCP server'));
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Server not found'));
    }

    final server = _servers[index];
    _servers[index] = DhcpServer(
      id: server.id,
      name: server.name,
      interface: server.interface,
      addressPool: server.addressPool,
      leaseTime: server.leaseTime,
      authoritative: server.authoritative,
      disabled: false,
      invalid: server.invalid,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableServer(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable DHCP server'));
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Server not found'));
    }

    final server = _servers[index];
    _servers[index] = DhcpServer(
      id: server.id,
      name: server.name,
      interface: server.interface,
      addressPool: server.addressPool,
      leaseTime: server.leaseTime,
      authoritative: server.authoritative,
      disabled: true,
      invalid: server.invalid,
    );

    return const Right(true);
  }

  // ==================== DHCP Networks ====================

  @override
  Future<Either<Failure, List<DhcpNetwork>>> getNetworks() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load DHCP networks'));
    }
    return Right(List.from(_networks));
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add DHCP network'));
    }

    // Check for duplicate address
    if (_networks.any((n) => n.address == address)) {
      return const Left(ServerFailure('Network with this address already exists'));
    }

    final network = DhcpNetwork(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: address,
      gateway: gateway,
      netmask: netmask,
      dnsServer: dnsServer,
      domain: domain,
      comment: comment,
    );

    _networks.add(network);
    return const Right(true);
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit DHCP network'));
    }

    final index = _networks.indexWhere((n) => n.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Network not found'));
    }

    final network = _networks[index];
    _networks[index] = DhcpNetwork(
      id: network.id,
      address: address ?? network.address,
      gateway: gateway ?? network.gateway,
      netmask: netmask ?? network.netmask,
      dnsServer: dnsServer ?? network.dnsServer,
      domain: domain ?? network.domain,
      comment: comment ?? network.comment,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeNetwork(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove DHCP network'));
    }

    _networks.removeWhere((n) => n.id == id);
    return const Right(true);
  }

  // ==================== DHCP Leases ====================

  @override
  Future<Either<Failure, List<DhcpLease>>> getLeases() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load DHCP leases'));
    }
    return Right(List.from(_leases));
  }

  @override
  Future<Either<Failure, bool>> addLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add DHCP lease'));
    }

    // Check for duplicate address or MAC
    if (_leases.any((l) => l.address == address)) {
      return const Left(ServerFailure('Lease with this address already exists'));
    }
    if (_leases.any((l) => l.macAddress == macAddress)) {
      return const Left(ServerFailure('Lease with this MAC address already exists'));
    }

    final lease = DhcpLease(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: address,
      macAddress: macAddress,
      server: server ?? 'dhcp-server1',
      status: 'bound',
      lastSeen: DateTime.now().toIso8601String(),
      comment: comment,
      dynamic: false,
      disabled: false,
      blocked: false,
    );

    _leases.add(lease);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeLease(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove DHCP lease'));
    }

    _leases.removeWhere((l) => l.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> makeStatic(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to make lease static'));
    }

    final index = _leases.indexWhere((l) => l.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Lease not found'));
    }

    final lease = _leases[index];
    _leases[index] = DhcpLease(
      id: lease.id,
      address: lease.address,
      macAddress: lease.macAddress,
      server: lease.server,
      status: lease.status,
      lastSeen: lease.lastSeen,
      hostName: lease.hostName,
      comment: lease.comment,
      dynamic: false,
      disabled: lease.disabled,
      blocked: lease.blocked,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> enableLease(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable DHCP lease'));
    }

    final index = _leases.indexWhere((l) => l.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Lease not found'));
    }

    final lease = _leases[index];
    _leases[index] = DhcpLease(
      id: lease.id,
      address: lease.address,
      macAddress: lease.macAddress,
      server: lease.server,
      status: lease.status,
      lastSeen: lease.lastSeen,
      hostName: lease.hostName,
      comment: lease.comment,
      dynamic: lease.dynamic,
      disabled: false,
      blocked: lease.blocked,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableLease(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable DHCP lease'));
    }

    final index = _leases.indexWhere((l) => l.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Lease not found'));
    }

    final lease = _leases[index];
    _leases[index] = DhcpLease(
      id: lease.id,
      address: lease.address,
      macAddress: lease.macAddress,
      server: lease.server,
      status: lease.status,
      lastSeen: lease.lastSeen,
      hostName: lease.hostName,
      comment: lease.comment,
      dynamic: lease.dynamic,
      disabled: true,
      blocked: lease.blocked,
    );

    return const Right(true);
  }

  // ==================== Helpers ====================

  @override
  Future<Either<Failure, List<Map<String, String>>>> getIpPools() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load IP pools'));
    }

    return const Right([
      {'id': '1', 'name': 'dhcp_pool', 'ranges': '192.168.88.10-192.168.88.254'},
      {'id': '2', 'name': 'guest_pool', 'ranges': '192.168.100.10-192.168.100.254'},
    ]);
  }

  @override
  Future<Either<Failure, bool>> addIpPool({
    required String name,
    required String ranges,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add IP pool'));
    }
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getInterfaces() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load interfaces'));
    }

    return const Right([
      {'id': '1', 'name': 'bridge'},
      {'id': '2', 'name': 'ether1'},
      {'id': '3', 'name': 'ether2'},
      {'id': '4', 'name': 'wlan1'},
    ]);
  }
}
