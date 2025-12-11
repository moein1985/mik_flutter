import 'package:equatable/equatable.dart';

/// Entity representing a DNS lookup result
class DnsLookupResult extends Equatable {
  final String domain;
  final List<String> ipv4Addresses;
  final List<String> ipv6Addresses;
  final List<String> otherRecords;
  final Duration? responseTime;
  final String? error;
  final String? recordType;
  final String? dnsServer;

  const DnsLookupResult({
    required this.domain,
    this.ipv4Addresses = const [],
    this.ipv6Addresses = const [],
    this.otherRecords = const [],
    this.responseTime,
    this.error,
    this.recordType,
    this.dnsServer,
  });

  /// Check if lookup was successful
  bool get hasResults => ipv4Addresses.isNotEmpty || ipv6Addresses.isNotEmpty || otherRecords.isNotEmpty;

  /// Get all IP addresses (both IPv4 and IPv6)
  List<String> get allAddresses => [...ipv4Addresses, ...ipv6Addresses];

  /// Check if result contains IPv4 addresses
  bool get hasIpv4 => ipv4Addresses.isNotEmpty;

  /// Check if result contains IPv6 addresses
  bool get hasIpv6 => ipv6Addresses.isNotEmpty;

  /// Get the primary IP address (first IPv4, or first IPv6 if no IPv4)
  String? get primaryAddress {
    if (ipv4Addresses.isNotEmpty) return ipv4Addresses.first;
    if (ipv6Addresses.isNotEmpty) return ipv6Addresses.first;
    return null;
  }

  DnsLookupResult copyWith({
    String? domain,
    List<String>? ipv4Addresses,
    List<String>? ipv6Addresses,
    List<String>? otherRecords,
    Duration? responseTime,
    String? error,
    String? recordType,
    String? dnsServer,
  }) {
    return DnsLookupResult(
      domain: domain ?? this.domain,
      ipv4Addresses: ipv4Addresses ?? this.ipv4Addresses,
      ipv6Addresses: ipv6Addresses ?? this.ipv6Addresses,
      otherRecords: otherRecords ?? this.otherRecords,
      responseTime: responseTime ?? this.responseTime,
      error: error ?? this.error,
      recordType: recordType ?? this.recordType,
      dnsServer: dnsServer ?? this.dnsServer,
    );
  }

  @override
  List<Object?> get props => [
        domain,
        ipv4Addresses,
        ipv6Addresses,
        otherRecords,
        responseTime,
        error,
        recordType,
        dnsServer,
      ];
}