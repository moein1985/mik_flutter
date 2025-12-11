import 'routeros_base_client.dart';

/// HotSpot management client
class RouterOSHotspotClient extends RouterOSBaseClient {
  RouterOSHotspotClient({
    required super.host,
    required super.port,
    super.useSsl,
  });

  /// Check if hotspot package is enabled
  Future<bool> isHotspotPackageEnabled() async {
    try {
      final response = await sendCommand(['/system/package/print']);
      final packages = _filterProtocolMessages(response);

      // Look for hotspot package
      for (final package in packages) {
        if (package['name'] == 'hotspot') {
          return package['disabled'] != 'true';
        }
      }

      // If hotspot package not found separately, check if it's part of routeros bundle
      // In newer RouterOS, hotspot is bundled with routeros package
      for (final package in packages) {
        if (package['name'] == 'routeros') {
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
    final response = await sendCommand(['/ip/hotspot/print']);
    return _filterProtocolMessages(response);
  }

  /// Enable a hotspot server
  Future<bool> enableHotspotServer(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable a hotspot server
  Future<bool> disableHotspotServer(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot users
  Future<List<Map<String, String>>> getHotspotUsers() async {
    final response = await sendCommand(['/ip/hotspot/user/print']);
    return _filterProtocolMessages(response);
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
      final List<String> cmd = [
        '/ip/hotspot/user/add',
        '=name=$name',
        '=password=$password',
      ];

      if (profile != null && profile.isNotEmpty) {
        cmd.add('=profile=$profile');
      }
      if (comment != null && comment.isNotEmpty) {
        cmd.add('=comment=$comment');
      }
      if (server != null && server.isNotEmpty) {
        cmd.add('=server=$server');
      }
      if (limitUptime != null && limitUptime.isNotEmpty) {
        cmd.add('=limit-uptime=$limitUptime');
      }
      if (limitBytesIn != null && limitBytesIn.isNotEmpty) {
        cmd.add('=limit-bytes-in=$limitBytesIn');
      }
      if (limitBytesOut != null && limitBytesOut.isNotEmpty) {
        cmd.add('=limit-bytes-out=$limitBytesOut');
      }
      if (limitBytesTotal != null && limitBytesTotal.isNotEmpty) {
        cmd.add('=limit-bytes-total=$limitBytesTotal');
      }

      final response = await sendCommand(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot user
  Future<bool> removeHotspotUser(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot active users
  Future<List<Map<String, String>>> getHotspotActiveUsers() async {
    final response = await sendCommand(['/ip/hotspot/active/print']);
    return _filterProtocolMessages(response);
  }

  /// Get hotspot hosts
  Future<List<Map<String, String>>> getHotspotHosts() async {
    final response = await sendCommand(['/ip/hotspot/host/print']);
    return _filterProtocolMessages(response);
  }

  /// Get hotspot IP bindings
  Future<List<Map<String, String>>> getHotspotIpBindings() async {
    final response = await sendCommand(['/ip/hotspot/ip-binding/print']);
    return _filterProtocolMessages(response);
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
      final commands = [
        '/ip/hotspot/ip-binding/add',
        '=type=$type',
      ];

      if (mac != null && mac.isNotEmpty) {
        commands.add('=mac-address=$mac');
      }
      if (address != null && address.isNotEmpty) {
        commands.add('=address=$address');
      }
      if (toAddress != null && toAddress.isNotEmpty) {
        commands.add('=to-address=$toAddress');
      }
      if (server != null && server.isNotEmpty) {
        commands.add('=server=$server');
      }
      if (comment != null && comment.isNotEmpty) {
        commands.add('=comment=$comment');
      }

      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
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
      final commands = [
        '/ip/hotspot/ip-binding/set',
        '=.id=$id',
      ];

      if (mac != null) commands.add('=mac-address=$mac');
      if (address != null) commands.add('=address=$address');
      if (toAddress != null) commands.add('=to-address=$toAddress');
      if (server != null) commands.add('=server=$server');
      if (type != null) commands.add('=type=$type');
      if (comment != null) commands.add('=comment=$comment');

      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot IP binding
  Future<bool> removeHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Enable hotspot IP binding
  Future<bool> enableHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable hotspot IP binding
  Future<bool> disableHotspotIpBinding(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/ip-binding/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get walled garden entries
  Future<List<Map<String, String>>> getWalledGarden() async {
    final response = await sendCommand(['/ip/hotspot/walled-garden/print']);
    return _filterProtocolMessages(response);
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
      final commands = [
        '/ip/hotspot/walled-garden/add',
        '=action=$action',
      ];

      if (dstHost != null && dstHost.isNotEmpty) {
        commands.add('=dst-host=$dstHost');
      }
      if (dstPort != null && dstPort.isNotEmpty) {
        commands.add('=dst-port=$dstPort');
      }
      if (protocol != null && protocol.isNotEmpty) {
        commands.add('=protocol=$protocol');
      }
      if (comment != null && comment.isNotEmpty) {
        commands.add('=comment=$comment');
      }

      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove walled garden entry
  Future<bool> removeWalledGardenEntry(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/walled-garden/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get hotspot user profiles
  Future<List<Map<String, String>>> getHotspotUserProfiles() async {
    final response = await sendCommand(['/ip/hotspot/user/profile/print']);
    return _filterProtocolMessages(response);
  }

  /// Add hotspot user profile
  Future<bool> addHotspotUserProfile({
    required String name,
    String? sessionTimeout,
    String? idleTimeout,
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? sharedUsers,
    String? rateLimit,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/profile/add',
        '=name=$name',
      ];

      if (sessionTimeout != null && sessionTimeout.isNotEmpty) {
        commands.add('=session-timeout=$sessionTimeout');
      }
      if (idleTimeout != null && idleTimeout.isNotEmpty) {
        commands.add('=idle-timeout=$idleTimeout');
      }
      if (keepaliveTimeout != null && keepaliveTimeout.isNotEmpty) {
        commands.add('=keepalive-timeout=$keepaliveTimeout');
      }
      if (statusAutorefresh != null && statusAutorefresh.isNotEmpty) {
        commands.add('=status-autorefresh=$statusAutorefresh');
      }
      if (sharedUsers != null && sharedUsers.isNotEmpty) {
        commands.add('=shared-users=$sharedUsers');
      }
      if (rateLimit != null && rateLimit.isNotEmpty) {
        commands.add('=rate-limit=$rateLimit');
      }
      if (onLogin != null && onLogin.isNotEmpty) {
        commands.add('=on-login=$onLogin');
      }
      if (onLogout != null && onLogout.isNotEmpty) {
        commands.add('=on-logout=$onLogout');
      }

      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove hotspot user profile
  Future<bool> removeHotspotUserProfile(String id) async {
    try {
      final response = await sendCommand([
        '/ip/hotspot/user/profile/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
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
    String? keepaliveTimeout,
    String? statusAutorefresh,
    String? sharedUsers,
    String? rateLimit,
    String? onLogin,
    String? onLogout,
  }) async {
    try {
      final commands = [
        '/ip/hotspot/user/profile/set',
        '=.id=$id',
      ];

      if (name != null && name.isNotEmpty) {
        commands.add('=name=$name');
      }
      if (sessionTimeout != null && sessionTimeout.isNotEmpty) {
        commands.add('=session-timeout=$sessionTimeout');
      }
      if (idleTimeout != null && idleTimeout.isNotEmpty) {
        commands.add('=idle-timeout=$idleTimeout');
      }
      if (keepaliveTimeout != null && keepaliveTimeout.isNotEmpty) {
        commands.add('=keepalive-timeout=$keepaliveTimeout');
      }
      if (statusAutorefresh != null && statusAutorefresh.isNotEmpty) {
        commands.add('=status-autorefresh=$statusAutorefresh');
      }
      if (sharedUsers != null && sharedUsers.isNotEmpty) {
        commands.add('=shared-users=$sharedUsers');
      }
      if (rateLimit != null && rateLimit.isNotEmpty) {
        commands.add('=rate-limit=$rateLimit');
      }
      if (onLogin != null && onLogin.isNotEmpty) {
        commands.add('=on-login=$onLogin');
      }
      if (onLogout != null && onLogout.isNotEmpty) {
        commands.add('=on-logout=$onLogout');
      }

      final response = await sendCommand(commands);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Reset hotspot configuration
  Future<bool> resetHotspotConfiguration() async {
    try {
      // Order matters! Delete in the correct order to avoid dependency errors
      // Also remove walled garden IP entries

      // Remove hotspot servers
      final servers = await getHotspotServers();
      for (final server in servers) {
        final id = server['.id'];
        if (id != null) {
          await sendCommand(['/ip/hotspot/remove', '=.id=$id']);
        }
      }

      // Remove walled garden entries
      final walledGarden = await getWalledGarden();
      for (final entry in walledGarden) {
        final id = entry['.id'];
        if (id != null) {
          await sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
        }
      }

      // Remove IP bindings
      final bindings = await getHotspotIpBindings();
      for (final binding in bindings) {
        final id = binding['.id'];
        if (id != null) {
          await sendCommand(['/ip/hotspot/ip-binding/remove', '=.id=$id']);
        }
      }

      // Remove user profiles (except default)
      final profiles = await getHotspotUserProfiles();
      for (final profile in profiles) {
        final name = profile['name'];
        if (name != null && name != 'default') {
          final id = profile['.id'];
          if (id != null) {
            await sendCommand(['/ip/hotspot/user/profile/remove', '=.id=$id']);
          }
        }
      }

      // Remove users (except default-trial)
      final users = await getHotspotUsers();
      for (final user in users) {
        final name = user['name'];
        if (name != null && name != 'default-trial') {
          final id = user['.id'];
          if (id != null) {
            await sendCommand(['/ip/hotspot/user/remove', '=.id=$id']);
          }
        }
      }

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
      // Order matters! Delete in the correct order to avoid dependency errors

      if (deleteServers) {
        // Remove hotspot servers
        final servers = await getHotspotServers();
        for (final server in servers) {
          final id = server['.id'];
          if (id != null) {
            await sendCommand(['/ip/hotspot/remove', '=.id=$id']);
          }
        }
      }

      if (deleteWalledGarden) {
        // Remove walled garden entries
        final walledGarden = await getWalledGarden();
        for (final entry in walledGarden) {
          final id = entry['.id'];
          if (id != null) {
            await sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
          }
        }
      }

      if (deleteIpBindings) {
        // Remove IP bindings
        final bindings = await getHotspotIpBindings();
        for (final binding in bindings) {
          final id = binding['.id'];
          if (id != null) {
            await sendCommand(['/ip/hotspot/ip-binding/remove', '=.id=$id']);
          }
        }
      }

      if (deleteProfiles) {
        // Remove user profiles (except default)
        final profiles = await getHotspotUserProfiles();
        for (final profile in profiles) {
          final name = profile['name'];
          if (name != null && name != 'default') {
            final id = profile['.id'];
            if (id != null) {
              await sendCommand(['/ip/hotspot/user/profile/remove', '=.id=$id']);
            }
          }
        }
      }

      if (deleteUsers) {
        // Remove users (except default-trial)
        final users = await getHotspotUsers();
        for (final user in users) {
          final name = user['name'];
          if (name != null && name != 'default-trial') {
            final id = user['.id'];
            if (id != null) {
              await sendCommand(['/ip/hotspot/user/remove', '=.id=$id']);
            }
          }
        }
      }

      // Note: deleteServerProfiles and deleteIpPools are not implemented yet
      // as they require additional logic

      return true;
    } catch (e) {
      return false;
    }
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
    final words = ['/ip/hotspot/user/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (password != null) words.add('=password=$password');
    if (profile != null) words.add('=profile=$profile');
    if (comment != null) words.add('=comment=$comment');
    if (server != null) words.add('=server=$server');
    if (limitUptime != null) words.add('=limit-uptime=$limitUptime');
    if (limitBytesIn != null) words.add('=limit-bytes-in=$limitBytesIn');
    if (limitBytesOut != null) words.add('=limit-bytes-out=$limitBytesOut');
    if (limitBytesTotal != null) words.add('=limit-bytes-total=$limitBytesTotal');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable hotspot user
  Future<bool> enableHotspotUser(String id) async {
    final result = await sendCommand(['/ip/hotspot/user/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable hotspot user
  Future<bool> disableHotspotUser(String id) async {
    final result = await sendCommand(['/ip/hotspot/user/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Reset hotspot user counters
  Future<bool> resetHotspotUserCounters(String id) async {
    final result = await sendCommand(['/ip/hotspot/user/reset-counters', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disconnect hotspot user
  Future<bool> disconnectHotspotUser(String id) async {
    final result = await sendCommand(['/ip/hotspot/active/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
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
    final words = ['/ip/hotspot/setup', '=interface=$interface'];
    if (addressPool != null) words.add('=address-pool=$addressPool');
    if (profile != null) words.add('=profile=$profile');
    if (name != null) words.add('=name=$name');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove hotspot host
  Future<bool> removeHotspotHost(String id) async {
    final result = await sendCommand(['/ip/hotspot/host/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Make hotspot host binding
  Future<bool> makeHotspotHostBinding({
    String? id,
    required String macAddress,
    String? type,
    String? address,
    String? toAddress,
    String? server,
  }) async {
    final words = ['/ip/hotspot/ip-binding/add', '=mac-address=$macAddress'];
    if (type != null) words.add('=type=$type');
    if (address != null) words.add('=address=$address');
    if (toAddress != null) words.add('=to-address=$toAddress');
    if (server != null) words.add('=server=$server');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
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
    final words = ['/ip/hotspot/walled-garden/add'];
    if (server != null) words.add('=server=$server');
    if (srcAddress != null) words.add('=src-address=$srcAddress');
    if (dstAddress != null) words.add('=dst-address=$dstAddress');
    if (dstHost != null) words.add('=dst-host=$dstHost');
    if (dstPort != null) words.add('=dst-port=$dstPort');
    if (path != null) words.add('=path=$path');
    if (protocol != null) words.add('=protocol=$protocol');
    if (action != null) words.add('=action=$action');
    if (method != null) words.add('=method=$method');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
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
    final words = ['/ip/hotspot/walled-garden/set', '=.id=$id'];
    if (server != null) words.add('=server=$server');
    if (srcAddress != null) words.add('=src-address=$srcAddress');
    if (dstAddress != null) words.add('=dst-address=$dstAddress');
    if (dstHost != null) words.add('=dst-host=$dstHost');
    if (dstPort != null) words.add('=dst-port=$dstPort');
    if (path != null) words.add('=path=$path');
    if (protocol != null) words.add('=protocol=$protocol');
    if (action != null) words.add('=action=$action');
    if (method != null) words.add('=method=$method');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove walled garden
  Future<bool> removeWalledGarden(String id) async {
    final result = await sendCommand(['/ip/hotspot/walled-garden/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable walled garden
  Future<bool> enableWalledGarden(String id) async {
    final result = await sendCommand(['/ip/hotspot/walled-garden/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable walled garden
  Future<bool> disableWalledGarden(String id) async {
    final result = await sendCommand(['/ip/hotspot/walled-garden/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
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
    final words = ['/ip/hotspot/profile/add', '=name=$name'];
    if (hotspotAddress != null) words.add('=hotspot-address=$hotspotAddress');
    if (dnsName != null) words.add('=dns-name=$dnsName');
    if (htmlDirectory != null) words.add('=html-directory=$htmlDirectory');
    if (rateLimit != null) words.add('=rate-limit=$rateLimit');
    if (httpCookieLifetime != null) words.add('=http-cookie-lifetime=$httpCookieLifetime');
    if (httpProxy != null) words.add('=http-proxy=$httpProxy');
    if (smtpServer != null) words.add('=smtp-server=$smtpServer');
    if (loginBy != null) words.add('=login-by=$loginBy');
    if (splitUserDomain != null) words.add('=split-user-domain=$splitUserDomain');
    if (useRadius != null) words.add('=use-radius=$useRadius');
    if (radiusAccounting != null) words.add('=radius-accounting=$radiusAccounting');
    if (radiusInterimUpdate != null) words.add('=radius-interim-update=$radiusInterimUpdate');
    if (nasPortType != null) words.add('=nas-port-type=$nasPortType');
    if (nasIdentifier != null) words.add('=nas-identifier=$nasIdentifier');
    if (radiusLocationId != null) words.add('=radius-location-id=$radiusLocationId');
    if (radiusLocationName != null) words.add('=radius-location-name=$radiusLocationName');
    if (radiusCalledStationId != null) words.add('=radius-called-station-id=$radiusCalledStationId');
    if (advertise != null) words.add('=advertise=$advertise');
    if (advertiseUrl != null) words.add('=advertise-url=$advertiseUrl');
    if (advertiseMacAddress != null) words.add('=advertise-mac-address=$advertiseMacAddress');
    if (advertiseInterface != null) words.add('=advertise-interface=$advertiseInterface');
    if (advertiseInterval != null) words.add('=advertise-interval=$advertiseInterval');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
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
    final words = ['/ip/hotspot/profile/set', '=.id=$id'];
    if (name != null) words.add('=name=$name');
    if (hotspotAddress != null) words.add('=hotspot-address=$hotspotAddress');
    if (dnsName != null) words.add('=dns-name=$dnsName');
    if (htmlDirectory != null) words.add('=html-directory=$htmlDirectory');
    if (rateLimit != null) words.add('=rate-limit=$rateLimit');
    if (httpCookieLifetime != null) words.add('=http-cookie-lifetime=$httpCookieLifetime');
    if (httpProxy != null) words.add('=http-proxy=$httpProxy');
    if (smtpServer != null) words.add('=smtp-server=$smtpServer');
    if (loginBy != null) words.add('=login-by=$loginBy');
    if (splitUserDomain != null) words.add('=split-user-domain=$splitUserDomain');
    if (useRadius != null) words.add('=use-radius=$useRadius');
    if (radiusAccounting != null) words.add('=radius-accounting=$radiusAccounting');
    if (radiusInterimUpdate != null) words.add('=radius-interim-update=$radiusInterimUpdate');
    if (nasPortType != null) words.add('=nas-port-type=$nasPortType');
    if (nasIdentifier != null) words.add('=nas-identifier=$nasIdentifier');
    if (radiusLocationId != null) words.add('=radius-location-id=$radiusLocationId');
    if (radiusLocationName != null) words.add('=radius-location-name=$radiusLocationName');
    if (radiusCalledStationId != null) words.add('=radius-called-station-id=$radiusCalledStationId');
    if (advertise != null) words.add('=advertise=$advertise');
    if (advertiseUrl != null) words.add('=advertise-url=$advertiseUrl');
    if (advertiseMacAddress != null) words.add('=advertise-mac-address=$advertiseMacAddress');
    if (advertiseInterface != null) words.add('=advertise-interface=$advertiseInterface');
    if (advertiseInterval != null) words.add('=advertise-interval=$advertiseInterval');
    if (comment != null) words.add('=comment=$comment');

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove hotspot profile
  Future<bool> removeHotspotProfile(String id) async {
    final result = await sendCommand(['/ip/hotspot/profile/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      return type != 'done' && type != 'trap' && type != 'fatal';
    }).toList();
  }
}