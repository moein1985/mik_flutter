/// Base SNMP Protocol Constants
/// 
/// Standard SNMP OIDs used across all SNMP implementations
class OidConstants {
  // System Group (RFC 1213)
  static const String sysDescr = '1.3.6.1.2.1.1.1.0';
  static const String sysObjectId = '1.3.6.1.2.1.1.2.0';
  static const String sysUpTime = '1.3.6.1.2.1.1.3.0';
  static const String sysContact = '1.3.6.1.2.1.1.4.0';
  static const String sysName = '1.3.6.1.2.1.1.5.0';
  static const String sysLocation = '1.3.6.1.2.1.1.6.0';
  static const String sysServices = '1.3.6.1.2.1.1.7.0';

  // Interfaces Group (RFC 1213)
  static const String ifNumber = '1.3.6.1.2.1.2.1.0';
  static const String ifDescr = '1.3.6.1.2.1.2.2.1.2';
  static const String ifType = '1.3.6.1.2.1.2.2.1.3';
  static const String ifMtu = '1.3.6.1.2.1.2.2.1.4';
  static const String ifSpeed = '1.3.6.1.2.1.2.2.1.5';
  static const String ifPhysAddress = '1.3.6.1.2.1.2.2.1.6';
  static const String ifAdminStatus = '1.3.6.1.2.1.2.2.1.7';
  static const String ifOperStatus = '1.3.6.1.2.1.2.2.1.8';
  static const String ifInOctets = '1.3.6.1.2.1.2.2.1.10';
  static const String ifOutOctets = '1.3.6.1.2.1.2.2.1.16';

  // IP Group (RFC 1213)
  static const String ipForwarding = '1.3.6.1.2.1.4.1.0';
  static const String ipDefaultTTL = '1.3.6.1.2.1.4.2.0';
  static const String ipInReceives = '1.3.6.1.2.1.4.3.0';
  static const String ipInDelivers = '1.3.6.1.2.1.4.9.0';
  static const String ipOutRequests = '1.3.6.1.2.1.4.10.0';

  // Host Resources MIB (RFC 2790)
  static const String hrSystemUptime = '1.3.6.1.2.1.25.1.1.0';
  static const String hrSystemDate = '1.3.6.1.2.1.25.1.2.0';
  static const String hrSystemNumUsers = '1.3.6.1.2.1.25.1.5.0';
  static const String hrSystemProcesses = '1.3.6.1.2.1.25.1.6.0';
  static const String hrSystemMaxProcesses = '1.3.6.1.2.1.25.1.7.0';
  
  static const String hrMemorySize = '1.3.6.1.2.1.25.2.2.0';
  static const String hrStorageDescr = '1.3.6.1.2.1.25.2.3.1.3';
  static const String hrStorageSize = '1.3.6.1.2.1.25.2.3.1.5';
  static const String hrStorageUsed = '1.3.6.1.2.1.25.2.3.1.6';
  
  static const String hrProcessorLoad = '1.3.6.1.2.1.25.3.3.1.2';

  // TCP/UDP (RFC 1213)
  static const String tcpCurrEstab = '1.3.6.1.2.1.6.9.0';
  static const String tcpInSegs = '1.3.6.1.2.1.6.10.0';
  static const String tcpOutSegs = '1.3.6.1.2.1.6.11.0';
  static const String udpInDatagrams = '1.3.6.1.2.1.7.1.0';
  static const String udpOutDatagrams = '1.3.6.1.2.1.7.4.0';

  // SNMP Group (RFC 1213)
  static const String snmpInPkts = '1.3.6.1.2.1.11.1.0';
  static const String snmpOutPkts = '1.3.6.1.2.1.11.2.0';
  static const String snmpInBadVersions = '1.3.6.1.2.1.11.3.0';
  static const String snmpInBadCommunityNames = '1.3.6.1.2.1.11.4.0';

  // UCD-SNMP-MIB (Linux systems)
  static const String laLoad1 = '1.3.6.1.4.1.2021.10.1.3.1';
  static const String laLoad5 = '1.3.6.1.4.1.2021.10.1.3.2';
  static const String laLoad15 = '1.3.6.1.4.1.2021.10.1.3.3';
  static const String memTotalReal = '1.3.6.1.4.1.2021.4.5.0';
  static const String memAvailReal = '1.3.6.1.4.1.2021.4.6.0';
  static const String memTotalSwap = '1.3.6.1.4.1.2021.4.3.0';
  static const String memAvailSwap = '1.3.6.1.4.1.2021.4.4.0';

  // NET-SNMP-EXTEND-MIB (Custom scripts)
  static const String nsExtendOutput1Line = '1.3.6.1.4.1.8072.1.3.2.3.1.1';
  static const String nsExtendOutput2Line = '1.3.6.1.4.1.8072.1.3.2.3.1.2';
  static const String nsExtendOutLine = '1.3.6.1.4.1.8072.1.3.2.4.1.2';
}
