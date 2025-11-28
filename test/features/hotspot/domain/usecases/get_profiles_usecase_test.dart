import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_profile.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_profiles_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late GetProfilesUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = GetProfilesUseCase(mockRepository);
  });

  const tProfiles = [
    HotspotProfile(
      id: '*1',
      name: 'default',
    ),
  ];

  group('GetProfilesUseCase', () {
    test('should return Right with list of profiles when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getProfiles())
          .thenAnswer((_) async => const Right(tProfiles));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tProfiles));
      verify(() => mockRepository.getProfiles()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getProfiles())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getProfiles()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}