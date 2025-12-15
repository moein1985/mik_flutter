import 'dart:math';
import '../../features/dashboard/domain/entities/system_resource.dart';
import '../../features/dashboard/domain/entities/router_interface.dart';
import '../../features/dashboard/domain/entities/ip_address.dart';
import '../../features/dashboard/domain/entities/firewall_rule.dart';
import '../../features/dashboard/domain/entities/dhcp_lease.dart';

/// Generates realistic fake data for MikroTik router
/// 
/// Uses realistic interface names, IP addresses, and configurations
/// that match typical MikroTik setups
class FakeDataGenerator {
  static final _random = Random();
  
  // Realistic MikroTik interface names
  static const _interfaceNames = [
    'ether1',
    'ether2',
    'ether3',
    'ether4',
    'ether5',
    'wlan1',
    'wlan2',
    'bridge1',
    'pppoe-out1',
    'sfp1',
  ];
  
  // Realistic RouterOS versions
  static const _routerOsVersions = [
    '7.12.1 (stable)',
    '7.13 (stable)',
    '7.14 (stable)',
    '6.49.10 (long-term)',
  ];
  
  static const _boardNames = [
    'RB750Gr3',
    'RB4011iGS+',
    'RB2011UiAS-2HnD-IN',
    'RB3011UiAS-RM',
    'CCR1009-7G-1C-1S+',
    'hEX S',
    'hAP ac2',
    'CRS326-24G-2S+',
  ];
  
  static const _architectures = [
    'arm',
    'arm64',
    'mipsbe',
    'tile',
  ];
  
  /// Generate random system resources
  static SystemResource generateSystemResource() {
    final uptimeSeconds = _random.nextInt(30 * 24 * 60 * 60); // Up to 30 days
    final days = uptimeSeconds ~/ (24 * 60 * 60);
    final hours = (uptimeSeconds % (24 * 60 * 60)) ~/ (60 * 60);
    final minutes = (uptimeSeconds % (60 * 60)) ~/ 60;
    
    final totalMemory = 256 * 1024 * 1024; // 256MB
    final usedMemory = _random.nextInt(totalMemory ~/ 2);
    final freeMemory = totalMemory - usedMemory;
    
    final totalHdd = 128 * 1024 * 1024; // 128MB
    final usedHdd = _random.nextInt(totalHdd ~/ 3);
    final freeHdd = totalHdd - usedHdd;
    
    return SystemResource(
      uptime: '${days}d${hours}h${minutes}m',
      version: _routerOsVersions[_random.nextInt(_routerOsVersions.length)],
      cpuLoad: '${_random.nextInt(100)}%',
      freeMemory: freeMemory.toString(),
      totalMemory: totalMemory.toString(),
      freeHddSpace: freeHdd.toString(),
      totalHddSpace: totalHdd.toString(),
      architectureName: _architectures[_random.nextInt(_architectures.length)],
      boardName: _boardNames[_random.nextInt(_boardNames.length)],
      platform: 'MikroTik',
    );
  }
  
  /// Generate a list of router interfaces
  static List<RouterInterface> generateInterfaces({int count = 5}) {
    final interfaces = <RouterInterface>[];
    
    for (var i = 0; i < count && i < _interfaceNames.length; i++) {
      final name = _interfaceNames[i];
      final type = _getInterfaceType(name);
      final running = _random.nextDouble() > 0.2; // 80% running
      final disabled = _random.nextDouble() > 0.9; // 10% disabled
      
      interfaces.add(
        RouterInterface(
          id: '*${i + 1}',
          name: name,
          type: type,
          running: running && !disabled,
          disabled: disabled,
          comment: _random.nextDouble() > 0.7 ? _getInterfaceComment(name) : null,
          macAddress: _generateMacAddress(),
        ),
      );
    }
    
    return interfaces;
  }
  
  /// Generate a list of IP addresses
  static List<IpAddress> generateIpAddresses({int count = 6}) {
    final ipAddresses = <IpAddress>[];
    
    // Add typical LAN address
    ipAddresses.add(
      IpAddress(
        id: '*1',
        address: '192.168.88.1/24',
        network: '192.168.88.0',
        interfaceName: 'bridge1',
        disabled: false,
        invalid: false,
        dynamic: false,
        comment: 'LAN Network',
      ),
    );
    
    // Add WAN address (usually dynamic)
    ipAddresses.add(
      IpAddress(
        id: '*2',
        address: '${_random.nextInt(200) + 10}.${_random.nextInt(256)}.${_random.nextInt(256)}.${_random.nextInt(254) + 1}/24',
        network: '${_random.nextInt(200) + 10}.${_random.nextInt(256)}.${_random.nextInt(256)}.0',
        interfaceName: 'ether1',
        disabled: false,
        invalid: false,
        dynamic: true,
        comment: 'WAN IP',
      ),
    );
    
    // Add additional addresses
    for (var i = 2; i < count && i < _interfaceNames.length; i++) {
      ipAddresses.add(
        IpAddress(
          id: '*${i + 1}',
          address: '192.168.${i * 10}.1/24',
          network: '192.168.${i * 10}.0',
          interfaceName: _interfaceNames[i],
          disabled: _random.nextDouble() > 0.9,
          invalid: false,
          dynamic: false,
          comment: _random.nextDouble() > 0.5 ? 'Network $i' : null,
        ),
      );
    }
    
    return ipAddresses;
  }
  
