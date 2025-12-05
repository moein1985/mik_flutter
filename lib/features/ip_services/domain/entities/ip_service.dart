import 'package:equatable/equatable.dart';

/// Entity representing an IP Service on RouterOS
class IpService extends Equatable {
  final String id;
  final String name;
  final int port;
  final String address;
  final String? certificate;
  final bool disabled;
  final bool invalid;
  final String? vrf;
  final int? maxSessions;
  final String? tlsVersion;

  const IpService({
    required this.id,
    required this.name,
    required this.port,
    this.address = '',
    this.certificate,
    this.disabled = false,
    this.invalid = false,
    this.vrf,
    this.maxSessions,
    this.tlsVersion,
  });

  /// Check if this service requires a certificate (SSL services)
  bool get requiresCertificate => name == 'api-ssl' || name == 'www-ssl';

  /// Check if certificate is missing when required
  bool get isCertificateMissing => 
      requiresCertificate && (certificate == null || certificate == 'none' || certificate!.isEmpty);

  /// Check if service is enabled
  bool get isEnabled => !disabled;

  @override
  List<Object?> get props => [
        id,
        name,
        port,
        address,
        certificate,
        disabled,
        invalid,
        vrf,
        maxSessions,
        tlsVersion,
      ];

  IpService copyWith({
    String? id,
    String? name,
    int? port,
    String? address,
    String? certificate,
    bool? disabled,
    bool? invalid,
    String? vrf,
    int? maxSessions,
    String? tlsVersion,
  }) {
    return IpService(
      id: id ?? this.id,
      name: name ?? this.name,
      port: port ?? this.port,
      address: address ?? this.address,
      certificate: certificate ?? this.certificate,
      disabled: disabled ?? this.disabled,
      invalid: invalid ?? this.invalid,
      vrf: vrf ?? this.vrf,
      maxSessions: maxSessions ?? this.maxSessions,
      tlsVersion: tlsVersion ?? this.tlsVersion,
    );
  }
}
