import 'package:equatable/equatable.dart';

/// Status of Let's Encrypt certificate on RouterOS
class LetsEncryptStatus extends Equatable {
  final bool hasCertificate;
  final String? certificateName;
  final String? dnsName;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final int? daysUntilExpiry;
  final bool isExpired;
  final bool isExpiringSoon; // Within 30 days

  const LetsEncryptStatus({
    required this.hasCertificate,
    this.certificateName,
    this.dnsName,
    this.issuedAt,
    this.expiresAt,
    this.daysUntilExpiry,
    this.isExpired = false,
    this.isExpiringSoon = false,
  });

  /// Check if certificate is valid and usable
  bool get isValid => hasCertificate && !isExpired;

  @override
  List<Object?> get props => [
        hasCertificate,
        certificateName,
        dnsName,
        issuedAt,
        expiresAt,
        daysUntilExpiry,
        isExpired,
        isExpiringSoon,
      ];

  LetsEncryptStatus copyWith({
    bool? hasCertificate,
    String? certificateName,
    String? dnsName,
    DateTime? issuedAt,
    DateTime? expiresAt,
    int? daysUntilExpiry,
    bool? isExpired,
    bool? isExpiringSoon,
  }) {
    return LetsEncryptStatus(
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificateName: certificateName ?? this.certificateName,
      dnsName: dnsName ?? this.dnsName,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      isExpired: isExpired ?? this.isExpired,
      isExpiringSoon: isExpiringSoon ?? this.isExpiringSoon,
    );
  }
}
