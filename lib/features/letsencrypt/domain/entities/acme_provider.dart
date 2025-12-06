import 'package:equatable/equatable.dart';

/// Supported ACME providers for SSL certificates
enum AcmeProviderType {
  letsEncrypt,  // Default - Let's Encrypt
  zeroSsl,      // ZeroSSL with EAB
  custom,       // Custom ACME server
}

/// Configuration for an ACME provider
class AcmeProvider extends Equatable {
  final AcmeProviderType type;
  final String name;
  final String? directoryUrl;
  final String? eabKid;         // External Account Binding Key ID (for ZeroSSL)
  final String? eabHmacKey;     // External Account Binding HMAC Key

  const AcmeProvider({
    required this.type,
    required this.name,
    this.directoryUrl,
    this.eabKid,
    this.eabHmacKey,
  });

  /// Let's Encrypt provider (default)
  static const letsEncrypt = AcmeProvider(
    type: AcmeProviderType.letsEncrypt,
    name: "Let's Encrypt",
    // Let's Encrypt is the default in RouterOS, no URL needed
  );

  /// ZeroSSL provider (requires EAB credentials)
  static AcmeProvider zeroSsl({
    required String eabKid,
    required String eabHmacKey,
  }) {
    return AcmeProvider(
      type: AcmeProviderType.zeroSsl,
      name: 'ZeroSSL',
      directoryUrl: 'https://acme.zerossl.com/v2/DV90',
      eabKid: eabKid,
      eabHmacKey: eabHmacKey,
    );
  }

  /// Custom ACME provider
  static AcmeProvider custom({
    required String name,
    required String directoryUrl,
    String? eabKid,
    String? eabHmacKey,
  }) {
    return AcmeProvider(
      type: AcmeProviderType.custom,
      name: name,
      directoryUrl: directoryUrl,
      eabKid: eabKid,
      eabHmacKey: eabHmacKey,
    );
  }

  /// Check if provider requires EAB credentials
  bool get requiresEab => type == AcmeProviderType.zeroSsl || eabKid != null;

  @override
  List<Object?> get props => [type, name, directoryUrl, eabKid, eabHmacKey];
}
