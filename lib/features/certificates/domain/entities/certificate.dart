import 'package:equatable/equatable.dart';

/// Entity representing a Certificate on RouterOS
class Certificate extends Equatable {
  final String id;
  final String name;
  final String? commonName;
  final String? country;
  final String? state;
  final String? locality;
  final String? organization;
  final String? unit;
  final String? subjectAltName;
  final int? keySize;
  final String? keyType;
  final String? digestAlgorithm;
  final DateTime? notBefore;
  final DateTime? notAfter;
  final bool trusted;
  final bool ca;
  final bool privateKey;
  final bool crl;
  final bool revoked;
  final bool expired;
  final String? issuer;
  final String? serialNumber;
  final String? fingerprint;
  final String? akid;
  final String? skid;
  final int? daysValid;

  const Certificate({
    required this.id,
    required this.name,
    this.commonName,
    this.country,
    this.state,
    this.locality,
    this.organization,
    this.unit,
    this.subjectAltName,
    this.keySize,
    this.keyType,
    this.digestAlgorithm,
    this.notBefore,
    this.notAfter,
    this.trusted = false,
    this.ca = false,
    this.privateKey = false,
    this.crl = false,
    this.revoked = false,
    this.expired = false,
    this.issuer,
    this.serialNumber,
    this.fingerprint,
    this.akid,
    this.skid,
    this.daysValid,
  });

  /// Check if certificate is valid (not expired and not revoked)
  bool get isValid => !expired && !revoked;

  /// Check if certificate is self-signed
  bool get isSelfSigned => issuer == null || issuer == commonName;

  /// Check if certificate has private key (can be used for SSL services)
  bool get canBeUsedForSsl => privateKey && !expired && !revoked;

  @override
  List<Object?> get props => [
        id,
        name,
        commonName,
        trusted,
        ca,
        privateKey,
        expired,
        revoked,
      ];
}
