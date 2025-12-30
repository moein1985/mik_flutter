// lib/data/data_sources/oid_constants.dart

// This class holds all the SNMP OID constants for better organization and reusability.
class OidConstants {
  // --- Standard MIB-II OIDs (RFC 1213) ---
  // System Group
  static const String sysDescr = '1.3.6.1.2.1.1.1.0';
  static const String sysObjectId = '1.3.6.1.2.1.1.2.0';
  static const String sysUpTime = '1.3.6.1.2.1.1.3.0';
  static const String sysContact = '1.3.6.1.2.1.1.4.0';
  static const String sysName = '1.3.6.1.2.1.1.5.0';
  static const String sysLocation = '1.3.6.1.2.1.1.6.0';
  
  // Interfaces Group
  static const String ifNumber = '1.3.6.1.2.1.2.1.0';
  
  // Interface Table (ifTable)
  static const String ifDescrBase = '1.3.6.1.2.1.2.2.1.2.';
  static const String ifTypeBase = '1.3.6.1.2.1.2.2.1.3.';
  static const String ifSpeedBase = '1.3.6.1.2.1.2.2.1.5.';
  static const String ifPhysAddressBase = '1.3.6.1.2.1.2.2.1.6.';
  static const String ifAdminStatusBase = '1.3.6.1.2.1.2.2.1.7.';
  static const String ifOperStatusBase = '1.3.6.1.2.1.2.2.1.8.';
  static const String ifLastChangeBase = '1.3.6.1.2.1.2.2.1.9.';
  static const String ifInOctetsBase = '1.3.6.1.2.1.2.2.1.10.';
  static const String ifOutOctetsBase = '1.3.6.1.2.1.2.2.1.16.';
  static const String ifInErrorsBase = '1.3.6.1.2.1.2.2.1.14.';
  static const String ifOutErrorsBase = '1.3.6.1.2.1.2.2.1.20.';

  // Extended Interface Table (ifXTable) - RFC 2863
  static const String ifNameBase = '1.3.6.1.2.1.31.1.1.1.1.';
  static const String ifAliasBase = '1.3.6.1.2.1.31.1.1.1.18.';

  // --- Vendor & Standard Specific OIDs ---
  // Q-BRIDGE-MIB (IEEE 802.1Q) - Standard VLAN OIDs
  static const String dot1qPvid = '1.3.6.1.2.1.17.7.1.4.5.1.1.';
  
  // CISCO-VLAN-MEMBERSHIP-MIB OID
  static const String ciscoVmVlan = '1.3.6.1.4.1.9.9.68.1.2.2.1.2.';

  // --- Vendor Identification OID Prefixes ---
  static const String ciscoEnterpriseId = '1.3.6.1.4.1.9';
  static const String mikrotikEnterpriseId = '1.3.6.1.4.1.14988';
  // Microsoft Windows typically uses standard MIBs, identified by sysDescr pattern
  // Asterisk/Digium Enterprise ID
  static const String asteriskEnterpriseId = '1.3.6.1.4.1.22736';

  // --- HOST-RESOURCES-MIB (RFC 2790) - Used by Microsoft Windows & Asterisk ---
  // System Group
  static const String hrSystemUptime = '1.3.6.1.2.1.25.1.1.0';
  static const String hrSystemDate = '1.3.6.1.2.1.25.1.2.0';
  static const String hrSystemNumUsers = '1.3.6.1.2.1.25.1.5.0';
  static const String hrSystemProcesses = '1.3.6.1.2.1.25.1.6.0';
  static const String hrSystemMaxProcesses = '1.3.6.1.2.1.25.1.7.0';
  
  // Memory/Storage Group
  static const String hrMemorySize = '1.3.6.1.2.1.25.2.2.0'; // Total physical RAM in KB
  static const String hrStorageTable = '1.3.6.1.2.1.25.2.3.1';
  static const String hrStorageIndex = '1.3.6.1.2.1.25.2.3.1.1.';
  static const String hrStorageType = '1.3.6.1.2.1.25.2.3.1.2.';
  static const String hrStorageDescr = '1.3.6.1.2.1.25.2.3.1.3.';
  static const String hrStorageAllocationUnits = '1.3.6.1.2.1.25.2.3.1.4.';
  static const String hrStorageSize = '1.3.6.1.2.1.25.2.3.1.5.';
  static const String hrStorageUsed = '1.3.6.1.2.1.25.2.3.1.6.';
  
  // Device/Processor Group
  static const String hrDeviceTable = '1.3.6.1.2.1.25.3.2.1';
  static const String hrDeviceDescr = '1.3.6.1.2.1.25.3.2.1.3.';
  static const String hrProcessorLoad = '1.3.6.1.2.1.25.3.3.1.2.'; // CPU load %
  
