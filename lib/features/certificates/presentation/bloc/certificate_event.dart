import 'package:equatable/equatable.dart';

abstract class CertificateEvent extends Equatable {
  const CertificateEvent();

  @override
  List<Object?> get props => [];
}

class LoadCertificates extends CertificateEvent {
  const LoadCertificates();
}

class RefreshCertificates extends CertificateEvent {
  const RefreshCertificates();
}

class CreateSelfSignedCertificate extends CertificateEvent {
  final String name;
  final String commonName;
  final int keySize;
  final int daysValid;

  const CreateSelfSignedCertificate({
    required this.name,
    required this.commonName,
    this.keySize = 2048,
    this.daysValid = 365,
  });

  @override
  List<Object?> get props => [name, commonName, keySize, daysValid];
}

class DeleteCertificate extends CertificateEvent {
  final String id;

  const DeleteCertificate(this.id);

  @override
  List<Object?> get props => [id];
}
