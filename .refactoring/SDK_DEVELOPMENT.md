# SDK Development Guide

## Overview
This guide explains when and how to create reusable SDKs for vendor-specific functionality that can be shared across multiple modules or protocols.

## What is an SDK?

An SDK (Software Development Kit) in this context is a reusable library that provides:
- Multiple protocol implementations for a vendor
- Unified interface for device management
- Shared models and utilities
- Protocol-agnostic business logic

## When to Create an SDK

### Create an SDK when:

1. **Multiple Protocols Needed**
   - Device supports SNMP, NETCONF, RESTCONF, SSH/CLI
   - Example: Cisco devices (SNMP + NETCONF + RESTCONF + SSH)

2. **Shared Across Modules**
   - Multiple modules will use the same functionality
   - Example: SNMP protocol (used by general, Cisco, Microsoft, etc.)

3. **Complex Vendor Logic**
   - Vendor has proprietary data formats
   - Custom parsers or transformers needed
   - Example: Cisco IOS command parsing

4. **Third-Party API Integration**
   - External API with multiple endpoints
   - Example: VMware vSphere API

### Don't Create SDK when:
- ❌ Single protocol only (put in module)
- ❌ One-time use functionality
- ❌ Simple HTTP REST API (use repository pattern)

## SDK Structure

### Basic SDK Structure

```
lib/sdks/VENDOR_NAME/
├── VENDOR_sdk.dart              ← Main SDK interface
├── protocols/                    ← Protocol implementations
│   ├── protocol1/
│   │   ├── client.dart
│   │   └── models.dart
│   ├── protocol2/
│   │   ├── client.dart
│   │   └── models.dart
│   └── protocol3/
│       ├── client.dart
│       └── models.dart
├── models/                       ← Shared data models
│   ├── device_model.dart
│   ├── interface_model.dart
│   └── ...
└── utils/                        ← Helper utilities
    ├── parser.dart
    └── validator.dart
```

## Example: Cisco Multi-Protocol SDK

### Use Case
Cisco devices support multiple management protocols:
- SNMP (monitoring)
- NETCONF (configuration via XML)
- RESTCONF (configuration via REST API)
- SSH/CLI (command-line interface)

Different modules might prefer different protocols based on:
- Device capabilities
- User preferences
- Network constraints

### SDK Implementation

#### Main SDK Interface

