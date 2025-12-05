import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';
import '../datasources/certificate_remote_data_source.dart';

class CertificateRepositoryImpl implements CertificateRepository {
  final CertificateRemoteDataSource remoteDataSource;

  CertificateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Certificate>>> getCertificates() async {
    try {
      final certificates = await remoteDataSource.getCertificates();
      return Right(certificates.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get certificates: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  }) async {
    try {
      await remoteDataSource.createSelfSignedCertificate(
        name: name,
        commonName: commonName,
        keySize: keySize,
        daysValid: daysValid,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to create certificate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signCertificate(String name) async {
    try {
      await remoteDataSource.signCertificate(name);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to sign certificate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCertificate(String id) async {
    try {
      await remoteDataSource.deleteCertificate(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete certificate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> exportCertificate(String id, String filePath) async {
    try {
      await remoteDataSource.exportCertificate(id, filePath);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to export certificate: $e'));
    }
  }
}
