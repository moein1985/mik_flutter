import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/certificate.dart';

abstract class CertificateRepository {
  /// Get all certificates from router
  Future<Either<Failure, List<Certificate>>> getCertificates();

  /// Create a new self-signed certificate
  Future<Either<Failure, void>> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  });

  /// Sign a certificate (make it trusted)
  Future<Either<Failure, void>> signCertificate(String name);

  /// Delete a certificate
  Future<Either<Failure, void>> deleteCertificate(String id);

  /// Export certificate
  Future<Either<Failure, void>> exportCertificate(String id, String filePath);
}
