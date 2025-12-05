import 'package:equatable/equatable.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../domain/entities/ip_service.dart';

abstract class IpServiceState extends Equatable {
  const IpServiceState();

  @override
  List<Object?> get props => [];
}

class IpServiceInitial extends IpServiceState {
  const IpServiceInitial();
}

class IpServiceLoading extends IpServiceState {
  const IpServiceLoading();
}

class IpServiceLoaded extends IpServiceState {
  final List<IpService> services;
  final List<Certificate> availableCertificates;

  const IpServiceLoaded(this.services, {this.availableCertificates = const []});

  /// Get only manageable services (non-dynamic)
  List<IpService> get manageableServices =>
      services.where((s) => !s.name.contains('resolver') && 
                            !s.name.contains('dhcp') &&
                            !s.name.contains('ntp') &&
                            !s.name.contains('scanner') &&
                            !s.name.contains('snmp') &&
                            !s.name.contains('ipsec') &&
                            !s.name.contains('sstp-server') &&
                            !s.name.contains('l2tp-server') &&
                            !s.name.contains('discover') &&
                            !s.name.contains('agent')).toList();

  /// Get API-related services
  List<IpService> get apiServices =>
      services.where((s) => s.name == 'api' || s.name == 'api-ssl').toList();

  @override
  List<Object?> get props => [services, availableCertificates];
}

class IpServiceOperationSuccess extends IpServiceState {
  final String message;
  final List<IpService> services;
  final List<Certificate> availableCertificates;

  const IpServiceOperationSuccess(this.message, this.services, {this.availableCertificates = const []});

  @override
  List<Object?> get props => [message, services, availableCertificates];
}

class IpServiceError extends IpServiceState {
  final String message;

  const IpServiceError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when creating certificate for api-ssl
class IpServiceCreatingCertificate extends IpServiceState {
  final String message;

  const IpServiceCreatingCertificate(this.message);

  @override
  List<Object?> get props => [message];
}
