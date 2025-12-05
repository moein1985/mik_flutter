import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../certificates/data/datasources/certificate_remote_data_source.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../domain/entities/ip_service.dart';
import '../../domain/repositories/ip_service_repository.dart';
import '../datasources/ip_service_remote_data_source.dart';

class IpServiceRepositoryImpl implements IpServiceRepository {
  final IpServiceRemoteDataSource remoteDataSource;
  final CertificateRemoteDataSource certificateDataSource;

  IpServiceRepositoryImpl({
    required this.remoteDataSource,
    required this.certificateDataSource,
  });

  @override
  Future<Either<Failure, List<IpService>>> getServices() async {
    try {
      final services = await remoteDataSource.getServices();
      return Right(services.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get services: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setServiceEnabled(String id, bool enabled) async {
    try {
      await remoteDataSource.setServiceEnabled(id, enabled);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update service: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setServicePort(String id, int port) async {
    try {
      await remoteDataSource.setServicePort(id, port);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update port: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setServiceCertificate(String id, String certificateName) async {
    try {
      await remoteDataSource.setServiceCertificate(id, certificateName);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set certificate: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setServiceAddress(String id, String address) async {
    try {
      await remoteDataSource.setServiceAddress(id, address);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createSelfSignedCertificate(String name, String commonName) async {
    try {
      await remoteDataSource.createSelfSignedCertificate(name, commonName);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to create certificate: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Certificate>>> getAvailableCertificates() async {
    try {
      final certificates = await certificateDataSource.getCertificates();
      return Right(certificates.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get certificates: $e'));
    }
  }
}
