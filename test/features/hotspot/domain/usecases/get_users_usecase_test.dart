import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_user.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_users_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late GetUsersUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = GetUsersUseCase(mockRepository);
  });

  const tUsers = [
    HotspotUser(
      id: '*1',
      name: 'user1',
      disabled: false,
    ),
  ];

  group('GetUsersUseCase', () {
    test('should return Right with list of users when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getUsers())
          .thenAnswer((_) async => const Right(tUsers));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tUsers));
      verify(() => mockRepository.getUsers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getUsers())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getUsers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}