```dart
// lib/sdks/cisco/cisco_sdk.dart

import 'protocols/snmp/cisco_snmp_client.dart';
import 'protocols/netconf/cisco_netconf_client.dart';
import 'protocols/restconf/cisco_restconf_client.dart';
import 'protocols/ssh/cisco_cli_client.dart';
import 'models/cisco_device.dart';
import 'models/cisco_interface.dart';

/// Cisco Multi-Protocol SDK
/// 
/// Provides unified interface for Cisco device management
/// across multiple protocols (SNMP, NETCONF, RESTCONF, SSH/CLI).
class CiscoSDK {
  final String host;
  final int port;
  final String username;
  final String password;
  
  late CiscoSNMPClient? _snmpClient;
  late CiscoNetconfClient? _netconfClient;
  late CiscoRestconfClient? _restconfClient;
  late CiscoCLIClient? _cliClient;
  
  /// Preferred protocol for operations
  ProtocolPreference preference;
  
  CiscoSDK({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.preference = ProtocolPreference.auto,
  });
  
  /// Initialize and detect available protocols
  Future<void> init() async {
    // Try to initialize each protocol
    _snmpClient = await _tryInitSNMP();
    _netconfClient = await _tryInitNetconf();
    _restconfClient = await _tryInitRestconf();
    _cliClient = await _tryInitCLI();
    
    if (!hasAnyProtocol()) {
      throw Exception('No available protocols for device $host');
    }
  }
  
  /// Check if any protocol is available
  bool hasAnyProtocol() {
    return _snmpClient != null ||
           _netconfClient != null ||
           _restconfClient != null ||
           _cliClient != null;
  }
  
  /// Get device information using best available protocol
  Future<CiscoDevice> getDeviceInfo() async {
    switch (preference) {
      case ProtocolPreference.netconf:
        return await _getViaNetconf();
      case ProtocolPreference.restconf:
        return await _getViaRestconf();
      case ProtocolPreference.snmp:
        return await _getViaSNMP();
      case ProtocolPreference.cli:
        return await _getViaCLI();
      case ProtocolPreference.auto:
        return await _getViaAuto();
    }
  }
  
  /// Auto-select best protocol
  Future<CiscoDevice> _getViaAuto() async {
    // Priority: NETCONF > RESTCONF > SNMP > CLI
    if (_netconfClient != null) {
      return await _getViaNetconf();
    } else if (_restconfClient != null) {
      return await _getViaRestconf();
    } else if (_snmpClient != null) {
      return await _getViaSNMP();
    } else if (_cliClient != null) {
      return await _getViaCLI();
    }
    throw Exception('No available protocol');
  }
  
  /// Get interfaces using best available protocol
  Future<List<CiscoInterface>> getInterfaces() async {
    // Implementation similar to getDeviceInfo
  }
  
  /// Get VLAN information
  Future<List<CiscoVlan>> getVlans() async {
    // VLANs are best retrieved via NETCONF or CLI
    if (_netconfClient != null) {
      return await _netconfClient!.getVlans();
    } else if (_cliClient != null) {
      return await _cliClient!.getVlans();
    }
    throw Exception('NETCONF or CLI required for VLAN operations');
  }
  
  /// Configure interface (requires NETCONF, RESTCONF, or CLI)
  Future<void> configureInterface(
    String interfaceName,
    Map<String, dynamic> config,
  ) async {
    if (_netconfClient != null) {
      await _netconfClient!.configureInterface(interfaceName, config);
    } else if (_restconfClient != null) {
      await _restconfClient!.configureInterface(interfaceName, config);
    } else if (_cliClient != null) {
      await _cliClient!.configureInterface(interfaceName, config);
    } else {
      throw Exception('No configuration protocol available');
    }
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    await _snmpClient?.dispose();
    await _netconfClient?.dispose();
    await _restconfClient?.dispose();
    await _cliClient?.dispose();
  }
  
  // Private helper methods
  Future<CiscoSNMPClient?> _tryInitSNMP() async {
    try {
      final client = CiscoSNMPClient(host: host, community: 'public');
      await client.connect();
      return client;
    } catch (e) {
      return null;
    }
  }
  
  Future<CiscoDevice> _getViaNetconf() async {
    return await _netconfClient!.getDeviceInfo();
  }
  
  // ... other implementations
}

enum ProtocolPreference {
  auto,      // Auto-select best protocol
  netconf,   // Prefer NETCONF
  restconf,  // Prefer RESTCONF
  snmp,      // Prefer SNMP
  cli,       // Prefer SSH/CLI
}
```

#### Protocol Implementation: SNMP

