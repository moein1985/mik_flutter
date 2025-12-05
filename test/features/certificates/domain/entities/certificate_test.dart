import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/certificates/domain/entities/certificate.dart';

void main() {
  group('Certificate Entity', () {
    const tCertificate = Certificate(
      id: '*1',
      name: 'test-cert',
      commonName: 'test.local',
      keySize: 2048,
      privateKey: true,
      trusted: false,
      ca: false,
      expired: false,
      revoked: false,
    );

    test('should return true for isValid when not expired and not revoked', () {
      expect(tCertificate.isValid, true);
    });

    test('should return false for isValid when expired', () {
      const expiredCert = Certificate(
        id: '*1',
        name: 'test-cert',
        expired: true,
        revoked: false,
      );
      expect(expiredCert.isValid, false);
    });

    test('should return false for isValid when revoked', () {
      const revokedCert = Certificate(
        id: '*1',
        name: 'test-cert',
        expired: false,
        revoked: true,
      );
      expect(revokedCert.isValid, false);
    });

    test('should return true for isSelfSigned when issuer is null', () {
      const selfSignedCert = Certificate(
        id: '*1',
        name: 'test-cert',
        issuer: null,
      );
      expect(selfSignedCert.isSelfSigned, true);
    });

    test('should return true for isSelfSigned when issuer equals commonName', () {
      const selfSignedCert = Certificate(
        id: '*1',
        name: 'test-cert',
        commonName: 'test.local',
        issuer: 'test.local',
      );
      expect(selfSignedCert.isSelfSigned, true);
    });

    test('should return false for isSelfSigned when issuer differs from commonName', () {
      const signedCert = Certificate(
        id: '*1',
        name: 'test-cert',
        commonName: 'test.local',
        issuer: 'ca.local',
      );
      expect(signedCert.isSelfSigned, false);
    });

    test('should return true for canBeUsedForSsl when has privateKey and not expired/revoked', () {
      expect(tCertificate.canBeUsedForSsl, true);
    });

    test('should return false for canBeUsedForSsl when no privateKey', () {
      const noKeyCert = Certificate(
        id: '*1',
        name: 'test-cert',
        privateKey: false,
        expired: false,
        revoked: false,
      );
      expect(noKeyCert.canBeUsedForSsl, false);
    });

    test('should return false for canBeUsedForSsl when expired', () {
      const expiredCert = Certificate(
        id: '*1',
        name: 'test-cert',
        privateKey: true,
        expired: true,
        revoked: false,
      );
      expect(expiredCert.canBeUsedForSsl, false);
    });

    test('should return false for canBeUsedForSsl when revoked', () {
      const revokedCert = Certificate(
        id: '*1',
        name: 'test-cert',
        privateKey: true,
        expired: false,
        revoked: true,
      );
      expect(revokedCert.canBeUsedForSsl, false);
    });

    test('should be equal when all props are the same', () {
      const cert1 = Certificate(
        id: '*1',
        name: 'test-cert',
        commonName: 'test.local',
        trusted: false,
        ca: false,
        privateKey: true,
        expired: false,
        revoked: false,
      );

      const cert2 = Certificate(
        id: '*1',
        name: 'test-cert',
        commonName: 'test.local',
        trusted: false,
        ca: false,
        privateKey: true,
        expired: false,
        revoked: false,
      );

      expect(cert1, cert2);
    });

    test('should not be equal when id differs', () {
      const cert1 = Certificate(id: '*1', name: 'test-cert');
      const cert2 = Certificate(id: '*2', name: 'test-cert');

      expect(cert1, isNot(cert2));
    });

    test('should not be equal when name differs', () {
      const cert1 = Certificate(id: '*1', name: 'test-cert');
      const cert2 = Certificate(id: '*1', name: 'other-cert');

      expect(cert1, isNot(cert2));
    });
  });
}