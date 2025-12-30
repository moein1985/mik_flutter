/// Cisco Enterprise SNMP MIB Extensions
/// 
/// Enterprise OID: 1.3.6.1.4.1.9 (Cisco Systems)
/// 
/// These OIDs are specific to Cisco networking devices and provide
/// detailed hardware, software, and environmental monitoring information.
/// 
/// Compatible with:
/// - Cisco IOS (12.x, 15.x)
/// - Cisco IOS-XE (16.x, 17.x)
/// - Cisco NX-OS
/// - Cisco IOS-XR
/// 
/// Reference: Cisco SNMP MIB Documentation
class CiscoMIB {
  /// Enterprise ID for Cisco Systems
  static const String enterpriseId = '1.3.6.1.4.1.9';

  // --- Hardware Information (ENTITY-MIB) ---
  
  /// Physical device model name
  static const String entPhysicalModelName = '1.3.6.1.2.1.47.1.1.1.1.13.1';
  
  /// Physical device serial number
  static const String entPhysicalSerialNum = '1.3.6.1.2.1.47.1.1.1.1.11.1';
  
  /// Software revision/version
  static const String entPhysicalSoftwareRev = '1.3.6.1.2.1.47.1.1.1.1.10.1';
  
  /// Hardware revision
  static const String entPhysicalHardwareRev = '1.3.6.1.2.1.47.1.1.1.1.8.1';
  
  /// Physical device description
  static const String entPhysicalDescr = '1.3.6.1.2.1.47.1.1.1.1.2.1';

  // --- IOS Version (CISCO-IMAGE-MIB) ---
  
  /// IOS version string
  static const String ciscoImageString = '1.3.6.1.4.1.9.9.25.1.1.1.2.2';

  // --- CPU Usage (CISCO-PROCESS-MIB) ---
  
  /// CPU utilization in last 5 seconds (%)
  static const String cpmCPUTotal5sec = '1.3.6.1.4.1.9.9.109.1.1.1.1.3.1';
  
  /// CPU utilization in last 1 minute (%)
  static const String cpmCPUTotal1min = '1.3.6.1.4.1.9.9.109.1.1.1.1.4.1';
  
  /// CPU utilization in last 5 minutes (%)
  static const String cpmCPUTotal5min = '1.3.6.1.4.1.9.9.109.1.1.1.1.5.1';

  // --- Memory Usage (CISCO-MEMORY-POOL-MIB) ---
  
  /// Memory pool name (e.g., "Processor", "I/O")
  static const String ciscoMemoryPoolName = '1.3.6.1.4.1.9.9.48.1.1.1.2.1';
  
  /// Memory pool used bytes
  static const String ciscoMemoryPoolUsed = '1.3.6.1.4.1.9.9.48.1.1.1.5.1';
  
  /// Memory pool free bytes
  static const String ciscoMemoryPoolFree = '1.3.6.1.4.1.9.9.48.1.1.1.6.1';

  // --- Environmental Monitoring (CISCO-ENVMON-MIB) ---
  
  // Temperature Sensors
  /// Temperature sensor description
  static const String ciscoEnvMonTemperatureStatusDescr = '1.3.6.1.4.1.9.9.13.1.3.1.2.1';
  
  /// Temperature value (Celsius)
  static const String ciscoEnvMonTemperatureStatusValue = '1.3.6.1.4.1.9.9.13.1.3.1.3.1';
  
  /// Temperature status (1=normal, 2=warning, 3=critical, 4=shutdown, 5=notPresent, 6=notFunctioning)
  static const String ciscoEnvMonTemperatureState = '1.3.6.1.4.1.9.9.13.1.3.1.6.1';
  
  // Fan Status
  /// Fan description
  static const String ciscoEnvMonFanStatusDescr = '1.3.6.1.4.1.9.9.13.1.4.1.2.1';
  
  /// Fan state (1=normal, 2=warning, 3=critical, 4=shutdown, 5=notPresent, 6=notFunctioning)
  static const String ciscoEnvMonFanState = '1.3.6.1.4.1.9.9.13.1.4.1.3.1';
  
  // Power Supply Status
  /// Power supply description
  static const String ciscoEnvMonSupplyStatusDescr = '1.3.6.1.4.1.9.9.13.1.5.1.2.1';
  
  /// Power supply state (1=normal, 2=warning, 3=critical, 4=shutdown, 5=notPresent, 6=notFunctioning)
  static const String ciscoEnvMonSupplyState = '1.3.6.1.4.1.9.9.13.1.5.1.3.1';
  
