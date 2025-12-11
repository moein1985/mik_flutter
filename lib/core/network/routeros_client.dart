import 'clients/routeros_system_client.dart';
import 'clients/routeros_hotspot_client.dart';
import 'clients/routeros_diagnostic_client.dart';
import 'clients/routeros_backup_client.dart';
import 'clients/routeros_logs_client.dart';
import 'clients/routeros_queues_client.dart';
import 'clients/routeros_wireless_client.dart';
import 'clients/routeros_dhcp_client.dart';

/// Main RouterOS client that provides access to all specialized clients
class RouterOSClient {
  final String host;
  final int port;
  final bool useSsl;

  late final RouterOSSystemClient _systemClient;
  late final RouterOSHotspotClient _hotspotClient;
  late final RouterOSDiagnosticClient _diagnosticClient;
  late final RouterOSBackupClient _backupClient;
  late final RouterOSLogsClient _logsClient;
  late final RouterOSQueuesClient _queuesClient;
  late final RouterOSWirelessClient _wirelessClient;
  late final RouterOSDhcpClient _dhcpClient;

  RouterOSClient({
    required this.host,
    required this.port,
    this.useSsl = false,
  }) {
    _systemClient = RouterOSSystemClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _hotspotClient = RouterOSHotspotClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _diagnosticClient = RouterOSDiagnosticClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _backupClient = RouterOSBackupClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _logsClient = RouterOSLogsClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _queuesClient = RouterOSQueuesClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _wirelessClient = RouterOSWirelessClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
    _dhcpClient = RouterOSDhcpClient(
      host: host,
      port: port,
      useSsl: useSsl,
    );
  }

  bool get isConnected => _systemClient.isConnected;

  /// Connect to RouterOS device
  Future<void> connect() async {
    await _systemClient.connect();
    
    // Share the system client's socket with all other clients
    final socket = _systemClient.socket;
    if (socket != null) {
      _hotspotClient.useExistingSocket(socket);
      _diagnosticClient.useExistingSocket(socket);
      _backupClient.useExistingSocket(socket);
      _logsClient.useExistingSocket(socket);
      _queuesClient.useExistingSocket(socket);
      _wirelessClient.useExistingSocket(socket);
      _dhcpClient.useExistingSocket(socket);
    }
  }

  /// Disconnect from RouterOS device
  Future<void> disconnect() async {
    await _systemClient.disconnect();
  }

  /// Login to RouterOS
  Future<bool> login(String username, String password) async {
    return _systemClient.login(username, password);
  }

  // ==================== SYSTEM CLIENT METHODS ====================

  /// Get system resources
  Future<List<Map<String, String>>> getSystemResources() async {
    return _systemClient.getSystemResources();
  }

  /// Get all interfaces
  Future<List<Map<String, String>>> getInterfaces() async {
    return _systemClient.getInterfaces();
  }

  /// Enable an interface
  Future<bool> enableInterface(String id) async {
    return _systemClient.enableInterface(id);
  }

  /// Disable an interface
  Future<bool> disableInterface(String id) async {
    return _systemClient.disableInterface(id);
  }

  /// Monitor interface traffic
  Future<Map<String, String>> monitorTraffic(String interfaceName) async {
    return _systemClient.monitorTraffic(interfaceName);
  }

  /// Get all IP addresses
  Future<List<Map<String, String>>> getIpAddresses() async {
    return _systemClient.getIpAddresses();
  }

