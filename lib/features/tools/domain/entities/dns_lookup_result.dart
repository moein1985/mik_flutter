import 'package:equatable/equatable.dart';

/// Entity representing a DNS lookup result
class DnsLookupResult extends Equatable {
  final String domain;
  final List<String> ipv4Addresses;
  final List<String> ipv6Addresses;
  final Duration? responseTime;
  final String? error;

  const DnsLookupResult({
    required this.domain,
    this.ipv4Addresses = const [],
    this.ipv6Addresses = const [],
    this.responseTime,
    this.error,
  });

  /// Check if lookup was successful
  bool get hasResults => ipv4Addresses.isNotEmpty || ipv6Addresses.isNotEmpty;

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
    Duration? responseTime,
    String? error,
  }) {
    return DnsLookupResult(
      domain: domain ?? this.domain,
      ipv4Addresses: ipv4Addresses ?? this.ipv4Addresses,
      ipv6Addresses: ipv6Addresses ?? this.ipv6Addresses,
      responseTime: responseTime ?? this.responseTime,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        domain,
        ipv4Addresses,
        ipv6Addresses,
        responseTime,
        error,
      ];
}