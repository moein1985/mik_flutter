import 'package:flutter_test/flutter_test.dart';
import 'package:hsmik/features/certificates/data/models/certificate_model.dart';
import 'package:hsmik/features/certificates/domain/entities/certificate.dart';

void main() {
  group('CertificateModel', () {
    const tCertificateModel = CertificateModel(
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

    test('should be a subclass of Certificate entity', () {
      expect(tCertificateModel, isA<Certificate>());
    });

    test('should return valid model when fromRouterOS is called with complete data', () {
      // Arrange
      final routerOSData = {
        '.id': '*1',
        'name': 'test-cert',
        'common-name': 'test.local',
        'key-size': '2048',
        'private-key': 'true',
        'trusted': 'true',
        'ca': 'false',
        'expired': 'false',
        'revoked': 'false',
        'issuer': 'ca.local',
        'serial-number': '123456',
      };

      // Act
      final result = CertificateModel.fromRouterOS(routerOSData);

      // Assert
      expect(result.id, '*1');
      expect(result.name, 'test-cert');
      expect(result.commonName, 'test.local');
      expect(result.keySize, 2048);
      expect(result.privateKey, true);
      expect(result.trusted, true);
      expect(result.ca, false);
      expect(result.expired, false);
      expect(result.revoked, false);
      expect(result.issuer, 'ca.local');
      expect(result.serialNumber, '123456');
    });

    test('should handle missing optional fields in fromRouterOS', () {
      // Arrange
      final minimalData = {
        '.id': '*1',
        'name': 'test-cert',
      };

      // Act
      final result = CertificateModel.fromRouterOS(minimalData);

      // Assert
      expect(result.id, '*1');
      expect(result.name, 'test-cert');
      expect(result.commonName, null);
      expect(result.keySize, null);
      expect(result.privateKey, false); // default value
      expect(result.trusted, false); // default value
      expect(result.ca, false); // default value
      expect(result.expired, false); // default value
      expect(result.revoked, false); // default value
    });

    test('should parse boolean strings correctly', () {
      // Arrange
      final dataWithBooleans = {
        '.id': '*1',
        'name': 'test-cert',
        'private-key': 'true',
        'trusted': 'false',
        'ca': 'true',
        'expired': 'false',
        'revoked': 'true',
      };

      // Act
      final result = CertificateModel.fromRouterOS(dataWithBooleans);

      // Assert
      expect(result.privateKey, true);
      expect(result.trusted, false);
      expect(result.ca, true);
      expect(result.expired, false);
      expect(result.revoked, true);
    });

    test('should parse integer strings correctly', () {
      // Arrange
      final dataWithIntegers = {
        '.id': '*1',
        'name': 'test-cert',
        'key-size': '4096',
        'days-valid': '365',
      };

      // Act
      final result = CertificateModel.fromRouterOS(dataWithIntegers);

      // Assert
      expect(result.keySize, 4096);
      expect(result.daysValid, 365);
    });

    test('should handle invalid integer strings gracefully', () {
      // Arrange
      final dataWithInvalidIntegers = {
        '.id': '*1',
        'name': 'test-cert',
        'key-size': 'invalid',
        'days-valid': 'not-a-number',
      };

      // Act
      final result = CertificateModel.fromRouterOS(dataWithInvalidIntegers);

      // Assert
      expect(result.keySize, null);
      expect(result.daysValid, null);
    });

    test('should handle empty data map', () {
      // Arrange
      final emptyData = <String, String>{};

      // Act
      final result = CertificateModel.fromRouterOS(emptyData);

      // Assert
      expect(result.id, '');
      expect(result.name, '');
      expect(result.commonName, null);
    });
  });
}