  // Running Software Group
  static const String hrSWRunTable = '1.3.6.1.2.1.25.4.2.1';
  static const String hrSWRunIndex = '1.3.6.1.2.1.25.4.2.1.1.';
  static const String hrSWRunName = '1.3.6.1.2.1.25.4.2.1.2.';
  static const String hrSWRunPath = '1.3.6.1.2.1.25.4.2.1.4.';
  static const String hrSWRunParameters = '1.3.6.1.2.1.25.4.2.1.5.';
  static const String hrSWRunType = '1.3.6.1.2.1.25.4.2.1.6.';
  static const String hrSWRunStatus = '1.3.6.1.2.1.25.4.2.1.7.';
  
  // Running Software Performance Group
  static const String hrSWRunPerfCPU = '1.3.6.1.2.1.25.5.1.1.1.';
  static const String hrSWRunPerfMem = '1.3.6.1.2.1.25.5.1.1.2.';

  // --- CISCO-SPECIFIC OIDs ---
  
  // Hardware Information (ENTITY-MIB)
  static const String entPhysicalModelName = '1.3.6.1.2.1.47.1.1.1.1.13.1';
  static const String entPhysicalSerialNum = '1.3.6.1.2.1.47.1.1.1.1.11.1';
  static const String entPhysicalSoftwareRev = '1.3.6.1.2.1.47.1.1.1.1.10.1';
  static const String entPhysicalHardwareRev = '1.3.6.1.2.1.47.1.1.1.1.8.1';
  static const String entPhysicalDescr = '1.3.6.1.2.1.47.1.1.1.1.2.1';
  
  // IOS Version (CISCO-IMAGE-MIB)
  static const String ciscoImageString = '1.3.6.1.4.1.9.9.25.1.1.1.2.2';
  
  // CPU Usage (CISCO-PROCESS-MIB)
  static const String cpmCPUTotal5sec = '1.3.6.1.4.1.9.9.109.1.1.1.1.3.1';
  static const String cpmCPUTotal1min = '1.3.6.1.4.1.9.9.109.1.1.1.1.4.1';
  static const String cpmCPUTotal5min = '1.3.6.1.4.1.9.9.109.1.1.1.1.5.1';
  
  // Memory Usage (CISCO-MEMORY-POOL-MIB)
  static const String ciscoMemoryPoolName = '1.3.6.1.4.1.9.9.48.1.1.1.2.1';
  static const String ciscoMemoryPoolUsed = '1.3.6.1.4.1.9.9.48.1.1.1.5.1';
  static const String ciscoMemoryPoolFree = '1.3.6.1.4.1.9.9.48.1.1.1.6.1';
  
  // Environmental Monitoring (CISCO-ENVMON-MIB)
  // Temperature Sensors
  static const String ciscoEnvMonTemperatureStatusDescr = '1.3.6.1.4.1.9.9.13.1.3.1.2.1';
  static const String ciscoEnvMonTemperatureStatusValue = '1.3.6.1.4.1.9.9.13.1.3.1.3.1';
  static const String ciscoEnvMonTemperatureState = '1.3.6.1.4.1.9.9.13.1.3.1.6.1';
  
  // Fan Status
  static const String ciscoEnvMonFanStatusDescr = '1.3.6.1.4.1.9.9.13.1.4.1.2.1';
  static const String ciscoEnvMonFanState = '1.3.6.1.4.1.9.9.13.1.4.1.3.1';
  
  // Power Supply Status
  static const String ciscoEnvMonSupplyStatusDescr = '1.3.6.1.4.1.9.9.13.1.5.1.2.1';
  static const String ciscoEnvMonSupplyState = '1.3.6.1.4.1.9.9.13.1.5.1.3.1';
  static const String ciscoEnvMonSupplySource = '1.3.6.1.4.1.9.9.13.1.5.1.4.1';
  
  // PoE Information (CISCO-POWER-ETHERNET-EXT-MIB)
  static const String cpeExtPsePortEnable = '1.3.6.1.4.1.9.9.402.1.2.1.1.';
  static const String cpeExtPsePortPwrAllocated = '1.3.6.1.4.1.9.9.402.1.2.1.8.';
  static const String cpeExtPsePortPwrAvailable = '1.3.6.1.4.1.9.9.402.1.2.1.9.';
  static const String cpeExtPsePortPwrConsumption = '1.3.6.1.4.1.9.9.402.1.2.1.10.';
  
  // Port Duplex (CISCO-STACK-MIB & EtherLike-MIB)
  static const String portDuplex = '1.3.6.1.4.1.9.5.1.4.1.1.10.';
  static const String dot3StatsDuplexStatus = '1.3.6.1.2.1.10.7.2.1.19.';
  
  // VLAN Names (CISCO-VTP-MIB)
  static const String vtpVlanName = '1.3.6.1.4.1.9.9.46.1.3.1.1.4.1.';
  
  // Spanning Tree (BRIDGE-MIB)
  static const String dot1dStpPortState = '1.3.6.1.2.1.17.2.15.1.3.';
  static const String dot1dStpPortPriority = '1.3.6.1.2.1.17.2.15.1.2.';
}
