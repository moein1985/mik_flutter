import 'package:equatable/equatable.dart';
import '../../domain/entities/certificate.dart';

sealed class CertificateState extends Equatable {
  const CertificateState();

  @override
  List<Object?> get props => [];
}

final class CertificateInitial extends CertificateState {
  const CertificateInitial();
}

final class CertificateLoading extends CertificateState {
  const CertificateLoading();
}

final class CertificateLoaded extends CertificateState {
  final List<Certificate> certificates;

  const CertificateLoaded(this.certificates);

  /// Get certificates that can be used for SSL services
  List<Certificate> get sslCapableCertificates =>
      certificates.where((c) => c.canBeUsedForSsl).toList();

  @override
  List<Object?> get props => [certificates];
}

final class CertificateOperationSuccess extends CertificateState {
  final String message;
  final List<Certificate> certificates;

  const CertificateOperationSuccess(this.message, this.certificates);

  @override
  List<Object?> get props => [message, certificates];
}

final class CertificateCreating extends CertificateState {
  final String message;

  const CertificateCreating(this.message);

  @override
  List<Object?> get props => [message];
}

final class CertificateError extends CertificateState {
  final String message;

  const CertificateError(this.message);

  @override
  List<Object?> get props => [message];
}
