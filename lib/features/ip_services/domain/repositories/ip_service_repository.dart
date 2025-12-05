import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../entities/ip_service.dart';

abstract class IpServiceRepository {
  /// Get all IP services from router
  Future<Either<Failure, List<IpService>>> getServices();

  /// Enable or disable a service
  Future<Either<Failure, void>> setServiceEnabled(String id, bool enabled);

  /// Update service port
  Future<Either<Failure, void>> setServicePort(String id, int port);

  /// Update service certificate (for SSL services)
  Future<Either<Failure, void>> setServiceCertificate(String id, String certificateName);

  /// Update service address restriction
  Future<Either<Failure, void>> setServiceAddress(String id, String address);

  /// Create a self-signed certificate
  Future<Either<Failure, void>> createSelfSignedCertificate(String name, String commonName);
  
  /// Get available certificates for selection
  Future<Either<Failure, List<Certificate>>> getAvailableCertificates();
}
