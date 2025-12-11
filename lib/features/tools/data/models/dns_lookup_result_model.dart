import '../../domain/entities/dns_lookup_result.dart';

/// Model for DNS lookup result data from RouterOS API
class DnsLookupResultModel extends DnsLookupResult {
  const DnsLookupResultModel({
    required super.domain,
    super.ipv4Addresses,
    super.ipv6Addresses,
    super.otherRecords,
    super.responseTime,
    super.error,
    super.recordType,
    super.dnsServer,
  });

  /// Create model from RouterOS DNS lookup response
  factory DnsLookupResultModel.fromRouterOS(
    String domain,
    List<Map<String, String>> response, {
    String? recordType,
    String? dnsServer,
  }) {
    final ipv4Addresses = <String>[];
    final ipv6Addresses = <String>[];
    final otherRecords = <String>[];
    Duration? responseTime;
    String? error;

    for (final item in response) {
      // Skip protocol messages
      if (item.containsKey('type') && item['type'] == 'done') continue;

      // Check for error
      if (item.containsKey('message')) {
        error = item['message'];
        continue;
      }
      if (item.containsKey('error')) {
        error = item['error'];
        continue;
      }

      // Parse response time
      if (item.containsKey('response-time') && item['response-time'] != null) {
        responseTime = _parseDuration(item['response-time']!);
      }

      // Parse IP addresses or records based on record type
      final address = item['address'];
      final name = item['name'];
      
      if (address != null && address.isNotEmpty) {
        if (_isIpv4(address)) {
          ipv4Addresses.add(address);
        } else if (_isIpv6(address)) {
          ipv6Addresses.add(address);
        } else {
          otherRecords.add(address);
        }
      } else if (name != null && name.isNotEmpty) {
        otherRecords.add(name);
      }
      
      // Handle MX records
      if (item.containsKey('preference') && item.containsKey('exchange')) {
        otherRecords.add('${item['preference']} ${item['exchange']}');
      }
      
      // Handle TXT records
      if (item.containsKey('text')) {
        otherRecords.add(item['text']!);
      }
      
      // Handle NS records
      if (item.containsKey('ns')) {
        otherRecords.add(item['ns']!);
      }
      
      // Handle CNAME records
      if (item.containsKey('cname')) {
        otherRecords.add(item['cname']!);
      }
    }

    return DnsLookupResultModel(
      domain: domain,
      ipv4Addresses: ipv4Addresses,
      ipv6Addresses: ipv6Addresses,
      otherRecords: otherRecords,
      responseTime: responseTime,
      error: error,
      recordType: recordType,
      dnsServer: dnsServer,
    );
  }

  /// Check if string is IPv4 address
  static bool _isIpv4(String address) {
    final ipv4Regex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    return ipv4Regex.hasMatch(address);
  }

  /// Check if string is IPv6 address
  static bool _isIpv6(String address) {
    final ipv6Regex = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    return ipv6Regex.hasMatch(address);
  }

  /// Parse duration string like "10ms" or "1.5s" to Duration
  static Duration _parseDuration(String durationStr) {
    if (durationStr.endsWith('ms')) {
      final ms = double.tryParse(durationStr.substring(0, durationStr.length - 2));
      return Duration(microseconds: (ms! * 1000).round());
    } else if (durationStr.endsWith('s')) {
      final s = double.tryParse(durationStr.substring(0, durationStr.length - 1));
      return Duration(microseconds: (s! * 1000000).round());
    } else {
      // Assume milliseconds if no unit
      final ms = double.tryParse(durationStr);
      return Duration(microseconds: (ms! * 1000).round());
    }
  }

  /// Convert to entity
  DnsLookupResult toEntity() {
    return DnsLookupResult(
      domain: domain,
      ipv4Addresses: ipv4Addresses,
      ipv6Addresses: ipv6Addresses,
      otherRecords: otherRecords,
      responseTime: responseTime,
      error: error,
      recordType: recordType,
      dnsServer: dnsServer,
    );
  }
}