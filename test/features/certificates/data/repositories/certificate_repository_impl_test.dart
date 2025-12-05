import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/features/certificates/data/repositories/certificate_repository_impl.dart';
import 'package:hsmik/features/certificates/data/models/certificate_model.dart';
import 'package:hsmik/features/certificates/domain/entities/certificate.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late CertificateRepositoryImpl repository;
  late MockCertificateRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCertificateRemoteDataSource();
    repository = CertificateRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  setUpAll(() {
    registerFallbackValue(<String>[]);
    registerFallbackValue(Duration.zero);
  });

  group('getCertificates', () {
    test('should return list of certificates when remote data source succeeds', () async {
      // Arrange
      final tCertificateModels = [
        CertificateModel(
          id: '1',
          name: 'test-cert',
          commonName: 'test.local',
          keySize: 2048,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
          issuer: 'local-ca',
        ),
      ];

      when(() => mockRemoteDataSource.getCertificates())
          .thenAnswer((_) async => tCertificateModels);

      // Act
      final result = await repository.getCertificates();

      // Assert
      expect(result, isA<Right<Failure, List<Certificate>>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (certificates) {
          expect(certificates.length, 1);
          expect(certificates.first.name, 'test-cert');
        },
      );
      verify(() => mockRemoteDataSource.getCertificates()).called(1);
    });

    test('should return ServerFailure when remote data source throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.getCertificates())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.getCertificates();

      // Assert
      expect(result, isA<Left<Failure, List<Certificate>>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (certificates) => fail('Should return Left'),
      );
    });
  });

  group('createSelfSignedCertificate', () {
    const tName = 'test-cert';
    const tCommonName = 'test.local';
    const tKeySize = 2048;
    const tDaysValid = 365;

    test('should return void when remote data source succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
        keySize: tKeySize,
        daysValid: tDaysValid,
      )).thenAnswer((_) async {});

      // Act
      final result = await repository.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
        keySize: tKeySize,
        daysValid: tDaysValid,
      );

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRemoteDataSource.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
        keySize: tKeySize,
        daysValid: tDaysValid,
      )).called(1);
    });

    test('should return ServerFailure when remote data source throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.createSelfSignedCertificate(
        name: any(named: 'name'),
        commonName: any(named: 'commonName'),
        keySize: any(named: 'keySize'),
        daysValid: any(named: 'daysValid'),
      )).thenThrow(Exception('Certificate creation failed'));

      // Act
      final result = await repository.createSelfSignedCertificate(
        name: tName,
        commonName: tCommonName,
        keySize: tKeySize,
        daysValid: tDaysValid,
      );

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('deleteCertificate', () {
    const tId = '*1';

    test('should return void when remote data source succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteCertificate(tId))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.deleteCertificate(tId);

      // Assert
      expect(result, isA<Right<Failure, void>>());
      verify(() => mockRemoteDataSource.deleteCertificate(tId)).called(1);
    });

    test('should return ServerFailure when remote data source throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteCertificate(any()))
          .thenThrow(Exception('Certificate deletion failed'));

      // Act
      final result = await repository.deleteCertificate(tId);

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}