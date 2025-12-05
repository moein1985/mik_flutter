import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/certificates/data/datasources/certificate_remote_data_source.dart';
import 'package:hsmik/features/certificates/data/models/certificate_model.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late CertificateRemoteDataSourceImpl dataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockRouterOSClient mockClient;

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockClient = MockRouterOSClient();
    dataSource = CertificateRemoteDataSourceImpl(
      authRemoteDataSource: mockAuthRemoteDataSource,
    );

    // Setup mock client
    when(() => mockAuthRemoteDataSource.client).thenReturn(mockClient);
  });

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Duration.zero);
  });

  group('getCertificates', () {
    test('should return list of CertificateModel when successful', () async {
      // Arrange
      final List<Map<String, String>> mockResponse = [
        {
          '.id': '*1',
          'name': 'local-ca',
          'common-name': 'local-ca',
          'key-size': '2048',
          'private-key': 'true',
          'trusted': 'true',
          'ca': 'true',
          'expired': 'false',
          'revoked': 'false',
        },
        {
          '.id': '*2',
          'name': 'api-ssl-cert',
          'common-name': 'router',
          'key-size': '2048',
          'private-key': 'true',
          'trusted': 'false',
          'ca': 'false',
          'expired': 'false',
          'revoked': 'false',
          'issuer': 'local-ca',
        },
        {'type': 'done'}, // Should be filtered out
      ];

      when(() => mockClient.sendCommand(['/certificate/print']))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCertificates();

      // Assert
      expect(result, isA<List<CertificateModel>>());
      expect(result.length, 2);
      expect(result[0].name, 'local-ca');
      expect(result[0].ca, true);
      expect(result[1].name, 'api-ssl-cert');
      expect(result[1].ca, false);
      verify(() => mockClient.sendCommand(['/certificate/print'])).called(1);
    });

    test('should filter out protocol messages correctly', () async {
      // Arrange
      final List<Map<String, String>> mockResponse = [
        {'type': 'done'},
        {'type': 'trap', 'message': 'error'},
        {
          '.id': '*1',
          'name': 'cert1',
        },
      ];

      when(() => mockClient.sendCommand(['/certificate/print']))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCertificates();

      // Assert
      expect(result.length, 1);
      expect(result[0].name, 'cert1');
    });

    test('should handle empty response', () async {
      // Arrange
      final List<Map<String, String>> mockResponse = [];

      when(() => mockClient.sendCommand(['/certificate/print']))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getCertificates();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('createSelfSignedCertificate', () {
    const tName = 'test-cert';
    const tCommonName = 'test.local';
    const tKeySize = 2048;
    const tDaysValid = 365;

    test('should create certificate when CA exists', () async {
      // Arrange - CA exists
      final List<Map<String, String>> caCheckResponse = [
        {
          '.id': '*1',
          'name': 'local-ca',
          'private-key': 'true',
        },
      ];

      final List<Map<String, String>> addResponse = [{'type': 'done'}];
      final List<Map<String, String>> certPrintResponse = [
        {
          '.id': '*2',
          'name': tName,
        },
      ];
      final List<Map<String, String>> signResponse = [{'type': 'done'}];

      when(() => mockClient.sendCommand(any(), timeout: any(named: 'timeout'))).thenAnswer((invocation) async {
        final words = invocation.positionalArguments[0] as List<String>;
        if (words.contains('?name=local-ca')) {
          return caCheckResponse;
        } else if (words.contains('=name=$tName') && words.contains('/certificate/add')) {
          return addResponse;
        } else if (words.contains('?name=$tName')) {
          return certPrintResponse;
        } else if (words.contains('=.id=*2')) {
          return signResponse;
        }
        return [];
      });

      // Act
      await dataSource.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
        keySize: tKeySize,
        daysValid: tDaysValid,
      );
    });

    test('should create CA if not exists', () async {
      // Arrange - CA does not exist
      final List<Map<String, String>> caCheckResponse = [];
      final List<Map<String, String>> addCaResponse = [{'type': 'done'}];
      final List<Map<String, String>> caPrintResponse = [
        {
          '.id': '*1',
          'name': 'local-ca',
        },
      ];
      final List<Map<String, String>> signCaResponse = [{'type': 'done'}];
      final List<Map<String, String>> addCertResponse = [{'type': 'done'}];
      final List<Map<String, String>> certPrintResponse = [
        {
          '.id': '*2',
          'name': tName,
        },
      ];
      final List<Map<String, String>> signCertResponse = [{'type': 'done'}];

      when(() => mockClient.sendCommand(any(), timeout: any(named: 'timeout'))).thenAnswer((invocation) async {
        final words = invocation.positionalArguments[0] as List<String>;
        if (words.contains('?name=local-ca')) {
          return caCheckResponse;
        } else if (words.contains('=name=local-ca') && words.contains('/certificate/add')) {
          return addCaResponse;
        } else if (words.contains('?name=local-ca') && words.length == 2) {
          return caPrintResponse;
        } else if (words.contains('=.id=*1')) {
          return signCaResponse;
        } else if (words.contains('=name=$tName') && words.contains('/certificate/add')) {
          return addCertResponse;
        } else if (words.contains('?name=$tName')) {
          return certPrintResponse;
        } else if (words.contains('=.id=*2')) {
          return signCertResponse;
        }
        return [];
      });

      // Act & Assert - should not throw
      await dataSource.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
      );
    });

    test('should throw CertificateException on RouterOS error', () async {
      // Arrange
      final List<Map<String, String>> caCheckResponse = [
        {
          '.id': '*1',
          'name': 'local-ca',
          'private-key': 'true',
        },
      ];

      final List<Map<String, String>> addResponse = [
        {'type': 'trap', 'message': 'already exists'},
      ];

      when(() => mockClient.sendCommand(any(), timeout: any(named: 'timeout'))).thenAnswer((invocation) async {
        final words = invocation.positionalArguments[0] as List<String>;
        if (words.contains('?name=local-ca')) {
          return caCheckResponse;
        } else if (words.contains('=name=$tName') && words.contains('/certificate/add')) {
          return addResponse;
        }
        return [];
      });

      // Act & Assert
      expect(
        () => dataSource.createSelfSignedCertificate(
          name: tName,
          commonName: tCommonName,
        ),
        throwsA(isA<CertificateException>()),
      );
    });
  });

  group('deleteCertificate', () {
    test('should send correct delete command', () async {
      // Arrange
      const tId = '*1';
      when(() => mockClient.sendCommand([
            '/certificate/remove',
            '=.id=$tId',
          ])).thenAnswer((_) async => []);

      // Act
      await dataSource.deleteCertificate(tId);

      // Assert
      verify(() => mockClient.sendCommand([
            '/certificate/remove',
            '=.id=$tId',
          ])).called(1);
    });
  });
}