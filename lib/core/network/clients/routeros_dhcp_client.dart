import 'routeros_base_client.dart';

/// Specialized client for RouterOS DHCP operations
class RouterOSDhcpClient extends RouterOSBaseClient {
  RouterOSDhcpClient({
    required super.host,
    required super.port,
    required super.useSsl,
  });

  /// Get DHCP servers
  Future<List<Map<String, String>>> getDhcpServers() async {
    return sendCommand(['/ip/dhcp-server/print']);
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

    final result = await sendCommand(words);
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

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP server
  Future<bool> removeDhcpServer(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable DHCP server
  Future<bool> enableDhcpServer(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable DHCP server
  Future<bool> disableDhcpServer(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Get DHCP networks
  Future<List<Map<String, String>>> getDhcpNetworks() async {
    return sendCommand(['/ip/dhcp-server/network/print']);
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

    final result = await sendCommand(words);
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

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP network
  Future<bool> removeDhcpNetwork(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/network/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Get DHCP leases
  Future<List<Map<String, String>>> getDhcpLeases() async {
    return sendCommand(['/ip/dhcp-server/lease/print']);
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

    final result = await sendCommand(words);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Remove DHCP lease
  Future<bool> removeDhcpLease(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/lease/remove', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Make lease static
  Future<bool> makeDhcpLeaseStatic(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/lease/make-static', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Enable DHCP lease
  Future<bool> enableDhcpLease(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/lease/enable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }

  /// Disable DHCP lease
  Future<bool> disableDhcpLease(String id) async {
    final result = await sendCommand(['/ip/dhcp-server/lease/disable', '=.id=$id']);
    return result.isNotEmpty && result.first['ret'] == '';
  }
}