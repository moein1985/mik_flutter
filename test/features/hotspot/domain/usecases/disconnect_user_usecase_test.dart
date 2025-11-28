import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/usecases/disconnect_user_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late DisconnectUserUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = DisconnectUserUseCase(mockRepository);
  });

  group('DisconnectUserUseCase', () {
    test('should return Right with true when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.disconnectUser('*1'))
          .thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase('*1');

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.disconnectUser('*1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.disconnectUser('*1'))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase('*1');

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.disconnectUser('*1')).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}