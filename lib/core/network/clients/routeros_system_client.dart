import 'routeros_base_client.dart';

/// System and connection management client
class RouterOSSystemClient extends RouterOSBaseClient {
  RouterOSSystemClient({
    required super.host,
    required super.port,
    super.useSsl,
  });

  /// Get system resources
  Future<List<Map<String, String>>> getSystemResources() async {
    final response = await sendCommand(['/system/resource/print']);
    return _filterProtocolMessages(response);
  }

  /// Get all interfaces
  Future<List<Map<String, String>>> getInterfaces() async {
    final response = await sendCommand(['/interface/print']);
    return _filterProtocolMessages(response);
  }

  /// Enable an interface
  Future<bool> enableInterface(String id) async {
    try {
      final response = await sendCommand([
        '/interface/enable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Disable an interface
  Future<bool> disableInterface(String id) async {
    try {
      final response = await sendCommand([
        '/interface/disable',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Monitor interface traffic
  Future<Map<String, String>> monitorTraffic(String interfaceName) async {
    try {
      final response = await sendCommand(
        [
          '/interface/monitor-traffic',
          '=interface=$interfaceName',
          '=once=',
        ],
        timeout: const Duration(seconds: 5),
      );

      // Find the data response (not 'done' or 'trap')
      for (final item in response) {
        if (item['type'] != 'done' && item['type'] != 'trap') {
          return item;
        }
      }

      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Get all IP addresses
  Future<List<Map<String, String>>> getIpAddresses() async {
    final response = await sendCommand(['/ip/address/print']);
    return _filterProtocolMessages(response);
  }

  /// Add IP address
  Future<bool> addIpAddress({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    try {
      final List<String> cmd = [
        '/ip/address/add',
        '=address=$address',
        '=interface=$interfaceName',
      ];

      if (comment != null && comment.isNotEmpty) {
        cmd.add('=comment=$comment');
      }

      final response = await sendCommand(cmd);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove IP address
  Future<bool> removeIpAddress(String id) async {
    try {
      final response = await sendCommand([
        '/ip/address/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Get DHCP leases
  Future<List<Map<String, String>>> getDhcpLeases() async {
    final response = await sendCommand(['/ip/dhcp-server/lease/print']);
    return _filterProtocolMessages(response);
  }

  /// Get IP pools
  Future<List<Map<String, String>>> getIpPools() async {
    final response = await sendCommand(['/ip/pool/print']);
    return _filterProtocolMessages(response);
  }

  /// Add IP pool
  Future<bool> addIpPool({
    required String name,
    required String ranges,
  }) async {
    try {
      final response = await sendCommand([
        '/ip/pool/add',
        '=name=$name',
        '=ranges=$ranges',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  /// Remove IP pool
  Future<bool> removeIpPool(String id) async {
    try {
      final response = await sendCommand([
        '/ip/pool/remove',
        '=.id=$id',
      ]);
      return response.any((r) => r['type'] == 'done');
    } catch (e) {
      return false;
    }
  }

  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      return type != 'done' && type != 'trap' && type != 'fatal';
    }).toList();
  }
}