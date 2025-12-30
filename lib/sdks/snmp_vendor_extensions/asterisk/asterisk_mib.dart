/// Asterisk PBX SNMP MIB Extensions
/// 
/// Enterprise OID: 1.3.6.1.4.1.22736 (Digium/Asterisk)
/// 
/// These OIDs are specific to Asterisk PBX systems and provide
/// detailed telephony metrics and channel information.
/// 
/// Compatible with:
/// - Asterisk 11+
/// - Issabel 5 (Asterisk 18.19.0)
/// - FreePBX
/// 
/// Reference: ASTERISK-MIB.txt
class AsteriskMIB {
  /// Enterprise ID for Asterisk/Digium
  static const String enterpriseId = '1.3.6.1.4.1.22736';

  // --- Version Information ---
  
  /// Asterisk version string (e.g., "Asterisk 18.19.0")
  static const String version = '1.3.6.1.4.1.22736.1.1.1.0';
  
  /// Asterisk version number (numeric format)
  static const String versionNum = '1.3.6.1.4.1.22736.1.1.2.0';

  // --- Configuration Information ---
  
  /// System uptime in timeticks
  static const String configUptime = '1.3.6.1.4.1.22736.1.2.1.0';
  
  /// Last reload time in timeticks
  static const String configReloadTime = '1.3.6.1.4.1.22736.1.2.2.0';
  
  /// Asterisk process ID (PID)
  static const String configPid = '1.3.6.1.4.1.22736.1.2.3.0';
  
  /// AMI socket path (Asterisk Manager Interface)
  static const String configSocket = '1.3.6.1.4.1.22736.1.2.4.0';
  
  /// Number of currently active calls
  static const String configCallsActive = '1.3.6.1.4.1.22736.1.2.5.0';
  
  /// Total number of calls processed since startup
  static const String configCallsProcessed = '1.3.6.1.4.1.22736.1.2.6.0';

  // --- Channel Information ---
  
  /// Total number of active channels
  static const String channelCount = '1.3.6.1.4.1.22736.1.5.1.0';
  
  /// Number of entries in channel table
  static const String channelTableCount = '1.3.6.1.4.1.22736.1.5.3.0';

  // --- Channel Types Table ---
  
  /// Base OID for channel types table
  static const String chanTypeTable = '1.3.6.1.4.1.22736.1.5.4.1';
  
  /// Channel type index
  static const String chanTypeIndex = '1.3.6.1.4.1.22736.1.5.4.1.1.';
  
  /// Channel type name (e.g., "PJSIP", "SIP", "IAX2", "DAHDI")
  static const String chanTypeName = '1.3.6.1.4.1.22736.1.5.4.1.2.';
  
  /// Channel type description
  static const String chanTypeDesc = '1.3.6.1.4.1.22736.1.5.4.1.3.';
  
  /// Device state support (1=yes, 0=no)
  static const String chanTypeDeviceState = '1.3.6.1.4.1.22736.1.5.4.1.4.';
  
  /// Indications support (1=yes, 0=no)
  static const String chanTypeIndications = '1.3.6.1.4.1.22736.1.5.4.1.5.';
  
  /// Transfer support (1=yes, 0=no)
  static const String chanTypeTransfer = '1.3.6.1.4.1.22736.1.5.4.1.6.';
  
  /// Number of channels of this type
  static const String chanTypeChannels = '1.3.6.1.4.1.22736.1.5.4.1.7.';

  // --- Known Limitations ---
  
  /// ⚠️ PJSIP Peers: Not available via SNMP in Issabel 5
  /// Workaround: Use Asterisk Manager Interface (AMI) or Asterisk CLI
  /// Command: asterisk -rx "pjsip show endpoints"
  
  /// ⚠️ SIP Peers: Not available via SNMP in Asterisk 18+
  /// Workaround: Use AMI or CLI
  /// Command: asterisk -rx "sip show peers" (if chan_sip enabled)
  
  /// ⚠️ Extension States: Not available via SNMP
  /// Workaround: Use AMI ExtensionState events
  
  /// ⚠️ Queue Statistics: Not available via SNMP
  /// Workaround: Use AMI QueueStatus action or CLI
  /// Command: asterisk -rx "queue show"
}

/// Helper class for Asterisk-specific logic
class AsteriskHelper {
  /// Detect if device is Asterisk-based from sysObjectID or sysDescr
  static bool isAsteriskDevice(String? sysObjectId, String? sysDescr) {
    if (sysObjectId != null && 
        sysObjectId.startsWith(AsteriskMIB.enterpriseId)) {
      return true;
    }
    
    if (sysDescr != null) {
      final lowerDescr = sysDescr.toLowerCase();
      return lowerDescr.contains('asterisk') ||
             lowerDescr.contains('issabel') ||
             lowerDescr.contains('freepbx') ||
             lowerDescr.contains('elastix');
    }
    
    return false;
  }

  /// Get Asterisk version from version string
  /// Example: "Asterisk 18.19.0" -> "18.19.0"
  static String? extractVersion(String? versionString) {
    if (versionString == null) return null;
    
    final regex = RegExp(r'Asterisk\s+(\d+\.\d+\.\d+)');
    final match = regex.firstMatch(versionString);
    return match?.group(1);
  }

  /// Parse channel type name
  /// Returns clean channel type (e.g., "PJSIP", "SIP", "IAX2")
  static String parseChannelType(String? chanType) {
    if (chanType == null || chanType.isEmpty) return 'Unknown';
    return chanType.trim().toUpperCase();
  }
}
