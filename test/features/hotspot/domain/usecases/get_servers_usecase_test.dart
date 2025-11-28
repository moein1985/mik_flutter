import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_servers_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late GetServersUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = GetServersUseCase(mockRepository);
  });

  const tServers = [
    HotspotServer(
      id: '*1',
      name: 'hotspot1',
      interfaceName: 'ether1',
      addressPool: 'hs-pool',
      disabled: false,
    ),
  ];

  group('GetServersUseCase', () {
    test('should return Right with list of servers when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getServers())
          .thenAnswer((_) async => const Right(tServers));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tServers));
      verify(() => mockRepository.getServers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getServers())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getServers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}