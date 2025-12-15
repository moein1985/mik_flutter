import 'dart:math';
import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/hotspot_active_user.dart';
import '../../domain/entities/hotspot_host.dart';
import '../../domain/entities/hotspot_ip_binding.dart';
import '../../domain/entities/hotspot_profile.dart';
import '../../domain/entities/hotspot_server.dart';
import '../../domain/entities/hotspot_user.dart';
import '../../domain/entities/walled_garden.dart';
import '../../domain/repositories/hotspot_repository.dart';

/// Fake implementation of HotspotRepository for development without a real router
class FakeHotspotRepositoryImpl implements HotspotRepository {
  final _random = Random();
  
  // In-memory storage
  List<HotspotServer> _servers = [];
  List<HotspotUser> _users = [];
  List<HotspotActiveUser> _activeUsers = [];
  List<HotspotProfile> _profiles = [];
  List<HotspotIpBinding> _ipBindings = [];
  List<HotspotHost> _hosts = [];
  List<WalledGarden> _walledGarden = [];
  
  final bool _packageEnabled = true;
  int _idCounter = 1;

  FakeHotspotRepositoryImpl() {
    _initializeData();
  }

  void _initializeData() {
    // Initialize with 2 servers
    _servers = [
      HotspotServer(
        id: '*1',
        name: 'hotspot1',
        interfaceName: 'bridge1',
        addressPool: 'hs-pool-1',
        profile: 'default',
        disabled: false,
      ),
      HotspotServer(
        id: '*2',
        name: 'hotspot-guest',
        interfaceName: 'wlan1',
        addressPool: 'guest-pool',
        profile: 'guest-profile',
        disabled: false,
      ),
    ];

    // Initialize default profiles
    _profiles = [
      const HotspotProfile(
        id: '*1',
        name: 'default',
        sessionTimeout: '1d',
        idleTimeout: '30m',
        sharedUsers: '1',
        rateLimit: '10M/10M',
        keepaliveTimeout: '2m',
      ),
      const HotspotProfile(
        id: '*2',
        name: 'guest-profile',
        sessionTimeout: '4h',
        idleTimeout: '15m',
        sharedUsers: '1',
        rateLimit: '5M/5M',
        keepaliveTimeout: '1m',
      ),
      const HotspotProfile(
        id: '*3',
        name: 'premium',
        sessionTimeout: 'none',
        idleTimeout: '1h',
        sharedUsers: '3',
        rateLimit: '50M/50M',
        keepaliveTimeout: '5m',
      ),
    ];

    // Initialize users
    _users = [
      const HotspotUser(
        id: '*1',
        name: 'admin',
        password: 'admin123',
        profile: 'default',
        server: 'hotspot1',
        comment: 'Administrator account',
        disabled: false,
        limitUptime: '30d',
        limitBytesTotal: '10G',
        uptime: '5d 3h',
        bytesIn: '2.5G',
        bytesOut: '1.8G',
      ),
      const HotspotUser(
        id: '*2',
        name: 'guest1',
        password: 'guest123',
        profile: 'guest-profile',
        server: 'hotspot-guest',
        comment: 'Guest user',
        disabled: false,
        limitUptime: '1d',
        limitBytesTotal: '1G',
        uptime: '2h 15m',
        bytesIn: '350M',
        bytesOut: '120M',
      ),
      const HotspotUser(
        id: '*3',
        name: 'premium1',
        password: 'premium123',
        profile: 'premium',
        comment: 'Premium user with unlimited access',
        disabled: false,
        uptime: '10d 5h',
        bytesIn: '15G',
        bytesOut: '8G',
      ),
      const HotspotUser(
        id: '*4',
        name: 'user1',
        password: 'user123',
        profile: 'default',
        disabled: true,
        comment: 'Disabled user',
      ),
    ];

    // Initialize active users (subset of users currently logged in)
    _activeUsers = [
      const HotspotActiveUser(
        id: '*1',
        user: 'admin',
        server: 'hotspot1',
        address: '10.5.50.2',
        macAddress: '00:0C:29:A1:B2:C3',
        loginBy: 'password',
        uptime: '2h 15m',
        sessionTimeLeft: '21h 45m',
        idleTime: '1m 30s',
        bytesIn: '150M',
        bytesOut: '80M',
        packetsIn: '125000',
        packetsOut: '98000',
      ),
      const HotspotActiveUser(
        id: '*2',
        user: 'guest1',
        server: 'hotspot-guest',
        address: '192.168.88.50',
        macAddress: '00:0C:29:D4:E5:F6',
        loginBy: 'password',
        uptime: '45m',
        sessionTimeLeft: '3h 15m',
        idleTime: '30s',
        bytesIn: '45M',
        bytesOut: '12M',
        packetsIn: '35000',
        packetsOut: '15000',
      ),
    ];

    // Initialize IP bindings
    _ipBindings = [
      const HotspotIpBinding(
        id: '*1',
        mac: '00:0C:29:11:22:33',
        address: '10.5.50.10',
        type: 'bypassed',
        server: 'hotspot1',
        comment: 'Office printer - bypass authentication',
        disabled: false,
      ),
      const HotspotIpBinding(
        id: '*2',
        mac: '00:0C:29:44:55:66',
        address: '10.5.50.20',
        type: 'blocked',
        server: 'hotspot1',
        comment: 'Blocked device',
        disabled: false,
      ),
      const HotspotIpBinding(
        id: '*3',
        mac: '00:0C:29:77:88:99',
        type: 'regular',
        toAddress: '10.5.50.30',
        comment: 'Static assignment',
        disabled: false,
      ),
    ];

    // Initialize hosts
    _hosts = [
      const HotspotHost(
        id: '*1',
        macAddress: '00:0C:29:A1:B2:C3',
        address: '10.5.50.2',
        toAddress: '10.5.50.2',
        server: 'hotspot1',
        uptime: '2h 15m',
        idleTime: '1m 30s',
        bytesIn: '150M',
        bytesOut: '80M',
        packetsIn: '125000',
        packetsOut: '98000',
        authorized: true,
        bypassed: false,
      ),
      const HotspotHost(
        id: '*2',
        macAddress: '00:0C:29:D4:E5:F6',
        address: '192.168.88.50',
        toAddress: '192.168.88.50',
        server: 'hotspot-guest',
        uptime: '45m',
        idleTime: '30s',
        bytesIn: '45M',
        bytesOut: '12M',
        packetsIn: '35000',
        packetsOut: '15000',
        authorized: true,
        bypassed: false,
      ),
      const HotspotHost(
        id: '*3',
        macAddress: '00:0C:29:AA:BB:CC',
        address: '10.5.50.25',
        toAddress: '10.5.50.25',
        server: 'hotspot1',
        uptime: '5m',
        idleTime: '2m',
        bytesIn: '1M',
        bytesOut: '500K',
        packetsIn: '1200',
        packetsOut: '800',
        authorized: false,
        bypassed: false,
      ),
    ];

    // Initialize walled garden entries
    _walledGarden = [
      const WalledGarden(
        id: '*1',
        server: 'hotspot1',
        dstHost: '*.google.com',
        action: 'allow',
        method: 'http',
        comment: 'Allow Google services',
        disabled: false,
      ),
      const WalledGarden(
        id: '*2',
        dstHost: 'facebook.com',
        action: 'allow',
        method: 'https',
        comment: 'Allow Facebook',
        disabled: false,
      ),
      const WalledGarden(
        id: '*3',
        server: 'hotspot-guest',
        dstAddress: '8.8.8.8/32',
        dstPort: '53',
        action: 'allow',
        comment: 'Allow Google DNS',
        disabled: false,
      ),
    ];
  }

