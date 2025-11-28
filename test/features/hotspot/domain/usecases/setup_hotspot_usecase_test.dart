import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/usecases/setup_hotspot_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late SetupHotspotUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = SetupHotspotUseCase(mockRepository);
  });

  group('SetupHotspotUseCase', () {
    test('should return Right with true when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.setupHotspot(
            interface: 'ether1',
            addressPool: 'hs-pool',
            dnsName: 'hotspot.local',
          )).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        interface: 'ether1',
        addressPool: 'hs-pool',
        dnsName: 'hotspot.local',
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.setupHotspot(
            interface: 'ether1',
            addressPool: 'hs-pool',
            dnsName: 'hotspot.local',
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.setupHotspot(
            interface: 'ether1',
            addressPool: 'hs-pool',
            dnsName: 'hotspot.local',
          )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(
        interface: 'ether1',
        addressPool: 'hs-pool',
        dnsName: 'hotspot.local',
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.setupHotspot(
            interface: 'ether1',
            addressPool: 'hs-pool',
            dnsName: 'hotspot.local',
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}