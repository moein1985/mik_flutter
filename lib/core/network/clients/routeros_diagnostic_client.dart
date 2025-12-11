import 'routeros_base_client.dart';

/// Diagnostic tools client (ping, traceroute, DNS lookup)
class RouterOSDiagnosticClient extends RouterOSBaseClient {
  RouterOSDiagnosticClient({
    required super.host,
    required super.port,
    super.useSsl,
  });

  /// Ping a target host
  Future<List<Map<String, String>>> ping({
    required String target,
    int count = 4,
    int size = 56,
    int ttl = 64,
    String? srcAddress,
    Duration? timeout,
  }) async {
    final List<String> cmd = [
      '/ping',
      '=address=$target',
      '=count=$count',
      '=size=$size',
      '=ttl=$ttl',
    ];

    if (srcAddress != null && srcAddress.isNotEmpty) {
      cmd.add('=src-address=$srcAddress');
    }

    final response = await sendCommand(cmd, timeout: timeout);
    return _filterProtocolMessages(response);
  }

  /// Start ping stream
  Future<Stream<Map<String, String>>> startPing({
    required String target,
    int size = 56,
    int ttl = 64,
    String? srcAddress,
  }) async {
    final List<String> cmd = [
      '/ping',
      '=address=$target',
      '=size=$size',
      '=ttl=$ttl',
    ];

    if (srcAddress != null && srcAddress.isNotEmpty) {
      cmd.add('=src-address=$srcAddress');
    }

    return startStream(cmd);
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
    final List<String> cmd = [
      '/tool/traceroute',
      '=address=$target',
    ];

    if (maxHops != null) cmd.add('=max-hops=$maxHops');
    if (size != null) cmd.add('=size=$size');
    if (timeout != null) cmd.add('=timeout=${timeout}ms');
    if (srcAddress != null && srcAddress.isNotEmpty) cmd.add('=src-address=$srcAddress');
    if (port != null) cmd.add('=port=$port');
    if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');

    final response = await sendCommand(cmd);
    return _filterProtocolMessages(response);
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
    final List<String> cmd = [
      '/tool/traceroute',
      '=address=$target',
    ];

    if (maxHops != null) cmd.add('=max-hops=$maxHops');
    if (size != null) cmd.add('=size=$size');
    if (timeout != null) cmd.add('=timeout=${timeout}ms');
    if (srcAddress != null && srcAddress.isNotEmpty) cmd.add('=src-address=$srcAddress');
    if (port != null) cmd.add('=port=$port');
    if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');

    return startStream(cmd);
  }

  /// DNS lookup
  Future<List<Map<String, String>>> dnsLookup({
    required String name,
    String? server,
    String? type,
  }) async {
    final List<String> cmd = [
      '/tool/dns-lookup',
      '=name=$name',
    ];

    if (server != null && server.isNotEmpty) cmd.add('=server=$server');
    if (type != null && type.isNotEmpty) cmd.add('=type=$type');

    final response = await sendCommand(cmd);
    return _filterProtocolMessages(response);
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
    final List<String> cmd = [
      '/tool/bandwidth-test',
      '=address=$address',
    ];

    if (duration != null) cmd.add('=duration=$duration');
    if (direction != null && direction.isNotEmpty) cmd.add('=direction=$direction');
    if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');
    if (localTxSpeed != null) cmd.add('=local-tx-speed=$localTxSpeed');
    if (remoteTxSpeed != null) cmd.add('=remote-tx-speed=$remoteTxSpeed');
    if (localUdpTxSize != null && localUdpTxSize.isNotEmpty) cmd.add('=local-udp-tx-size=$localUdpTxSize');
    if (remoteUdpTxSize != null && remoteUdpTxSize.isNotEmpty) cmd.add('=remote-udp-tx-size=$remoteUdpTxSize');
    if (user != null && user.isNotEmpty) cmd.add('=user=$user');
    if (password != null && password.isNotEmpty) cmd.add('=password=$password');

    final response = await sendCommand(cmd);
    return _filterProtocolMessages(response);
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
    final List<String> cmd = [
      '/tool/bandwidth-test',
      '=address=$address',
    ];

    if (duration != null) cmd.add('=duration=$duration');
    if (direction != null && direction.isNotEmpty) cmd.add('=direction=$direction');
    if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');
    if (localTxSpeed != null) cmd.add('=local-tx-speed=$localTxSpeed');
    if (remoteTxSpeed != null) cmd.add('=remote-tx-speed=$remoteTxSpeed');
    if (localUdpTxSize != null && localUdpTxSize.isNotEmpty) cmd.add('=local-udp-tx-size=$localUdpTxSize');
    if (remoteUdpTxSize != null && remoteUdpTxSize.isNotEmpty) cmd.add('=remote-udp-tx-size=$remoteUdpTxSize');
    if (user != null && user.isNotEmpty) cmd.add('=user=$user');
    if (password != null && password.isNotEmpty) cmd.add('=password=$password');

    return startStream(cmd);
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
    final List<String> cmd = ['/tool/torch'];

    if (interface != null && interface.isNotEmpty) cmd.add('=interface=$interface');
    if (srcAddress != null && srcAddress.isNotEmpty) cmd.add('=src-address=$srcAddress');
    if (dstAddress != null && dstAddress.isNotEmpty) cmd.add('=dst-address=$dstAddress');
    if (srcPort != null && srcPort.isNotEmpty) cmd.add('=src-port=$srcPort');
    if (dstPort != null && dstPort.isNotEmpty) cmd.add('=dst-port=$dstPort');
    if (protocol != null && protocol.isNotEmpty) cmd.add('=protocol=$protocol');
    if (port != null) cmd.add('=port=$port');
    if (filter != null && filter.isNotEmpty) cmd.add('=filter=$filter');

    return startStream(cmd);
  }

  List<Map<String, String>> _filterProtocolMessages(List<Map<String, String>> response) {
    return response.where((item) {
      final type = item['type'];
      return type != 'done' && type != 'trap' && type != 'fatal';
    }).toList();
  }
}