```dart
// lib/sdks/cisco/protocols/snmp/cisco_snmp_client.dart

import 'dart:async';
import '../../../../core/protocols/snmp/snmp_client.dart';
import '../../models/cisco_device.dart';
import '../../models/cisco_interface.dart';
import 'cisco_mibs.dart';

class CiscoSNMPClient {
  final String host;
  final String community;
  final int port;
  
  late SNMPClient _snmpClient;
  
  CiscoSNMPClient({
    required this.host,
    required this.community,
    this.port = 161,
  });
  
  Future<void> connect() async {
    _snmpClient = SNMPClient(
      host: host,
      community: community,
      port: port,
    );
    await _snmpClient.connect();
  }
  
  Future<CiscoDevice> getDeviceInfo() async {
    // Get device info using Cisco-specific OIDs
    final hostname = await _snmpClient.get(CiscoMIBs.sysName);
    final model = await _snmpClient.get(CiscoMIBs.entPhysicalModelName);
    final serialNumber = await _snmpClient.get(CiscoMIBs.entPhysicalSerialNum);
    final iosVersion = await _snmpClient.get(CiscoMIBs.sysDescr);
    
    return CiscoDevice(
      hostname: hostname,
      model: model,
      serialNumber: serialNumber,
      iosVersion: _parseIOSVersion(iosVersion),
    );
  }
  
  Future<List<CiscoInterface>> getInterfaces() async {
    // Walk interface table
    final interfaces = await _snmpClient.walk(CiscoMIBs.ifTableBase);
    return interfaces.map((e) => _parseInterface(e)).toList();
  }
  
  String _parseIOSVersion(String sysDescr) {
    // Parse IOS version from sysDescr
    final regex = RegExp(r'Version (\S+)');
    final match = regex.firstMatch(sysDescr);
    return match?.group(1) ?? 'Unknown';
  }
  
  CiscoInterface _parseInterface(Map<String, dynamic> data) {
    // Parse interface data from SNMP result
    return CiscoInterface(
      name: data['ifDescr'],
      status: data['ifOperStatus'] == 1,
      speed: data['ifSpeed'],
    );
  }
  
  Future<void> dispose() async {
    await _snmpClient.disconnect();
  }
}
```

```dart
// lib/sdks/cisco/protocols/snmp/cisco_mibs.dart

class CiscoMIBs {
  // System information
  static const String sysName = '1.3.6.1.2.1.1.5.0';
  static const String sysDescr = '1.3.6.1.2.1.1.1.0';
  
  // Cisco Entity MIB
  static const String entPhysicalModelName = '1.3.6.1.2.1.47.1.1.1.1.13.1';
  static const String entPhysicalSerialNum = '1.3.6.1.2.1.47.1.1.1.1.11.1';
  
  // Interface MIB
  static const String ifTableBase = '1.3.6.1.2.1.2.2.1';
  
  // Cisco-specific OIDs
  static const String ciscoEnvMonTemperatureStatusValue = '1.3.6.1.4.1.9.9.13.1.3.1.3';
  static const String ciscoCPUUsage = '1.3.6.1.4.1.9.2.1.56.0';
}
```

#### Protocol Implementation: NETCONF

```dart
// lib/sdks/cisco/protocols/netconf/cisco_netconf_client.dart

import 'package:netconf/netconf.dart';
import '../../models/cisco_device.dart';
import '../../models/cisco_vlan.dart';

class CiscoNetconfClient {
  final String host;
  final String username;
  final String password;
  final int port;
  
  late NetconfClient _client;
  
  CiscoNetconfClient({
    required this.host,
    required this.username,
    required this.password,
    this.port = 830,
  });
  
  Future<void> connect() async {
    _client = NetconfClient(
      host: host,
      username: username,
      password: password,
      port: port,
    );
    await _client.connect();
  }
  
  Future<CiscoDevice> getDeviceInfo() async {
    final xml = '''
      <filter>
        <device-hardware-data xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-device-hardware-oper">
          <device-hardware/>
        </device-hardware-data>
      </filter>
    ''';
    
    final response = await _client.get(xml);
    return _parseDeviceInfo(response);
  }
  
  Future<List<CiscoVlan>> getVlans() async {
    final xml = '''
      <filter>
        <vlans xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-vlan-oper">
          <vlan/>
        </vlans>
      </filter>
    ''';
    
    final response = await _client.get(xml);
    return _parseVlans(response);
  }
  
  Future<void> configureInterface(
    String interfaceName,
    Map<String, dynamic> config,
  ) async {
    final xml = _buildInterfaceConfigXML(interfaceName, config);
    await _client.editConfig('running', xml);
  }
  
  CiscoDevice _parseDeviceInfo(String xml) {
    // Parse XML response and create CiscoDevice
  }
  
  List<CiscoVlan> _parseVlans(String xml) {
    // Parse XML response and create VLAN list
  }
  
  String _buildInterfaceConfigXML(String name, Map<String, dynamic> config) {
    // Build NETCONF XML for interface configuration
  }
  
  Future<void> dispose() async {
    await _client.disconnect();
  }
}
```

