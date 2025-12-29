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
}
