import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/features/wireless/data/repositories/wireless_repository_impl.dart';
import 'package:hsmik/features/wireless/data/models/wireless_interface_model.dart';
import 'package:hsmik/features/wireless/domain/entities/wireless_interface.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/core/errors/exceptions.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late WirelessRepositoryImpl repository;
  late MockWirelessRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockWirelessRemoteDataSource();
    repository = WirelessRepositoryImpl(mockRemoteDataSource);
  });

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Duration.zero);
  });

  group('getWirelessInterfaces', () {
    test('should return list of wireless interfaces when remote data source succeeds', () async {
      // Arrange
      final tWirelessInterfaceModels = [
        WirelessInterfaceModel(
          id: '*1',
          name: 'wlan1',
          ssid: 'MyWiFi',
          frequency: '2412',
          band: '2ghz-b/g/n',
          disabled: false,
          status: 'running',
          clients: 2,
          macAddress: 'AA:BB:CC:DD:EE:FF',
          mode: 'ap-bridge',
          security: 'default',
          txPower: 20,
          channelWidth: 20,
        ),
      ];

      when(() => mockRemoteDataSource.getWirelessInterfaces())
          .thenAnswer((_) async => tWirelessInterfaceModels);

      // Act
      final result = await repository.getWirelessInterfaces();

      // Assert
      expect(result, isA<Right<Failure, List<WirelessInterface>>>());
      result.fold(
        (failure) => fail('Should not return failure'),
        (interfaces) {
          expect(interfaces, hasLength(1));
          expect(interfaces.first.name, 'wlan1');
          expect(interfaces.first.ssid, 'MyWiFi');
          expect(interfaces.first.clients, 2);
        },
      );
      verify(() => mockRemoteDataSource.getWirelessInterfaces()).called(1);
    });

    test('should return ServerFailure when remote data source throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.getWirelessInterfaces())
          .thenThrow(ServerException('Server error'));

      // Act
      final result = await repository.getWirelessInterfaces();

      // Assert
      expect(result, isA<Left<Failure, List<WirelessInterface>>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (interfaces) => fail('Should return failure'),
      );
    });
  });

  group('enableInterface', () {
    test('should return void when remote data source succeeds', () async {
      // Arrange
      const interfaceName = 'wlan1';
      when(() => mockRemoteDataSource.enableInterface(interfaceName))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.enableInterface(interfaceName);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRemoteDataSource.enableInterface(interfaceName)).called(1);
    });

    test('should return ServerFailure when remote data source throws exception', () async {
      // Arrange
      const interfaceName = 'wlan1';
      when(() => mockRemoteDataSource.enableInterface(interfaceName))
          .thenThrow(ServerException('Server error'));

      // Act
      final result = await repository.enableInterface(interfaceName);

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return failure'),
      );
    });
  });
}