  /// Generate a list of firewall rules
  static List<FirewallRule> generateFirewallRules({int count = 10}) {
    final rules = <FirewallRule>[];
    
    final chains = ['input', 'forward', 'output'];
    final actions = ['accept', 'drop', 'reject', 'fasttrack-connection'];
    final protocols = ['tcp', 'udp', 'icmp'];
    final commonPorts = ['80', '443', '22', '21', '8291', '8728', '3389'];
    
    for (var i = 0; i < count; i++) {
      final chain = chains[_random.nextInt(chains.length)];
      final action = actions[_random.nextInt(actions.length)];
      
      rules.add(
        FirewallRule(
          id: '*${i + 1}',
          chain: chain,
          action: action,
          disabled: _random.nextDouble() > 0.8,
          invalid: false,
          dynamic: false,
          srcAddress: _random.nextDouble() > 0.5 ? _generateIpRange() : null,
          dstAddress: _random.nextDouble() > 0.5 ? _generateIpRange() : null,
          protocol: _random.nextDouble() > 0.3 ? protocols[_random.nextInt(protocols.length)] : null,
          dstPort: _random.nextDouble() > 0.5 ? commonPorts[_random.nextInt(commonPorts.length)] : null,
          comment: _random.nextDouble() > 0.4 ? _getFirewallComment(action, chain) : null,
          bytes: _random.nextInt(1000000000),
          packets: _random.nextInt(1000000),
        ),
      );
    }
    
    return rules;
  }
  
  /// Generate a list of DHCP leases
  static List<DhcpLease> generateDhcpLeases({int count = 8}) {
    final leases = <DhcpLease>[];
    
    for (var i = 0; i < count; i++) {
      final address = '192.168.88.${i + 10}';
      final status = i % 3 == 0 ? 'bound' : 'waiting';
      leases.add(
        DhcpLease(
          id: '*${i + 1}',
          address: address,
          macAddress: _generateMacAddress(),
          hostName: _generateHostname(i),
          status: status,
          expiresAfter: status == 'bound' ? '${_random.nextInt(24)}h${_random.nextInt(60)}m' : null,
          comment: _random.nextDouble() > 0.7 ? 'Device ${i + 1}' : null,
          dynamic: true,
          disabled: false,
        ),
      );
    }
    
    return leases;
  }
  
  // Helper methods
  
  static String _getInterfaceType(String name) {
    if (name.startsWith('ether')) return 'ether';
    if (name.startsWith('wlan')) return 'wlan';
    if (name.startsWith('bridge')) return 'bridge';
    if (name.startsWith('pppoe')) return 'pppoe-client';
    if (name.startsWith('sfp')) return 'sfp';
    return 'ether';
  }
  
  static String _getInterfaceComment(String name) {
    if (name == 'ether1') return 'WAN';
    if (name == 'bridge1') return 'LAN Bridge';
    if (name.startsWith('wlan')) return 'Wireless Network';
    return 'Network Interface';
  }
  
  static String _generateMacAddress() {
    final parts = List.generate(6, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'));
    return parts.join(':').toUpperCase();
  }
  
  static String _generateIpRange() {
    final options = [
      '192.168.88.0/24',
      '10.0.0.0/8',
      '172.16.0.0/12',
      '0.0.0.0/0', // any
    ];
    return options[_random.nextInt(options.length)];
  }
  
  static String _getFirewallComment(String action, String chain) {
    if (action == 'accept' && chain == 'input') {
      return 'Allow established connections';
    }
    if (action == 'drop' && chain == 'input') {
      return 'Drop invalid packets';
    }
    if (action == 'fasttrack-connection') {
      return 'FastTrack for performance';
    }
    return '$action rule for $chain';
  }
  
  static String _generateHostname(int index) {
    final prefixes = ['PC', 'Laptop', 'Phone', 'Tablet', 'IoT', 'Server'];
    return '${prefixes[index % prefixes.length]}-${index + 1}';
  }
  
  /// Simulate random error for testing error handling
  static bool shouldSimulateError(double errorRate) {
    return _random.nextDouble() < errorRate;
  }
  
  /// Generate random delay for network simulation
  static Duration generateRandomDelay(Duration min, Duration max) {
    final minMs = min.inMilliseconds;
    final maxMs = max.inMilliseconds;
    final delayMs = minMs + _random.nextInt(maxMs - minMs);
    return Duration(milliseconds: delayMs);
  }
}