  Future<void> _simulateDelay() async {
    final delay = Duration(
      milliseconds: AppConfig.fakeMinDelay.inMilliseconds +
          _random.nextInt(
            AppConfig.fakeMaxDelay.inMilliseconds -
                AppConfig.fakeMinDelay.inMilliseconds,
          ),
    );
    await Future.delayed(delay);
  }

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  String _generateId() => '*${_idCounter++}';

  // Server Management
  @override
  Future<Either<Failure, List<HotspotServer>>> getServers() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load HotSpot servers'));
    }
    if (!_packageEnabled) {
      return const Left(
          ServerFailure('HotSpot package is not enabled on this router'));
    }
    return Right(List.from(_servers));
  }

  @override
  Future<Either<Failure, bool>> enableServer(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable server'));
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Server not found'));
    }

    _servers[index] = HotspotServer(
      id: _servers[index].id,
      name: _servers[index].name,
      interfaceName: _servers[index].interfaceName,
      addressPool: _servers[index].addressPool,
      profile: _servers[index].profile,
      disabled: false,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableServer(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable server'));
    }

    final index = _servers.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Server not found'));
    }

    _servers[index] = HotspotServer(
      id: _servers[index].id,
      name: _servers[index].name,
      interfaceName: _servers[index].interfaceName,
      addressPool: _servers[index].addressPool,
      profile: _servers[index].profile,
      disabled: true,
    );

    return const Right(true);
  }

  // User Management
  @override
  Future<Either<Failure, List<HotspotUser>>> getUsers() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load users'));
    }
    return Right(List.from(_users));
  }

  @override
  Future<Either<Failure, bool>> addUser({
    required String name,
    required String password,
    String? profile,
    String? server,
    String? comment,
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add user'));
    }

    // Check duplicate name
    if (_users.any((u) => u.name == name)) {
      return const Left(ServerFailure('User with this name already exists'));
    }

    _users.add(HotspotUser(
      id: _generateId(),
      name: name,
      password: password,
      profile: profile,
      server: server,
      comment: comment,
      disabled: false,
      limitUptime: limitUptime,
      limitBytesIn: limitBytesIn,
      limitBytesOut: limitBytesOut,
      limitBytesTotal: limitBytesTotal,
    ));

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> editUser({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? server,
    String? comment,
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit user'));
    }

    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) {
      return const Left(ServerFailure('User not found'));
    }

    final user = _users[index];
    _users[index] = HotspotUser(
      id: user.id,
      name: name ?? user.name,
      password: password ?? user.password,
      profile: profile ?? user.profile,
      server: server ?? user.server,
      comment: comment ?? user.comment,
      disabled: user.disabled,
      limitUptime: limitUptime ?? user.limitUptime,
      limitBytesIn: limitBytesIn ?? user.limitBytesIn,
      limitBytesOut: limitBytesOut ?? user.limitBytesOut,
      limitBytesTotal: limitBytesTotal ?? user.limitBytesTotal,
      uptime: user.uptime,
      bytesIn: user.bytesIn,
      bytesOut: user.bytesOut,
      packetsIn: user.packetsIn,
      packetsOut: user.packetsOut,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeUser(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove user'));
    }

    _users.removeWhere((u) => u.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> enableUser(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable user'));
    }

    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) {
      return const Left(ServerFailure('User not found'));
    }

    final user = _users[index];
    _users[index] = HotspotUser(
      id: user.id,
      name: user.name,
      password: user.password,
      profile: user.profile,
      server: user.server,
      comment: user.comment,
      disabled: false,
      limitUptime: user.limitUptime,
      limitBytesIn: user.limitBytesIn,
      limitBytesOut: user.limitBytesOut,
      limitBytesTotal: user.limitBytesTotal,
      uptime: user.uptime,
      bytesIn: user.bytesIn,
      bytesOut: user.bytesOut,
      packetsIn: user.packetsIn,
      packetsOut: user.packetsOut,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableUser(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable user'));
    }

    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) {
      return const Left(ServerFailure('User not found'));
    }

    final user = _users[index];
    _users[index] = HotspotUser(
      id: user.id,
      name: user.name,
      password: user.password,
      profile: user.profile,
      server: user.server,
      comment: user.comment,
      disabled: true,
      limitUptime: user.limitUptime,
      limitBytesIn: user.limitBytesIn,
      limitBytesOut: user.limitBytesOut,
      limitBytesTotal: user.limitBytesTotal,
      uptime: user.uptime,
      bytesIn: user.bytesIn,
      bytesOut: user.bytesOut,
      packetsIn: user.packetsIn,
      packetsOut: user.packetsOut,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> resetUserCounters(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to reset counters'));
    }

    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) {
      return const Left(ServerFailure('User not found'));
    }

    final user = _users[index];
    _users[index] = HotspotUser(
      id: user.id,
      name: user.name,
      password: user.password,
      profile: user.profile,
      server: user.server,
      comment: user.comment,
      disabled: user.disabled,
      limitUptime: user.limitUptime,
      limitBytesIn: user.limitBytesIn,
      limitBytesOut: user.limitBytesOut,
      limitBytesTotal: user.limitBytesTotal,
      uptime: '0s',
      bytesIn: '0',
      bytesOut: '0',
      packetsIn: '0',
      packetsOut: '0',
    );

    return const Right(true);
  }

  // Active Users
  @override
  Future<Either<Failure, List<HotspotActiveUser>>> getActiveUsers() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load active users'));
    }
    return Right(List.from(_activeUsers));
  }

  @override
  Future<Either<Failure, bool>> disconnectUser(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disconnect user'));
    }

    _activeUsers.removeWhere((u) => u.id == id);
    return const Right(true);
  }

  // Profile Management
  @override
  Future<Either<Failure, List<HotspotProfile>>> getProfiles() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load profiles'));
    }
    return Right(List.from(_profiles));
  }

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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add profile'));
    }

    if (_profiles.any((p) => p.name == name)) {
      return const Left(ServerFailure('Profile with this name already exists'));
    }

    _profiles.add(HotspotProfile(
      id: _generateId(),
      name: name,
      sessionTimeout: sessionTimeout,
      idleTimeout: idleTimeout,
      sharedUsers: sharedUsers,
      rateLimit: rateLimit,
      keepaliveTimeout: keepaliveTimeout,
      statusAutorefresh: statusAutorefresh,
      onLogin: onLogin,
      onLogout: onLogout,
    ));

    return const Right(true);
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit profile'));
    }

    final index = _profiles.indexWhere((p) => p.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Profile not found'));
    }

    final profile = _profiles[index];
    _profiles[index] = HotspotProfile(
      id: profile.id,
      name: name ?? profile.name,
      sessionTimeout: sessionTimeout ?? profile.sessionTimeout,
      idleTimeout: idleTimeout ?? profile.idleTimeout,
      sharedUsers: sharedUsers ?? profile.sharedUsers,
      rateLimit: rateLimit ?? profile.rateLimit,
      keepaliveTimeout: keepaliveTimeout ?? profile.keepaliveTimeout,
      statusAutorefresh: statusAutorefresh ?? profile.statusAutorefresh,
      onLogin: onLogin ?? profile.onLogin,
      onLogout: onLogout ?? profile.onLogout,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeProfile(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove profile'));
    }

    _profiles.removeWhere((p) => p.id == id);
    return const Right(true);
  }

  // IP Binding Management
  @override
  Future<Either<Failure, List<HotspotIpBinding>>> getIpBindings() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load IP bindings'));
    }
    return Right(List.from(_ipBindings));
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add IP binding'));
    }

    _ipBindings.add(HotspotIpBinding(
      id: _generateId(),
      mac: mac,
      address: address,
      toAddress: toAddress,
      server: server,
      type: type,
      comment: comment,
      disabled: false,
    ));

    return const Right(true);
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit IP binding'));
    }

    final index = _ipBindings.indexWhere((b) => b.id == id);
    if (index == -1) {
      return const Left(ServerFailure('IP binding not found'));
    }

    final binding = _ipBindings[index];
    _ipBindings[index] = HotspotIpBinding(
      id: binding.id,
      mac: mac ?? binding.mac,
      address: address ?? binding.address,
      toAddress: toAddress ?? binding.toAddress,
      server: server ?? binding.server,
      type: type ?? binding.type,
      comment: comment ?? binding.comment,
      disabled: binding.disabled,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeIpBinding(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove IP binding'));
    }

    _ipBindings.removeWhere((b) => b.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> enableIpBinding(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable IP binding'));
    }

    final index = _ipBindings.indexWhere((b) => b.id == id);
    if (index == -1) {
      return const Left(ServerFailure('IP binding not found'));
    }

    final binding = _ipBindings[index];
    _ipBindings[index] = HotspotIpBinding(
      id: binding.id,
      mac: binding.mac,
      address: binding.address,
      toAddress: binding.toAddress,
      server: binding.server,
      type: binding.type,
      comment: binding.comment,
      disabled: false,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableIpBinding(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable IP binding'));
    }

    final index = _ipBindings.indexWhere((b) => b.id == id);
    if (index == -1) {
      return const Left(ServerFailure('IP binding not found'));
    }

    final binding = _ipBindings[index];
    _ipBindings[index] = HotspotIpBinding(
      id: binding.id,
      mac: binding.mac,
      address: binding.address,
      toAddress: binding.toAddress,
      server: binding.server,
      type: binding.type,
      comment: binding.comment,
      disabled: true,
    );

    return const Right(true);
  }

  // Hosts Management
  @override
  Future<Either<Failure, List<HotspotHost>>> getHosts() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load hosts'));
    }
    return Right(List.from(_hosts));
  }

  @override
  Future<Either<Failure, bool>> removeHost(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove host'));
    }

    _hosts.removeWhere((h) => h.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> makeHostBinding({
    required String id,
    required String type,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to create binding'));
    }

    final host = _hosts.firstWhere((h) => h.id == id,
        orElse: () => throw Exception('Host not found'));

    _ipBindings.add(HotspotIpBinding(
      id: _generateId(),
      mac: host.macAddress,
      address: host.address,
      type: type,
      server: host.server,
      comment: 'Created from host ${host.macAddress}',
      disabled: false,
    ));

    return const Right(true);
  }

  // Walled Garden Management
  @override
  Future<Either<Failure, List<WalledGarden>>> getWalledGarden() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load walled garden'));
    }
    return Right(List.from(_walledGarden));
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to add walled garden entry'));
    }

    _walledGarden.add(WalledGarden(
      id: _generateId(),
      server: server,
      srcAddress: srcAddress,
      dstAddress: dstAddress,
      dstHost: dstHost,
      dstPort: dstPort,
      path: path,
      action: action,
      method: method,
      comment: comment,
      disabled: false,
    ));

    return const Right(true);
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
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to edit walled garden entry'));
    }

    final index = _walledGarden.indexWhere((w) => w.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Walled garden entry not found'));
    }

    final entry = _walledGarden[index];
    _walledGarden[index] = WalledGarden(
      id: entry.id,
      server: server ?? entry.server,
      srcAddress: srcAddress ?? entry.srcAddress,
      dstAddress: dstAddress ?? entry.dstAddress,
      dstHost: dstHost ?? entry.dstHost,
      dstPort: dstPort ?? entry.dstPort,
      path: path ?? entry.path,
      action: action ?? entry.action,
      method: method ?? entry.method,
      comment: comment ?? entry.comment,
      disabled: entry.disabled,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> removeWalledGarden(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to remove walled garden entry'));
    }

    _walledGarden.removeWhere((w) => w.id == id);
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> enableWalledGarden(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to enable walled garden entry'));
    }

    final index = _walledGarden.indexWhere((w) => w.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Walled garden entry not found'));
    }

    final entry = _walledGarden[index];
    _walledGarden[index] = WalledGarden(
      id: entry.id,
      server: entry.server,
      srcAddress: entry.srcAddress,
      dstAddress: entry.dstAddress,
      dstHost: entry.dstHost,
      dstPort: entry.dstPort,
      path: entry.path,
      action: entry.action,
      method: entry.method,
      comment: entry.comment,
      disabled: false,
    );

    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> disableWalledGarden(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to disable walled garden entry'));
    }

    final index = _walledGarden.indexWhere((w) => w.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Walled garden entry not found'));
    }

    final entry = _walledGarden[index];
    _walledGarden[index] = WalledGarden(
      id: entry.id,
      server: entry.server,
      srcAddress: entry.srcAddress,
      dstAddress: entry.dstAddress,
      dstHost: entry.dstHost,
      dstPort: entry.dstPort,
      path: entry.path,
      action: entry.action,
      method: entry.method,
      comment: entry.comment,
      disabled: true,
    );

    return const Right(true);
  }

  // Setup
  @override
  Future<Either<Failure, bool>> setupHotspot({
    required String interface,
    String? addressPool,
    String? dnsName,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to setup HotSpot'));
    }

    // Add a new server with the given configuration
    final serverName = 'hotspot-${_servers.length + 1}';
    _servers.add(HotspotServer(
      id: _generateId(),
      name: serverName,
      interfaceName: interface,
      addressPool: addressPool ?? 'hs-pool-${_servers.length + 1}',
      profile: 'default',
      disabled: false,
    ));

    return const Right(true);
  }

  // Package & Setup Helpers
  @override
  Future<Either<Failure, bool>> isHotspotPackageEnabled() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to check HotSpot package'));
    }
    return Right(_packageEnabled);
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getInterfaces() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load interfaces'));
    }

    return const Right([
      {'name': 'ether1', 'type': 'ether'},
      {'name': 'ether2', 'type': 'ether'},
      {'name': 'wlan1', 'type': 'wlan'},
      {'name': 'bridge1', 'type': 'bridge'},
    ]);
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getIpPools() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load IP pools'));
    }

    return const Right([
      {'name': 'hs-pool-1', 'ranges': '10.5.50.2-10.5.50.254'},
      {'name': 'guest-pool', 'ranges': '192.168.88.10-192.168.88.254'},
      {'name': 'dhcp-pool', 'ranges': '192.168.1.2-192.168.1.254'},
    ]);
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getIpAddresses() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load IP addresses'));
    }

    return const Right([
      {'address': '10.5.50.1/24', 'interface': 'bridge1'},
      {'address': '192.168.88.1/24', 'interface': 'wlan1'},
      {'address': '192.168.1.1/24', 'interface': 'ether1'},
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

    // In a real implementation, this would add the pool to the router
    // Here we just simulate success
    return const Right(true);
  }

  // Reset HotSpot
  @override
  Future<Either<Failure, bool>> resetHotspot({
    bool deleteUsers = true,
    bool deleteProfiles = true,
    bool deleteIpBindings = true,
    bool deleteWalledGarden = true,
    bool deleteServers = true,
    bool deleteServerProfiles = true,
    bool deleteIpPools = false,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to reset HotSpot'));
    }

    // Simulate longer operation
    await Future.delayed(const Duration(seconds: 2));

    if (deleteUsers) _users.clear();
    if (deleteProfiles) _profiles.clear();
    if (deleteIpBindings) _ipBindings.clear();
    if (deleteWalledGarden) _walledGarden.clear();
    if (deleteServers) _servers.clear();
    
    _activeUsers.clear();
    _hosts.clear();

    // Reinitialize with defaults if needed
    if (_profiles.isEmpty) {
      _profiles.add(const HotspotProfile(
        id: '*1',
        name: 'default',
      ));
    }

    return const Right(true);
  }
}
