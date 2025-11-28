import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/usecases/toggle_user_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late ToggleUserUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = ToggleUserUseCase(mockRepository);
  });

  group('ToggleUserUseCase', () {
    test('should return Right with true when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.enableUser('*1'))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(id: '*1', enable: true);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.enableUser('*1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call disableUser when enable is false', () async {
      // Arrange
      when(() => mockRepository.disableUser('*1'))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(id: '*1', enable: false);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.disableUser('*1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.enableUser('*1'))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(id: '*1', enable: true);

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.enableUser('*1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}