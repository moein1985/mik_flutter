import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_user_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late AddUserUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = AddUserUseCase(mockRepository);
  });

  group('AddUserUseCase', () {
    test('should return Right with true when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.addUser(
            name: 'user1',
            password: 'pass',
            profile: 'default',
            server: 'hotspot1',
            comment: 'test',
          )).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(
        name: 'user1',
        password: 'pass',
        profile: 'default',
        server: 'hotspot1',
        comment: 'test',
      );

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.addUser(
            name: 'user1',
            password: 'pass',
            profile: 'default',
            server: 'hotspot1',
            comment: 'test',
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.addUser(
            name: 'user1',
            password: 'pass',
            profile: 'default',
            server: 'hotspot1',
            comment: 'test',
          )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase(
        name: 'user1',
        password: 'pass',
        profile: 'default',
        server: 'hotspot1',
        comment: 'test',
      );

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.addUser(
            name: 'user1',
            password: 'pass',
            profile: 'default',
            server: 'hotspot1',
            comment: 'test',
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}