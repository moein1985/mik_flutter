import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_active_user.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_active_users_usecase.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late GetActiveUsersUseCase usecase;
  late MockHotspotRepository mockRepository;

  setUp(() {
    mockRepository = MockHotspotRepository();
    usecase = GetActiveUsersUseCase(mockRepository);
  });

  const tActiveUsers = [
    HotspotActiveUser(
      id: '*1',
      user: 'user1',
      server: 'hotspot1',
      address: '192.168.1.100',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      loginBy: 'http-chap',
      uptime: '1d2h3m',
      sessionTimeLeft: '2h30m',
      idleTime: '5m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    ),
  ];

  group('GetActiveUsersUseCase', () {
    test('should return Right with list of active users when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.getActiveUsers())
          .thenAnswer((_) async => const Right(tActiveUsers));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tActiveUsers));
      verify(() => mockRepository.getActiveUsers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left with ServerFailure when repository fails', () async {
      // Arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockRepository.getActiveUsers())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.getActiveUsers()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}