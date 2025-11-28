import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/exceptions.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/data/repositories/hotspot_repository_impl.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';
import 'package:hsmik/features/hotspot/data/models/hotspot_server_model.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late HotspotRepositoryImpl repository;
  late MockHotspotRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockHotspotRemoteDataSource();
    repository = HotspotRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final tServers = [
    HotspotServerModel(
      id: '*1',
      name: 'hotspot1',
      interfaceName: 'ether1',
      addressPool: 'hs-pool',
      disabled: false,
    ),
  ];

  group('HotspotRepositoryImpl', () {
    test('should return Right with servers when getServers succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getServers())
          .thenAnswer((_) async => tServers);

      // Act
      final result = await repository.getServers();

      // Assert
      expect(result, isA<Right<Failure, List<HotspotServer>>>()
          .having((r) => r.value, 'value', tServers));
      verify(() => mockRemoteDataSource.getServers()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });

    test('should return Left with ServerFailure when getServers throws ServerException', () async {
      // Arrange
      when(() => mockRemoteDataSource.getServers())
          .thenThrow(ServerException('Server error'));

      // Act
      final result = await repository.getServers();

      // Assert
      expect(result, const Left(ServerFailure('Server error')));
      verify(() => mockRemoteDataSource.getServers()).called(1);
      verifyNoMoreInteractions(mockRemoteDataSource);
    });
  });
}