  /// Power supply source (1=unknown, 2=ac, 3=dc, 4=externalPowerSupply, 5=internalRedundant)
  static const String ciscoEnvMonSupplySource = '1.3.6.1.4.1.9.9.13.1.5.1.4.1';

  // --- PoE Information (CISCO-POWER-ETHERNET-EXT-MIB) ---
  
  /// PoE port enable status (Base OID + port index)
  static const String cpeExtPsePortEnable = '1.3.6.1.4.1.9.9.402.1.2.1.1.';
  
  /// PoE power allocated (mW)
  static const String cpeExtPsePortPwrAllocated = '1.3.6.1.4.1.9.9.402.1.2.1.8.';
  
  /// PoE power available (mW)
  static const String cpeExtPsePortPwrAvailable = '1.3.6.1.4.1.9.9.402.1.2.1.9.';
  
  /// PoE power consumption (mW)
  static const String cpeExtPsePortPwrConsumption = '1.3.6.1.4.1.9.9.402.1.2.1.10.';

  // --- Port Duplex (CISCO-STACK-MIB & EtherLike-MIB) ---
  
  /// Port duplex status (1=half, 2=full, 3=disagree, 4=auto)
  static const String portDuplex = '1.3.6.1.4.1.9.5.1.4.1.1.10.';
  
  /// Ethernet duplex status (1=unknown, 2=halfDuplex, 3=fullDuplex)
  static const String dot3StatsDuplexStatus = '1.3.6.1.2.1.10.7.2.1.19.';

  // --- VLAN Names (CISCO-VTP-MIB) ---
  
  /// VLAN name (Base OID + VLAN ID)
  static const String vtpVlanName = '1.3.6.1.4.1.9.9.46.1.3.1.1.4.1.';

  // --- VLAN Membership (CISCO-VLAN-MEMBERSHIP-MIB) ---
  
  /// VLAN assignment for port (Base OID + port index)
  static const String ciscoVmVlan = '1.3.6.1.4.1.9.9.68.1.2.2.1.2.';

  // --- Spanning Tree (BRIDGE-MIB) ---
  
  /// STP port state (1=disabled, 2=blocking, 3=listening, 4=learning, 5=forwarding, 6=broken)
  static const String dot1dStpPortState = '1.3.6.1.2.1.17.2.15.1.3.';
  
  /// STP port priority
  static const String dot1dStpPortPriority = '1.3.6.1.2.1.17.2.15.1.2.';
}

/// Helper class for Cisco-specific logic
class CiscoHelper {
  /// Detect if device is Cisco from sysObjectID
  static bool isCiscoDevice(String? sysObjectId) {
    return sysObjectId != null && 
           sysObjectId.startsWith(CiscoMIB.enterpriseId);
  }

  /// Parse IOS version string
  /// Example: "Cisco IOS Software, C2960 Software (C2960-LANBASEK9-M), Version 15.0(2)SE11"
  static String? extractIOSVersion(String? versionString) {
    if (versionString == null) return null;
    
    final regex = RegExp(r'Version\s+(\d+\.\d+\([^)]+\)[^\s,]+)');
    final match = regex.firstMatch(versionString);
    return match?.group(1);
  }

  /// Parse environmental monitor status
  static String parseEnvMonState(int state) {
    switch (state) {
      case 1: return 'Normal';
      case 2: return 'Warning';
      case 3: return 'Critical';
      case 4: return 'Shutdown';
      case 5: return 'Not Present';
      case 6: return 'Not Functioning';
      default: return 'Unknown';
    }
  }

  /// Parse duplex status
  static String parseDuplexStatus(int status) {
    switch (status) {
      case 1: return 'Half Duplex';
      case 2: return 'Full Duplex';
      case 3: return 'Disagree';
      case 4: return 'Auto';
      default: return 'Unknown';
    }
  }

  /// Parse STP port state
  static String parseStpPortState(int state) {
    switch (state) {
      case 1: return 'Disabled';
      case 2: return 'Blocking';
      case 3: return 'Listening';
      case 4: return 'Learning';
      case 5: return 'Forwarding';
      case 6: return 'Broken';
      default: return 'Unknown';
    }
  }

  /// Calculate memory usage percentage
  static double calculateMemoryUsage(int used, int free) {
    final total = used + free;
    if (total == 0) return 0.0;
    return (used / total) * 100;
  }
}
