import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/repositories/certificate_repository.dart';

/// Fake implementation of CertificateRepository for development without a real router
class FakeCertificateRepositoryImpl implements CertificateRepository {
  // In-memory data store
  final List<Certificate> _certificates = [
    Certificate(
      id: '1',
      name: 'self-signed-cert',
      commonName: 'MikroTik',
      subjectAltName: '',
      fingerprint: 'AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00',
      keySize: 2048,
      daysValid: 3650,
      trusted: false,
      ca: false,
    ),
    Certificate(
      id: '2',
      name: 'letsencrypt-cert',
      commonName: 'router.example.com',
      subjectAltName: 'DNS:router.example.com',
      fingerprint: '11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00',
      keySize: 2048,
      daysValid: 90,
      trusted: true,
      ca: false,
    ),
    Certificate(
      id: '3',
      name: 'expired-cert',
      commonName: 'old.mikrotik.local',
      subjectAltName: '',
      fingerprint: '99:88:77:66:55:44:33:22:11:00:FF:EE:DD:CC:BB:AA',
      keySize: 2048,
      daysValid: -30,
      trusted: false,
      ca: false,
      expired: true,
    ),
  ];

  Future<void> _simulateDelay() => Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  @override
  Future<Either<Failure, List<Certificate>>> getCertificates() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load certificates'));
    }
    return Right(List.from(_certificates));
  }

  @override
  Future<Either<Failure, void>> createSelfSignedCertificate({
    required String name,
    required String commonName,
    int keySize = 2048,
    int daysValid = 365,
  }) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to create certificate'));
    }

    // Check for duplicate name
    if (_certificates.any((c) => c.name == name)) {
      return const Left(
          ServerFailure('Certificate with this name already exists'));
    }

    // Generate random fingerprint
    final fingerprint = List.generate(
      16,
      (i) => (i * 17 + name.hashCode) % 256,
    ).map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');

    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      commonName: commonName,
      subjectAltName: '',
      fingerprint: fingerprint,
      keySize: keySize,
      daysValid: daysValid,
      trusted: false,
      ca: false,
    );

    _certificates.add(cert);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> signCertificate(String name) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to sign certificate'));
    }

    final index = _certificates.indexWhere((c) => c.name == name);
    if (index == -1) {
      return const Left(ServerFailure('Certificate not found'));
    }

    final cert = _certificates[index];
    _certificates[index] = Certificate(
      id: cert.id,
      name: cert.name,
      commonName: cert.commonName,
      subjectAltName: cert.subjectAltName,
      fingerprint: cert.fingerprint,
      keySize: cert.keySize,
      daysValid: cert.daysValid,
      trusted: true,
      ca: cert.ca,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteCertificate(String id) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to delete certificate'));
    }

    final existed = _certificates.any((c) => c.id == id);
    if (!existed) {
      return const Left(ServerFailure('Certificate not found'));
    }

    _certificates.removeWhere((c) => c.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> exportCertificate(
      String id, String filePath) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to export certificate'));
    }

    // Check if certificate exists
    if (!_certificates.any((c) => c.id == id)) {
      return const Left(ServerFailure('Certificate not found'));
    }

    // Simulate file export (in real implementation would save to file)
    // Just validate the path
    if (filePath.isEmpty) {
      return const Left(ServerFailure('Invalid file path'));
    }

    return const Right(null);
  }
}
