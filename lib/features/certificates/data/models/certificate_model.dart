import '../../domain/entities/certificate.dart';

/// Model class for Certificate with JSON serialization
class CertificateModel extends Certificate {
  const CertificateModel({
    required super.id,
    required super.name,
    super.commonName,
    super.country,
    super.state,
    super.locality,
    super.organization,
    super.unit,
    super.subjectAltName,
    super.keySize,
    super.keyType,
    super.digestAlgorithm,
    super.notBefore,
    super.notAfter,
    super.trusted,
    super.ca,
    super.privateKey,
    super.crl,
    super.revoked,
    super.expired,
    super.issuer,
    super.serialNumber,
    super.fingerprint,
    super.akid,
    super.skid,
    super.daysValid,
  });

  factory CertificateModel.fromRouterOS(Map<String, String> data) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      try {
        // RouterOS date format: "jan/01/2024 00:00:00"
        return DateTime.tryParse(dateStr);
      } catch (_) {
        return null;
      }
    }

    return CertificateModel(
      id: data['.id'] ?? '',
      name: data['name'] ?? '',
      commonName: data['common-name'],
      country: data['country'],
      state: data['state'],
      locality: data['locality'],
      organization: data['organization'],
      unit: data['unit'],
      subjectAltName: data['subject-alt-name'],
      keySize: int.tryParse(data['key-size'] ?? ''),
      keyType: data['key-type'],
      digestAlgorithm: data['digest-algorithm'],
      notBefore: parseDate(data['invalid-before']),
      notAfter: parseDate(data['invalid-after']),
      trusted: data['trusted'] == 'true',
      ca: data['ca'] == 'true',
      privateKey: data['private-key'] == 'true',
      crl: data['crl'] == 'true',
      revoked: data['revoked'] == 'true',
      expired: data['expired'] == 'true',
      issuer: data['issuer'],
      serialNumber: data['serial-number'],
      fingerprint: data['fingerprint'],
      akid: data['akid'],
      skid: data['skid'],
      daysValid: int.tryParse(data['days-valid'] ?? ''),
    );
  }

  Certificate toEntity() => Certificate(
        id: id,
        name: name,
        commonName: commonName,
        country: country,
        state: state,
        locality: locality,
        organization: organization,
        unit: unit,
        subjectAltName: subjectAltName,
        keySize: keySize,
        keyType: keyType,
        digestAlgorithm: digestAlgorithm,
        notBefore: notBefore,
        notAfter: notAfter,
        trusted: trusted,
        ca: ca,
        privateKey: privateKey,
        crl: crl,
        revoked: revoked,
        expired: expired,
        issuer: issuer,
        serialNumber: serialNumber,
        fingerprint: fingerprint,
        akid: akid,
        skid: skid,
        daysValid: daysValid,
      );
}
