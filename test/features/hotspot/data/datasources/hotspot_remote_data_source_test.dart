import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hsmik/core/errors/exceptions.dart';
import 'package:hsmik/features/hotspot/data/datasources/hotspot_remote_data_source.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_server_model.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late HotspotRemoteDataSourceImpl dataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late MockRouterOSClient mockClient;

  setUp(() {
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    mockClient = MockRouterOSClient();
    dataSource = HotspotRemoteDataSourceImpl(
      authRemoteDataSource: mockAuthRemoteDataSource,
    );
  });

  group('HotspotRemoteDataSourceImpl', () {
    test('should return list of HotspotServerModel when getServers succeeds', () async {
      // Arrange
      final tResponse = [
        {
          'type': 're',
          '.id': '*1',
          'name': 'hotspot1',
          'interface': 'ether1',
          'address-pool': 'hs-pool',
          'disabled': 'false',
        },
      ];
      when(() => mockAuthRemoteDataSource.legacyClient).thenReturn(mockClient);
      when(() => mockClient.getHotspotServers()).thenAnswer((_) async => tResponse);

      // Act
      final result = await dataSource.getServers();

      // Assert
      expect(result, isA<List<HotspotServerModel>>());
      expect(result.length, 1);
      expect(result[0].id, '*1');
      verify(() => mockClient.getHotspotServers()).called(1);
    });

    test('should throw ServerException when getServers fails', () async {
      // Arrange
      when(() => mockAuthRemoteDataSource.legacyClient).thenReturn(mockClient);
      when(() => mockClient.getHotspotServers()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => dataSource.getServers(), throwsA(isA<ServerException>()));
    });

    test('should throw ServerException when not connected', () async {
      // Arrange
      when(() => mockAuthRemoteDataSource.legacyClient).thenReturn(null);

      // Act & Assert
      expect(() => dataSource.getServers(), throwsA(isA<ServerException>()));
    });
  });
}