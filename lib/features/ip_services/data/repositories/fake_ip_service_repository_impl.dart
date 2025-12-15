import 'package:dartz/dartz.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/fake_data/fake_data_generator.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../domain/entities/ip_service.dart';
import '../../domain/repositories/ip_service_repository.dart';

/// Fake implementation of IpServiceRepository for development without a real router
class FakeIpServiceRepositoryImpl implements IpServiceRepository {
  // In-memory data store - Standard RouterOS services
  final List<IpService> _services = [
    const IpService(
      id: '1',
      name: 'telnet',
      port: 23,
      address: '',
      disabled: false,
      invalid: false,
    ),
    const IpService(
      id: '2',
      name: 'ftp',
      port: 21,
      address: '',
      disabled: false,
      invalid: false,
    ),
    const IpService(
      id: '3',
      name: 'www',
      port: 80,
      address: '',
      disabled: false,
      invalid: false,
    ),
    const IpService(
      id: '4',
      name: 'ssh',
      port: 22,
      address: '',
      disabled: false,
      invalid: false,
    ),
    const IpService(
      id: '5',
      name: 'www-ssl',
      port: 443,
      address: '',
      certificate: 'self-signed-cert',
      disabled: false,
      invalid: false,
      tlsVersion: 'any',
    ),
    const IpService(
      id: '6',
      name: 'api',
      port: 8728,
      address: '',
      disabled: false,
      invalid: false,
    ),
    const IpService(
      id: '7',
      name: 'api-ssl',
      port: 8729,
      address: '',
      certificate: 'self-signed-cert',
      disabled: false,
      invalid: false,
      tlsVersion: 'any',
    ),
    const IpService(
      id: '8',
      name: 'winbox',
      port: 8291,
      address: '',
      disabled: false,
      invalid: false,
    ),
  ];

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
  ];

  Future<void> _simulateDelay() => Future.delayed(AppConfig.fakeNetworkDelay);

  bool _shouldSimulateError() =>
      FakeDataGenerator.shouldSimulateError(AppConfig.fakeErrorRate);

  @override
  Future<Either<Failure, List<IpService>>> getServices() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load IP services'));
    }
    return Right(List.from(_services));
  }

  @override
  Future<Either<Failure, void>> setServiceEnabled(String id, bool enabled) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update service status'));
    }

    final index = _services.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Service not found'));
    }

    final service = _services[index];
    _services[index] = IpService(
      id: service.id,
      name: service.name,
      port: service.port,
      address: service.address,
      certificate: service.certificate,
      disabled: !enabled,
      invalid: service.invalid,
      vrf: service.vrf,
      maxSessions: service.maxSessions,
      tlsVersion: service.tlsVersion,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setServicePort(String id, int port) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update service port'));
    }

    final index = _services.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Service not found'));
    }

    // Validate port range
    if (port < 1 || port > 65535) {
      return const Left(ServerFailure('Invalid port number (must be 1-65535)'));
    }

    // Check for port conflicts
    if (_services.any((s) => s.id != id && s.port == port && !s.disabled)) {
      return const Left(ServerFailure('Port already in use by another service'));
    }

    final service = _services[index];
    _services[index] = IpService(
      id: service.id,
      name: service.name,
      port: port,
      address: service.address,
      certificate: service.certificate,
      disabled: service.disabled,
      invalid: service.invalid,
      vrf: service.vrf,
      maxSessions: service.maxSessions,
      tlsVersion: service.tlsVersion,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setServiceCertificate(
      String id, String certificateName) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update service certificate'));
    }

    final index = _services.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Service not found'));
    }

    final service = _services[index];

    // Only SSL services can have certificates
    if (!service.requiresCertificate) {
      return const Left(
          ServerFailure('This service does not support certificates'));
    }

    // Validate certificate exists
    if (certificateName != 'none' &&
        !_certificates.any((c) => c.name == certificateName)) {
      return const Left(ServerFailure('Certificate not found'));
    }

    _services[index] = IpService(
      id: service.id,
      name: service.name,
      port: service.port,
      address: service.address,
      certificate: certificateName == 'none' ? null : certificateName,
      disabled: service.disabled,
      invalid: service.invalid,
      vrf: service.vrf,
      maxSessions: service.maxSessions,
      tlsVersion: service.tlsVersion,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> setServiceAddress(
      String id, String address) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to update service address'));
    }

    final index = _services.indexWhere((s) => s.id == id);
    if (index == -1) {
      return const Left(ServerFailure('Service not found'));
    }

    final service = _services[index];
    _services[index] = IpService(
      id: service.id,
      name: service.name,
      port: service.port,
      address: address,
      certificate: service.certificate,
      disabled: service.disabled,
      invalid: service.invalid,
      vrf: service.vrf,
      maxSessions: service.maxSessions,
      tlsVersion: service.tlsVersion,
    );

    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> createSelfSignedCertificate(
      String name, String commonName) async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to create certificate'));
    }

    // Check for duplicate name
    if (_certificates.any((c) => c.name == name)) {
      return const Left(
          ServerFailure('Certificate with this name already exists'));
    }

    final cert = Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      commonName: commonName,
      subjectAltName: '',
      fingerprint: 'FF:EE:DD:CC:BB:AA:99:88:77:66:55:44:33:22:11:00',
      keySize: 2048,
      daysValid: 3650,
      trusted: false,
      ca: false,
    );

    _certificates.add(cert);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Certificate>>> getAvailableCertificates() async {
    await _simulateDelay();
    if (_shouldSimulateError()) {
      return const Left(ServerFailure('Failed to load certificates'));
    }
    return Right(List.from(_certificates));
  }
}
