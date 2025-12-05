import 'package:equatable/equatable.dart';

abstract class IpServiceEvent extends Equatable {
  const IpServiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadIpServices extends IpServiceEvent {
  const LoadIpServices();
}

class RefreshIpServices extends IpServiceEvent {
  const RefreshIpServices();
}

class ToggleServiceEnabled extends IpServiceEvent {
  final String serviceId;
  final bool enabled;

  const ToggleServiceEnabled({required this.serviceId, required this.enabled});

  @override
  List<Object?> get props => [serviceId, enabled];
}

class UpdateServicePort extends IpServiceEvent {
  final String serviceId;
  final int port;

  const UpdateServicePort({required this.serviceId, required this.port});

  @override
  List<Object?> get props => [serviceId, port];
}

class UpdateServiceCertificate extends IpServiceEvent {
  final String serviceId;
  final String certificateName;

  const UpdateServiceCertificate({
    required this.serviceId,
    required this.certificateName,
  });

  @override
  List<Object?> get props => [serviceId, certificateName];
}

class UpdateServiceAddress extends IpServiceEvent {
  final String serviceId;
  final String address;

  const UpdateServiceAddress({required this.serviceId, required this.address});

  @override
  List<Object?> get props => [serviceId, address];
}

/// Create a self-signed certificate and assign it to api-ssl service
class CreateAndAssignCertificateForApiSsl extends IpServiceEvent {
  final String serviceId;
  final String certificateName;
  final String commonName;

  const CreateAndAssignCertificateForApiSsl({
    required this.serviceId,
    required this.certificateName,
    required this.commonName,
  });

  @override
  List<Object?> get props => [serviceId, certificateName, commonName];
}

/// Load available certificates for dropdown selection
class LoadAvailableCertificates extends IpServiceEvent {
  const LoadAvailableCertificates();
}
