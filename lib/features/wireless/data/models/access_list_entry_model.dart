import '../../domain/entities/access_list_entry.dart';

class AccessListEntryModel extends AccessListEntry {
  const AccessListEntryModel({
    required super.id,
    required super.macAddress,
    required super.interface,
    required super.authentication,
    required super.forwarding,
    super.apTxLimit,
    super.clientTxLimit,
    super.signalRange,
    super.time,
    super.comment,
  });

  factory AccessListEntryModel.fromMap(Map<String, String> map) {
    // MikroTik may not return authentication/forwarding if they are default (yes)
    // So we need to check: if the key doesn't exist, default to true
    // If the key exists, check if it's 'yes'
    final hasAuthentication = map.containsKey('authentication');
    final hasForwarding = map.containsKey('forwarding');
    
    return AccessListEntryModel(
      id: map['.id'] ?? '',
      macAddress: map['mac-address'] ?? '',
      interface: map['interface'] ?? '',
      // Default to true if not present (MikroTik default)
      authentication: hasAuthentication ? map['authentication'] == 'yes' : true,
      forwarding: hasForwarding ? map['forwarding'] == 'yes' : true,
      apTxLimit: map['ap-tx-limit'],
      clientTxLimit: map['client-tx-limit'],
      signalRange: map['signal-range'],
      time: map['time'],
      comment: map['comment'],
    );
  }

  /// Convert bandwidth string to MikroTik format (e.g., "10m" -> "10000000", "5M" -> "5000000")
  /// MikroTik expects bandwidth in bits per second as a plain number
  static String? _convertBandwidth(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final trimmed = value.trim().toLowerCase();
    
    // If it's already just a number, return as-is
    final numOnly = int.tryParse(trimmed);
    if (numOnly != null) return trimmed;
    
    // Parse number with suffix
    final match = RegExp(r'^(\d+(?:\.\d+)?)\s*([kmg])?$', caseSensitive: false).firstMatch(trimmed);
    if (match == null) return value; // Return original if can't parse
    
    final numPart = double.tryParse(match.group(1) ?? '0') ?? 0;
    final suffix = match.group(2)?.toLowerCase();
    
    int multiplier = 1;
    switch (suffix) {
      case 'k':
        multiplier = 1000; // kilobits
        break;
      case 'm':
        multiplier = 1000000; // megabits
        break;
      case 'g':
        multiplier = 1000000000; // gigabits
        break;
    }
    
    return (numPart * multiplier).round().toString();
  }

  /// Validate and convert time format for MikroTik
  /// MikroTik expects time in format like "8h-17h" or "08:00:00-17:00:00,mon,tue,wed"
  /// Returns null if the format is invalid
  static String? _validateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final trimmed = value.trim();
    
    // Valid patterns:
    // - Time range: "8h-17h", "08:00-17:00", "08:00:00-17:00:00"
    // - With days: "8h-17h,mon,tue,wed"
    // - Full format: "00:00:00-23:59:59,mon,tue,wed,thu,fri,sat,sun"
    
    // Check for time range pattern (must contain a dash for range)
    if (trimmed.contains('-')) {
      // Basic validation: should have format like "Xh-Yh" or "XX:XX-XX:XX"
      final timeRangePattern = RegExp(
        r'^(\d{1,2}h?|\d{1,2}:\d{2}(:\d{2})?)-(\d{1,2}h?|\d{1,2}:\d{2}(:\d{2})?)(,\w+)*$',
        caseSensitive: false
      );
      if (timeRangePattern.hasMatch(trimmed)) {
        return trimmed;
      }
    }
    
    // If validation fails, return null to skip this field
    return null;
  }

  Map<String, String> toMap() {
    final map = <String, String>{
      'mac-address': macAddress,
      'interface': interface,
      'authentication': authentication ? 'yes' : 'no',
      'forwarding': forwarding ? 'yes' : 'no',
    };

    final convertedApTxLimit = _convertBandwidth(apTxLimit);
    final convertedClientTxLimit = _convertBandwidth(clientTxLimit);
    
    if (convertedApTxLimit != null) map['ap-tx-limit'] = convertedApTxLimit;
    if (convertedClientTxLimit != null) map['client-tx-limit'] = convertedClientTxLimit;
    if (signalRange != null) map['signal-range'] = signalRange!;
    
    // Validate time format before sending
    final validatedTime = _validateTime(time);
    if (validatedTime != null) map['time'] = validatedTime;
    
    if (comment != null) map['comment'] = comment!;

    return map;
  }
}