  /// Add IP address
  Future<bool> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    return _systemClient.addIpAddress(
      address: address,
      interfaceName: interfaceName,
      comment: comment,
    );
  }

  /// Remove IP address
  Future<bool> removeIpAddress(String id) async {
    return _systemClient.removeIpAddress(id);
  }

  /// Get DHCP leases
  Future<List<Map<String, String>>> getDhcpLeases() async {
    return _systemClient.sendCommand(['/ip/dhcp-server/lease/print']);
  }

  /// Get IP pools
  Future<List<Map<String, String>>> getIpPools() async {
    return _systemClient.getIpPools();
  }

  /// Add IP pool
  Future<bool> addIpPool({
    required String name,
    required String ranges,
  }) async {
    return _systemClient.addIpPool(name: name, ranges: ranges);
  }

  /// Remove IP pool
  Future<bool> removeIpPool(String id) async {
    return _systemClient.removeIpPool(id);
  }

  // ==================== HOTSPOT CLIENT METHODS ====================
  // NOTE: All hotspot methods use _systemClient.sendCommand directly because
  // only _systemClient listens to the socket. The specialized clients don't work
  // with shared socket architecture.

  /// Check if hotspot package is enabled
  Future<bool> isHotspotPackageEnabled() async {
    try {
      final response = await _systemClient.sendCommand(['/system/package/print']);
      for (final package in response) {
        if (package['name'] == 'hotspot' || package['name'] == 'routeros') {
          return package['disabled'] != 'true';
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get all hotspot servers
  Future<List<Map<String, String>>> getHotspotServers() async {
    return _systemClient.sendCommand(['/ip/hotspot/print']);
  }

  /// Enable a hotspot server
  Future<bool> enableHotspotServer(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable a hotspot server
  Future<bool> disableHotspotServer(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot users
  Future<List<Map<String, String>>> getHotspotUsers() async {
    return _systemClient.sendCommand(['/ip/hotspot/user/print']);
  }

  /// Add hotspot user
  Future<bool> addHotspotUser({
    required String name,
    required String password,
    String? profile,
    String? comment,
    String? server,
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/add', '=name=$name', '=password=$password'];
      if (profile != null && profile.isNotEmpty) cmd.add('=profile=$profile');
      if (comment != null && comment.isNotEmpty) cmd.add('=comment=$comment');
      if (server != null && server.isNotEmpty) cmd.add('=server=$server');
      if (limitUptime != null && limitUptime.isNotEmpty) cmd.add('=limit-uptime=$limitUptime');
      if (limitBytesIn != null && limitBytesIn.isNotEmpty) cmd.add('=limit-bytes-in=$limitBytesIn');
      if (limitBytesOut != null && limitBytesOut.isNotEmpty) cmd.add('=limit-bytes-out=$limitBytesOut');
      if (limitBytesTotal != null && limitBytesTotal.isNotEmpty) cmd.add('=limit-bytes-total=$limitBytesTotal');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot user
  Future<bool> removeHotspotUser(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/user/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot active users
  Future<List<Map<String, String>>> getHotspotActiveUsers() async {
    return _systemClient.sendCommand(['/ip/hotspot/active/print']);
  }

  /// Get hotspot hosts
  Future<List<Map<String, String>>> getHotspotHosts() async {
    return _systemClient.sendCommand(['/ip/hotspot/host/print']);
  }

  /// Get hotspot IP bindings
  Future<List<Map<String, String>>> getHotspotIpBindings() async {
    return _systemClient.sendCommand(['/ip/hotspot/ip-binding/print']);
  }

  /// Add hotspot IP binding
  Future<bool> addHotspotIpBinding({
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String type = 'regular',
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/ip-binding/add', '=type=$type'];
      if (mac != null && mac.isNotEmpty) cmd.add('=mac-address=$mac');
      if (address != null && address.isNotEmpty) cmd.add('=address=$address');
      if (toAddress != null && toAddress.isNotEmpty) cmd.add('=to-address=$toAddress');
      if (server != null && server.isNotEmpty) cmd.add('=server=$server');
      if (comment != null && comment.isNotEmpty) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Edit hotspot IP binding
  Future<bool> editHotspotIpBinding({
    required String id,
    String? mac,
    String? address,
    String? toAddress,
    String? server,
    String? type,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/ip-binding/set', '=.id=$id'];
      if (mac != null) cmd.add('=mac-address=$mac');
      if (address != null) cmd.add('=address=$address');
      if (toAddress != null) cmd.add('=to-address=$toAddress');
      if (server != null) cmd.add('=server=$server');
      if (type != null) cmd.add('=type=$type');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot IP binding
  Future<bool> removeHotspotIpBinding(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/ip-binding/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable hotspot IP binding
  Future<bool> enableHotspotIpBinding(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/ip-binding/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable hotspot IP binding
  Future<bool> disableHotspotIpBinding(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/ip-binding/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get walled garden entries
  Future<List<Map<String, String>>> getWalledGarden() async {
    return _systemClient.sendCommand(['/ip/hotspot/walled-garden/print']);
  }

  /// Add walled garden entry
  Future<bool> addWalledGardenEntry({
    String? dstHost,
    String? dstPort,
    String? protocol,
    String? action = 'allow',
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/walled-garden/add', '=action=$action'];
      if (dstHost != null && dstHost.isNotEmpty) cmd.add('=dst-host=$dstHost');
      if (dstPort != null && dstPort.isNotEmpty) cmd.add('=dst-port=$dstPort');
      if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');
      if (comment != null && comment.isNotEmpty) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove walled garden entry
  Future<bool> removeWalledGardenEntry(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot user profiles
  Future<List<Map<String, String>>> getHotspotUserProfiles() async {
    return _systemClient.sendCommand(['/ip/hotspot/user/profile/print']);
  }

  /// Edit hotspot user
  Future<bool> editHotspotUser({
    required String id,
    String? name,
    String? password,
    String? profile,
    String? comment,
    String? server,
    String? limitUptime,
    String? limitBytesIn,
    String? limitBytesOut,
    String? limitBytesTotal,
  }) async {
    try {
      final cmd = ['/ip/hotspot/user/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (password != null) cmd.add('=password=$password');
      if (profile != null) cmd.add('=profile=$profile');
      if (comment != null) cmd.add('=comment=$comment');
      if (server != null) cmd.add('=server=$server');
      if (limitUptime != null) cmd.add('=limit-uptime=$limitUptime');
      if (limitBytesIn != null) cmd.add('=limit-bytes-in=$limitBytesIn');
      if (limitBytesOut != null) cmd.add('=limit-bytes-out=$limitBytesOut');
      if (limitBytesTotal != null) cmd.add('=limit-bytes-total=$limitBytesTotal');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable hotspot user
  Future<bool> enableHotspotUser(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/user/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable hotspot user
  Future<bool> disableHotspotUser(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/user/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset hotspot user counters
  Future<bool> resetHotspotUserCounters(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/user/reset-counters', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disconnect hotspot user
  Future<bool> disconnectHotspotUser(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/active/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot profiles (alias for getHotspotUserProfiles)
  Future<List<Map<String, String>>> getHotspotProfiles() async {
    return getHotspotUserProfiles();
  }

  /// Setup hotspot (basic configuration)
  Future<bool> setupHotspot({
    required String interface,
    String? addressPool,
    String? profile,
    String? name,
  }) async {
    try {
      final cmd = ['/ip/hotspot/setup', '=interface=$interface'];
      if (addressPool != null) cmd.add('=address-pool=$addressPool');
      if (profile != null) cmd.add('=profile=$profile');
      if (name != null) cmd.add('=name=$name');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot host
  Future<bool> removeHotspotHost(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/host/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Make hotspot host binding
  Future<bool> makeHotspotHostBinding({
    required String macAddress,
    String? type,
    String? address,
    String? toAddress,
    String? server,
  }) async {
    try {
      final cmd = ['/ip/hotspot/ip-binding/add', '=mac-address=$macAddress'];
      if (type != null) cmd.add('=type=$type');
      if (address != null) cmd.add('=address=$address');
      if (toAddress != null) cmd.add('=to-address=$toAddress');
      if (server != null) cmd.add('=server=$server');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add walled garden
  Future<bool> addWalledGarden({
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String? protocol,
    String? action,
    String? method,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/walled-garden/add'];
      if (server != null) cmd.add('=server=$server');
      if (srcAddress != null) cmd.add('=src-address=$srcAddress');
      if (dstAddress != null) cmd.add('=dst-address=$dstAddress');
      if (dstHost != null) cmd.add('=dst-host=$dstHost');
      if (dstPort != null) cmd.add('=dst-port=$dstPort');
      if (path != null) cmd.add('=path=$path');
      if (protocol != null) cmd.add('=protocol=$protocol');
      if (action != null) cmd.add('=action=$action');
      if (method != null) cmd.add('=method=$method');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Edit walled garden
  Future<bool> editWalledGarden({
    required String id,
    String? server,
    String? srcAddress,
    String? dstAddress,
    String? dstHost,
    String? dstPort,
    String? path,
    String? protocol,
    String? action,
    String? method,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/walled-garden/set', '=.id=$id'];
      if (server != null) cmd.add('=server=$server');
      if (srcAddress != null) cmd.add('=src-address=$srcAddress');
      if (dstAddress != null) cmd.add('=dst-address=$dstAddress');
      if (dstHost != null) cmd.add('=dst-host=$dstHost');
      if (dstPort != null) cmd.add('=dst-port=$dstPort');
      if (path != null) cmd.add('=path=$path');
      if (protocol != null) cmd.add('=protocol=$protocol');
      if (action != null) cmd.add('=action=$action');
      if (method != null) cmd.add('=method=$method');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove walled garden
  Future<bool> removeWalledGarden(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable walled garden
  Future<bool> enableWalledGarden(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/walled-garden/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable walled garden
  Future<bool> disableWalledGarden(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/walled-garden/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add hotspot profile
  Future<bool> addHotspotProfile({
    required String name,
    String? hotspotAddress,
    String? dnsName,
    String? htmlDirectory,
    int? rateLimit,
    String? httpCookieLifetime,
    String? httpProxy,
    String? smtpServer,
    String? loginBy,
    String? splitUserDomain,
    String? useRadius,
    String? radiusAccounting,
    String? radiusInterimUpdate,
    String? nasPortType,
    String? nasIdentifier,
    String? radiusLocationId,
    String? radiusLocationName,
    String? radiusCalledStationId,
    String? advertise,
    String? advertiseUrl,
    String? advertiseMacAddress,
    String? advertiseInterface,
    String? advertiseInterval,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/profile/add', '=name=$name'];
      if (hotspotAddress != null) cmd.add('=hotspot-address=$hotspotAddress');
      if (dnsName != null) cmd.add('=dns-name=$dnsName');
      if (htmlDirectory != null) cmd.add('=html-directory=$htmlDirectory');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (httpCookieLifetime != null) cmd.add('=http-cookie-lifetime=$httpCookieLifetime');
      if (httpProxy != null) cmd.add('=http-proxy=$httpProxy');
      if (smtpServer != null) cmd.add('=smtp-server=$smtpServer');
      if (loginBy != null) cmd.add('=login-by=$loginBy');
      if (splitUserDomain != null) cmd.add('=split-user-domain=$splitUserDomain');
      if (useRadius != null) cmd.add('=use-radius=$useRadius');
      if (radiusAccounting != null) cmd.add('=radius-accounting=$radiusAccounting');
      if (radiusInterimUpdate != null) cmd.add('=radius-interim-update=$radiusInterimUpdate');
      if (nasPortType != null) cmd.add('=nas-port-type=$nasPortType');
      if (nasIdentifier != null) cmd.add('=nas-identifier=$nasIdentifier');
      if (radiusLocationId != null) cmd.add('=radius-location-id=$radiusLocationId');
      if (radiusLocationName != null) cmd.add('=radius-location-name=$radiusLocationName');
      if (radiusCalledStationId != null) cmd.add('=radius-called-station-id=$radiusCalledStationId');
      if (advertise != null) cmd.add('=advertise=$advertise');
      if (advertiseUrl != null) cmd.add('=advertise-url=$advertiseUrl');
      if (advertiseMacAddress != null) cmd.add('=advertise-mac-address=$advertiseMacAddress');
      if (advertiseInterface != null) cmd.add('=advertise-interface=$advertiseInterface');
      if (advertiseInterval != null) cmd.add('=advertise-interval=$advertiseInterval');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Edit hotspot profile
  Future<bool> editHotspotProfile({
    required String id,
    String? name,
    String? hotspotAddress,
    String? dnsName,
    String? htmlDirectory,
    int? rateLimit,
    String? httpCookieLifetime,
    String? httpProxy,
    String? smtpServer,
    String? loginBy,
    String? splitUserDomain,
    String? useRadius,
    String? radiusAccounting,
    String? radiusInterimUpdate,
    String? nasPortType,
    String? nasIdentifier,
    String? radiusLocationId,
    String? radiusLocationName,
    String? radiusCalledStationId,
    String? advertise,
    String? advertiseUrl,
    String? advertiseMacAddress,
    String? advertiseInterface,
    String? advertiseInterval,
    String? comment,
  }) async {
    try {
      final cmd = ['/ip/hotspot/profile/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (hotspotAddress != null) cmd.add('=hotspot-address=$hotspotAddress');
      if (dnsName != null) cmd.add('=dns-name=$dnsName');
      if (htmlDirectory != null) cmd.add('=html-directory=$htmlDirectory');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (httpCookieLifetime != null) cmd.add('=http-cookie-lifetime=$httpCookieLifetime');
      if (httpProxy != null) cmd.add('=http-proxy=$httpProxy');
      if (smtpServer != null) cmd.add('=smtp-server=$smtpServer');
      if (loginBy != null) cmd.add('=login-by=$loginBy');
      if (splitUserDomain != null) cmd.add('=split-user-domain=$splitUserDomain');
      if (useRadius != null) cmd.add('=use-radius=$useRadius');
      if (radiusAccounting != null) cmd.add('=radius-accounting=$radiusAccounting');
      if (radiusInterimUpdate != null) cmd.add('=radius-interim-update=$radiusInterimUpdate');
      if (nasPortType != null) cmd.add('=nas-port-type=$nasPortType');
      if (nasIdentifier != null) cmd.add('=nas-identifier=$nasIdentifier');
      if (radiusLocationId != null) cmd.add('=radius-location-id=$radiusLocationId');
      if (radiusLocationName != null) cmd.add('=radius-location-name=$radiusLocationName');
      if (radiusCalledStationId != null) cmd.add('=radius-called-station-id=$radiusCalledStationId');
      if (advertise != null) cmd.add('=advertise=$advertise');
      if (advertiseUrl != null) cmd.add('=advertise-url=$advertiseUrl');
      if (advertiseMacAddress != null) cmd.add('=advertise-mac-address=$advertiseMacAddress');
      if (advertiseInterface != null) cmd.add('=advertise-interface=$advertiseInterface');
      if (advertiseInterval != null) cmd.add('=advertise-interval=$advertiseInterval');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot profile
  Future<bool> removeHotspotProfile(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/profile/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Add hotspot user profile
  Future<bool> addHotspotUserProfile({
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
      final cmd = ['/ip/hotspot/user/profile/add', '=name=$name'];
      if (sessionTimeout != null) cmd.add('=session-timeout=$sessionTimeout');
      if (idleTimeout != null) cmd.add('=idle-timeout=$idleTimeout');
      if (sharedUsers != null) cmd.add('=shared-users=$sharedUsers');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (keepaliveTimeout != null) cmd.add('=keepalive-timeout=$keepaliveTimeout');
      if (statusAutorefresh != null) cmd.add('=status-autorefresh=$statusAutorefresh');
      if (onLogin != null) cmd.add('=on-login=$onLogin');
      if (onLogout != null) cmd.add('=on-logout=$onLogout');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Edit hotspot user profile
  Future<bool> editHotspotUserProfile({
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
      final cmd = ['/ip/hotspot/user/profile/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (sessionTimeout != null) cmd.add('=session-timeout=$sessionTimeout');
      if (idleTimeout != null) cmd.add('=idle-timeout=$idleTimeout');
      if (sharedUsers != null) cmd.add('=shared-users=$sharedUsers');
      if (rateLimit != null) cmd.add('=rate-limit=$rateLimit');
      if (keepaliveTimeout != null) cmd.add('=keepalive-timeout=$keepaliveTimeout');
      if (statusAutorefresh != null) cmd.add('=status-autorefresh=$statusAutorefresh');
      if (onLogin != null) cmd.add('=on-login=$onLogin');
      if (onLogout != null) cmd.add('=on-logout=$onLogout');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot user profile
  Future<bool> removeHotspotUserProfile(String id) async {
    try {
      await _systemClient.sendCommand(['/ip/hotspot/user/profile/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset hotspot with selective deletion
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
      // Delete items in order to avoid dependency issues
      if (deleteUsers) {
        final users = await _systemClient.sendCommand(['/ip/hotspot/user/print']);
        for (final user in users) {
          if (user['.id'] != null) {
            await _systemClient.sendCommand(['/ip/hotspot/user/remove', '=.id=${user['.id']}']);
          }
        }
      }
      if (deleteIpBindings) {
        final bindings = await _systemClient.sendCommand(['/ip/hotspot/ip-binding/print']);
        for (final binding in bindings) {
          if (binding['.id'] != null) {
            await _systemClient.sendCommand(['/ip/hotspot/ip-binding/remove', '=.id=${binding['.id']}']);
          }
        }
      }
      if (deleteWalledGarden) {
        final entries = await _systemClient.sendCommand(['/ip/hotspot/walled-garden/print']);
        for (final entry in entries) {
          if (entry['.id'] != null) {
            await _systemClient.sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=${entry['.id']}']);
          }
        }
      }
      if (deleteServers) {
        final servers = await _systemClient.sendCommand(['/ip/hotspot/print']);
        for (final server in servers) {
          if (server['.id'] != null) {
            await _systemClient.sendCommand(['/ip/hotspot/remove', '=.id=${server['.id']}']);
          }
        }
      }
      if (deleteProfiles) {
        final profiles = await _systemClient.sendCommand(['/ip/hotspot/user/profile/print']);
        for (final profile in profiles) {
          if (profile['.id'] != null && profile['name'] != 'default') {
            await _systemClient.sendCommand(['/ip/hotspot/user/profile/remove', '=.id=${profile['.id']}']);
          }
        }
      }
      if (deleteServerProfiles) {
        final profiles = await _systemClient.sendCommand(['/ip/hotspot/profile/print']);
        for (final profile in profiles) {
          if (profile['.id'] != null && profile['name'] != 'default') {
            await _systemClient.sendCommand(['/ip/hotspot/profile/remove', '=.id=${profile['.id']}']);
          }
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== DIAGNOSTIC CLIENT METHODS ====================

  /// Ping a target host
  Future<List<Map<String, String>>> ping({
    required String target,
    int count = 4,
    int size = 56,
    int ttl = 64,
    String? srcAddress,
    Duration? timeout,
  }) async {
    final cmd = ['/ping', '=address=$target', '=count=$count', '=size=$size', '=ttl=$ttl'];
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    return _systemClient.sendCommand(cmd, timeout: timeout ?? Duration(seconds: 30));
  }

  /// Start ping stream
  Future<Stream<Map<String, String>>> startPing({
    required String target,
    int size = 56,
    int ttl = 64,
    String? srcAddress,
  }) async {
    final cmd = ['/ping', '=address=$target', '=size=$size', '=ttl=$ttl'];
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    return _systemClient.startStream(cmd);
  }

  /// Traceroute to target host
  Future<List<Map<String, String>>> traceroute({
    required String target,
    int? maxHops,
    int? size,
    int? timeout,
    String? srcAddress,
    int? port,
    String? protocol,
  }) async {
    final cmd = ['/tool/traceroute', '=address=$target'];
    if (maxHops != null) cmd.add('=max-hops=$maxHops');
    if (size != null) cmd.add('=size=$size');
    if (timeout != null) cmd.add('=timeout=${timeout}ms');
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    if (port != null) cmd.add('=port=$port');
    if (protocol != null) cmd.add('=protocol=$protocol');
    return _systemClient.sendCommand(cmd, timeout: Duration(seconds: 60));
  }

  /// Start traceroute stream
  Future<Stream<Map<String, String>>> startTraceroute({
    required String target,
    int? maxHops,
    int? size,
    int? timeout,
    String? srcAddress,
    int? port,
    String? protocol,
  }) async {
    final cmd = ['/tool/traceroute', '=address=$target'];
    if (maxHops != null) cmd.add('=max-hops=$maxHops');
    if (size != null) cmd.add('=size=$size');
    if (timeout != null) cmd.add('=timeout=${timeout}ms');
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    if (port != null) cmd.add('=port=$port');
    if (protocol != null) cmd.add('=protocol=$protocol');
    return _systemClient.startStream(cmd);
  }

  /// DNS lookup
  Future<List<Map<String, String>>> dnsLookup({
    required String name,
    String? server,
    String? type,
  }) async {
    final cmd = ['/put', '[:resolve $name]'];
    return _systemClient.sendCommand(cmd);
  }

  /// Bandwidth test
  Future<List<Map<String, String>>> bandwidthTest({
    required String address,
    int? duration,
    String? direction,
    String? protocol,
    int? localTxSpeed,
    int? remoteTxSpeed,
    String? localUdpTxSize,
    String? remoteUdpTxSize,
    String? user,
    String? password,
  }) async {
    final cmd = ['/tool/bandwidth-test', '=address=$address'];
    if (duration != null) cmd.add('=duration=$duration');
    if (direction != null) cmd.add('=direction=$direction');
    if (protocol != null) cmd.add('=protocol=$protocol');
    if (localTxSpeed != null) cmd.add('=local-tx-speed=$localTxSpeed');
    if (remoteTxSpeed != null) cmd.add('=remote-tx-speed=$remoteTxSpeed');
    if (localUdpTxSize != null) cmd.add('=local-udp-tx-size=$localUdpTxSize');
    if (remoteUdpTxSize != null) cmd.add('=remote-udp-tx-size=$remoteUdpTxSize');
    if (user != null) cmd.add('=user=$user');
    if (password != null) cmd.add('=password=$password');
    return _systemClient.sendCommand(cmd, timeout: Duration(seconds: duration ?? 10 + 5));
  }

  /// Start bandwidth test stream
  Future<Stream<Map<String, String>>> startBandwidthTest({
    required String address,
    int? duration,
    String? direction,
    String? protocol,
    int? localTxSpeed,
    int? remoteTxSpeed,
    String? localUdpTxSize,
    String? remoteUdpTxSize,
    String? user,
    String? password,
  }) async {
    final cmd = ['/tool/bandwidth-test', '=address=$address'];
    if (duration != null) cmd.add('=duration=$duration');
    if (direction != null) cmd.add('=direction=$direction');
    if (protocol != null) cmd.add('=protocol=$protocol');
    if (localTxSpeed != null) cmd.add('=local-tx-speed=$localTxSpeed');
    if (remoteTxSpeed != null) cmd.add('=remote-tx-speed=$remoteTxSpeed');
    if (localUdpTxSize != null) cmd.add('=local-udp-tx-size=$localUdpTxSize');
    if (remoteUdpTxSize != null) cmd.add('=remote-udp-tx-size=$remoteUdpTxSize');
    if (user != null) cmd.add('=user=$user');
    if (password != null) cmd.add('=password=$password');
    return _systemClient.startStream(cmd);
  }

  /// Torch (packet sniffer)
  Future<Stream<Map<String, String>>> startTorch({
    String? interface,
    String? srcAddress,
    String? dstAddress,
    String? srcPort,
    String? dstPort,
    String? protocol,
    int? port,
    String? filter,
  }) async {
    final cmd = ['/tool/torch'];
    if (interface != null) cmd.add('=interface=$interface');
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    if (dstAddress != null) cmd.add('=dst-address=$dstAddress');
    if (srcPort != null) cmd.add('=src-port=$srcPort');
    if (dstPort != null) cmd.add('=dst-port=$dstPort');
    if (protocol != null) cmd.add('=protocol=$protocol');
    if (port != null) cmd.add('=port=$port');
    return _systemClient.startStream(cmd);
  }

  // ==================== BACKUP CLIENT METHODS ====================

  /// Get all available backups
  Future<List<Map<String, String>>> getBackups() async {
    return _systemClient.sendCommand(['/file/print', '?type=backup']);
  }

  /// Create a new backup
  Future<bool> createBackup({
    required String name,
    String? password,
    bool dontEncrypt = true,
  }) async {
    try {
      final cmd = ['/system/backup/save', '=name=$name'];
      if (password != null && !dontEncrypt) cmd.add('=password=$password');
      if (dontEncrypt) cmd.add('=dont-encrypt=yes');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a backup
  Future<bool> deleteBackup(String name) async {
    try {
      await _systemClient.sendCommand(['/file/remove', '=$name']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restore from backup
  Future<bool> restoreBackup(String name) async {
    try {
      await _systemClient.sendCommand(['/system/backup/load', '=name=$name']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== LOGS CLIENT METHODS ====================

  /// Get system logs
  Future<List<Map<String, String>>> getLogs({
    String? topics,
    String? since,
    String? until,
    int? count,
  }) async {
    final cmd = ['/log/print'];
    if (topics != null) cmd.add('?topics~$topics');
    if (count != null) cmd.add('=count=$count');
    return _systemClient.sendCommand(cmd);
  }

  /// Start following logs (streaming)
  Future<Stream<Map<String, String>>> followLogs({
    String? topics,
    bool follow = true,
  }) async {
    final cmd = ['/log/print', '=follow=yes'];
    if (topics != null) cmd.add('?topics~$topics');
    return _systemClient.startStream(cmd);
  }

  /// Stop streaming logs
  Future<void> stopStreaming() async {
    // For now, just close the connection which will stop all streams
    // TODO: Implement proper stream stopping in RouterOSBaseClient
    try {
      await disconnect();
    } catch (e) {
      // Ignore errors when disconnecting
    }
  }

  /// Start ping stream
  Future<Stream<Map<String, String>>> pingStream({
    required String address,
    int count = 100,
    int interval = 1,
    int? size,
    int? ttl,
    String? srcAddress,
    String? interfaceName,
    bool doNotFragment = false,
  }) async {
    final cmd = ['/ping', '=address=$address', '=count=$count', '=interval=$interval'];
    if (size != null) cmd.add('=size=$size');
    if (ttl != null) cmd.add('=ttl=$ttl');
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    if (interfaceName != null) cmd.add('=interface=$interfaceName');
    if (doNotFragment) cmd.add('=do-not-fragment=yes');
    return _systemClient.startStream(cmd);
  }

  /// Start traceroute stream
  Future<Stream<Map<String, String>>> tracerouteStream({
    required String address,
    int? maxHops,
    int? size,
    int? timeout,
    String? srcAddress,
    int? port,
    String? protocol,
  }) async {
    final cmd = ['/tool/traceroute', '=address=$address'];
    if (maxHops != null) cmd.add('=max-hops=$maxHops');
    if (size != null) cmd.add('=size=$size');
    if (timeout != null) cmd.add('=timeout=${timeout}ms');
    if (srcAddress != null) cmd.add('=src-address=$srcAddress');
    if (port != null) cmd.add('=port=$port');
    if (protocol != null) cmd.add('=protocol=$protocol');
    return _systemClient.startStream(cmd);
  }

  /// Clear logs
  Future<bool> clearLogs() async {
    try {
      // RouterOS doesn't have a direct clear logs command
      // This is typically done by removing log entries
      await _systemClient.sendCommand(['/log/print', '=detail']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== QUEUES CLIENT METHODS ====================

  /// Get all simple queues
  Future<List<Map<String, String>>> getSimpleQueues() async {
    return _systemClient.sendCommand(['/queue/simple/print']);
  }

  /// Add a simple queue
  Future<bool> addSimpleQueue({
    required String name,
    required String target,
    String? maxLimit,
    String? limitAt,
    int? queue,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/queue/simple/add', '=name=$name', '=target=$target'];
      if (maxLimit != null) cmd.add('=max-limit=$maxLimit');
      if (limitAt != null) cmd.add('=limit-at=$limitAt');
      if (queue != null) cmd.add('=queue=$queue');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update a simple queue
  Future<bool> updateSimpleQueue({
    required String id,
    String? name,
    String? target,
    String? maxLimit,
    String? limitAt,
    int? queue,
    String? comment,
    bool? disabled,
  }) async {
    try {
      final cmd = ['/queue/simple/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (target != null) cmd.add('=target=$target');
      if (maxLimit != null) cmd.add('=max-limit=$maxLimit');
      if (limitAt != null) cmd.add('=limit-at=$limitAt');
      if (queue != null) cmd.add('=queue=$queue');
      if (comment != null) cmd.add('=comment=$comment');
      if (disabled != null) cmd.add('=disabled=${disabled ? 'yes' : 'no'}');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a simple queue
  Future<bool> deleteSimpleQueue(String id) async {
    try {
      await _systemClient.sendCommand(['/queue/simple/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Enable a simple queue
  Future<bool> enableSimpleQueue(String id) async {
    try {
      await _systemClient.sendCommand(['/queue/simple/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable a simple queue
  Future<bool> disableSimpleQueue(String id) async {
    try {
      await _systemClient.sendCommand(['/queue/simple/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== WIRELESS CLIENT METHODS ====================

  /// Get wireless interfaces
  Future<List<Map<String, String>>> getWirelessInterfaces() async {
    return _systemClient.sendCommand(['/interface/wireless/print']);
  }

  /// Enable wireless interface
  Future<bool> enableWirelessInterface(String id) async {
    try {
      await _systemClient.sendCommand(['/interface/wireless/enable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disable wireless interface
  Future<bool> disableWirelessInterface(String id) async {
    try {
      await _systemClient.sendCommand(['/interface/wireless/disable', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get wireless registrations
  Future<List<Map<String, String>>> getWirelessRegistrations({
    String? interface,
  }) async {
    final cmd = ['/interface/wireless/registration-table/print'];
    if (interface != null) cmd.add('?interface=$interface');
    return _systemClient.sendCommand(cmd);
  }

  /// Disconnect wireless client
  Future<bool> disconnectWirelessClient({
    required String interface,
    required String macAddress,
  }) async {
    try {
      // Find the registration entry and remove it
      final regs = await _systemClient.sendCommand([
        '/interface/wireless/registration-table/print',
        '?interface=$interface',
        '?mac-address=$macAddress'
      ]);
      for (final reg in regs) {
        if (reg['.id'] != null) {
          await _systemClient.sendCommand(['/interface/wireless/registration-table/remove', '=.id=${reg['.id']}']);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get wireless security profiles
  Future<List<Map<String, String>>> getWirelessSecurityProfiles() async {
    return _systemClient.sendCommand(['/interface/wireless/security-profiles/print']);
  }

  /// Create wireless security profile
  Future<bool> createWirelessSecurityProfile({
    required String name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? supplicantIdentity,
    String? eapMethods,
    String? tlsCertificate,
    String? tlsMode,
    String? comment,
  }) async {
    try {
      final cmd = ['/interface/wireless/security-profiles/add', '=name=$name'];
      if (authenticationTypes != null) cmd.add('=authentication-types=$authenticationTypes');
      if (unicastCiphers != null) cmd.add('=unicast-ciphers=$unicastCiphers');
      if (groupCiphers != null) cmd.add('=group-ciphers=$groupCiphers');
      if (wpaPreSharedKey != null) cmd.add('=wpa-pre-shared-key=$wpaPreSharedKey');
      if (wpa2PreSharedKey != null) cmd.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
      if (supplicantIdentity != null) cmd.add('=supplicant-identity=$supplicantIdentity');
      if (eapMethods != null) cmd.add('=eap-methods=$eapMethods');
      if (tlsCertificate != null) cmd.add('=tls-certificate=$tlsCertificate');
      if (tlsMode != null) cmd.add('=tls-mode=$tlsMode');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update wireless security profile
  Future<bool> updateWirelessSecurityProfile({
    required String id,
    String? name,
    String? authenticationTypes,
    String? unicastCiphers,
    String? groupCiphers,
    String? wpaPreSharedKey,
    String? wpa2PreSharedKey,
    String? supplicantIdentity,
    String? eapMethods,
    String? tlsCertificate,
    String? tlsMode,
    String? comment,
  }) async {
    try {
      final cmd = ['/interface/wireless/security-profiles/set', '=.id=$id'];
      if (name != null) cmd.add('=name=$name');
      if (authenticationTypes != null) cmd.add('=authentication-types=$authenticationTypes');
      if (unicastCiphers != null) cmd.add('=unicast-ciphers=$unicastCiphers');
      if (groupCiphers != null) cmd.add('=group-ciphers=$groupCiphers');
      if (wpaPreSharedKey != null) cmd.add('=wpa-pre-shared-key=$wpaPreSharedKey');
      if (wpa2PreSharedKey != null) cmd.add('=wpa2-pre-shared-key=$wpa2PreSharedKey');
      if (supplicantIdentity != null) cmd.add('=supplicant-identity=$supplicantIdentity');
      if (eapMethods != null) cmd.add('=eap-methods=$eapMethods');
      if (tlsCertificate != null) cmd.add('=tls-certificate=$tlsCertificate');
      if (tlsMode != null) cmd.add('=tls-mode=$tlsMode');
      if (comment != null) cmd.add('=comment=$comment');
      await _systemClient.sendCommand(cmd);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete wireless security profile
  Future<bool> deleteWirelessSecurityProfile(String id) async {
    try {
      await _systemClient.sendCommand(['/interface/wireless/security-profiles/remove', '=.id=$id']);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== DHCP METHODS ====================

  /// Get DHCP servers
  Future<List<Map<String, String>>> getDhcpServers() async {
    return _systemClient.sendCommand(['/ip/dhcp-server/print']);
  }

  /// Add DHCP server
  Future<bool> addDhcpServer({
    required String name,
    required String interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    final words = ['/ip/dhcp-server/add', '=name=$name', '=interface=$interface'];
    if (addressPool != null) words.add('=address-pool=$addressPool');
    if (leaseTime != null) words.add('=lease-time=$leaseTime');
    if (authoritative != null) words.add('=authoritative=${authoritative ? 'yes' : 'no'}');

    final result = await _systemClient.sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Edit DHCP server
  Future<bool> editDhcpServer({
    required String id,
    String? name,
    String? interface,
    String? addressPool,
    String? leaseTime,
    bool? authoritative,
  }) async {
    final words = ['/ip/dhcp-server/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (interface != null) words.add('=interface=$interface');
    if (addressPool != null) words.add('=address-pool=$addressPool');
    if (leaseTime != null) words.add('=lease-time=$leaseTime');
    if (authoritative != null) words.add('=authoritative=${authoritative ? 'yes' : 'no'}');

    final result = await _systemClient.sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP server
  Future<bool> removeDhcpServer(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable DHCP server
  Future<bool> enableDhcpServer(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable DHCP server
  Future<bool> disableDhcpServer(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Get DHCP networks
  Future<List<Map<String, String>>> getDhcpNetworks() async {
    return _systemClient.sendCommand(['/ip/dhcp-server/network/print']);
  }

  /// Add DHCP network
  Future<bool> addDhcpNetwork({
    required String address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    final words = ['/ip/dhcp-server/network/add', '=address=$address'];
    if (gateway != null) words.add('=gateway=$gateway');
    if (netmask != null) words.add('=netmask=$netmask');
    if (dnsServer != null) words.add('=dns-server=$dnsServer');
    if (domain != null) words.add('=domain=$domain');
    if (comment != null) words.add('=comment=$comment');

    final result = await _systemClient.sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Edit DHCP network
  Future<bool> editDhcpNetwork({
    required String id,
    String? address,
    String? gateway,
    String? netmask,
    String? dnsServer,
    String? domain,
    String? comment,
  }) async {
    final words = ['/ip/dhcp-server/network/set', '=.id=$id'];
    if (address != null) words.add('=address=$address');
    if (gateway != null) words.add('=gateway=$gateway');
    if (netmask != null) words.add('=netmask=$netmask');
    if (dnsServer != null) words.add('=dns-server=$dnsServer');
    if (domain != null) words.add('=domain=$domain');
    if (comment != null) words.add('=comment=$comment');

    final result = await _systemClient.sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP network
  Future<bool> removeDhcpNetwork(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/network/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Add DHCP lease
  Future<bool> addDhcpLease({
    required String address,
    required String macAddress,
    String? server,
    String? comment,
  }) async {
    final words = [
      '/ip/dhcp-server/lease/add',
      '=address=$address',
      '=mac-address=$macAddress',
    ];
    if (server != null) words.add('=server=$server');
    if (comment != null) words.add('=comment=$comment');

    final result = await _systemClient.sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP lease
  Future<bool> removeDhcpLease(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/lease/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Make lease static
  Future<bool> makeDhcpLeaseStatic(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/lease/make-static', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable DHCP lease
  Future<bool> enableDhcpLease(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/lease/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable DHCP lease
  Future<bool> disableDhcpLease(String id) async {
    final result = await _systemClient.sendCommand(['/ip/dhcp-server/lease/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  // ==================== LEGACY METHODS (DEPRECATED) ====================
  // These methods are kept for backward compatibility but delegate to the new clients

  /// Send a command and wait for response (legacy method)
  @Deprecated('Use specialized client methods instead. This method will be removed in a future version.')
  Future<List<Map<String, String>>> sendCommand(
    List<String> words, {
    Duration? timeout,
  }) async {
    return _systemClient.sendCommand(words, timeout: timeout);
  }

  /// Start streaming command (legacy method)
  @Deprecated('Use specialized client methods instead. This method will be removed in a future version.')
  Future<Stream<Map<String, String>>> startStream(List<String> words) async {
    return _systemClient.startStream(words);
  }

  /// Stop streaming command (legacy method)
  @Deprecated('Use specialized client methods instead. This method will be removed in a future version.')
  Future<void> stopStream(String tag) async {
    await _systemClient.stopStream(tag);
  }
}