### Shared Models

```dart
// lib/sdks/cisco/models/cisco_device.dart

import 'package:equatable/equatable.dart';

class CiscoDevice extends Equatable {
  final String hostname;
  final String model;
  final String serialNumber;
  final String iosVersion;
  final DateTime? uptime;
  
  const CiscoDevice({
    required this.hostname,
    required this.model,
    required this.serialNumber,
    required this.iosVersion,
    this.uptime,
  });
  
  @override
  List<Object?> get props => [
    hostname,
    model,
    serialNumber,
    iosVersion,
    uptime,
  ];
}
```

## Using an SDK in a Module

### Example: Cisco Module Using Cisco SDK

```dart
// lib/modules/cisco/data/datasources/cisco_datasource.dart

import '../../../../sdks/cisco/cisco_sdk.dart';
import '../../../../sdks/cisco/models/cisco_device.dart';
import '../models/cisco_device_model.dart';

abstract class CiscoDataSource {
  Future<CiscoDeviceModel> getDeviceInfo();
}

class CiscoDataSourceImpl implements CiscoDataSource {
  final CiscoSDK sdk;
  
  CiscoDataSourceImpl({required this.sdk});
  
  @override
  Future<CiscoDeviceModel> getDeviceInfo() async {
    // Use SDK to fetch data
    final device = await sdk.getDeviceInfo();
    
    // Convert SDK model to data layer model
    return CiscoDeviceModel(
      hostname: device.hostname,
      model: device.model,
      serialNumber: device.serialNumber,
      iosVersion: device.iosVersion,
    );
  }
}
```

## SDK Best Practices

### DO:
- ✅ Provide protocol abstraction
- ✅ Auto-detect available protocols
- ✅ Fallback to alternative protocols
- ✅ Document protocol requirements
- ✅ Handle connection errors gracefully
- ✅ Implement proper cleanup (dispose)
- ✅ Use shared models
- ✅ Provide clear examples

### DON'T:
- ❌ Mix SDK logic with UI
- ❌ Hardcode credentials
- ❌ Ignore protocol limitations
- ❌ Leak resources
- ❌ Over-complicate simple use cases

## SDK Checklist

Before releasing an SDK:

- [ ] All protocols implemented
- [ ] Protocol auto-detection works
- [ ] Fallback mechanisms tested
- [ ] Models are immutable
- [ ] Error handling comprehensive
- [ ] Resource cleanup implemented
- [ ] Documentation complete
- [ ] Examples provided
- [ ] Unit tests written (>80% coverage)
- [ ] Integration tests with real devices
- [ ] Performance tested
- [ ] Memory leaks checked

## Example SDKs in Project

### Planned SDKs:

1. **Cisco SDK** (`sdks/cisco/`)
   - Protocols: SNMP, NETCONF, RESTCONF, SSH/CLI
   - Use case: Multi-protocol Cisco management

2. **SNMP Vendor Extensions** (`sdks/snmp_vendor_extensions/`)
   - Vendor-specific MIB definitions
   - Use case: Shared across SNMP-enabled modules

## References
- [NETCONF RFC 6241](https://www.rfc-editor.org/rfc/rfc6241)
- [RESTCONF RFC 8040](https://www.rfc-editor.org/rfc/rfc8040)
- [Cisco Yang Models](https://github.com/YangModels/yang)
- [SNMP Best Practices](https://www.cisco.com/c/en/us/support/docs/ip/simple-network-management-protocol-snmp/7244-snmp-best.html)
