import 'package:equatable/equatable.dart';
import '../../domain/entities/acme_provider.dart';
import '../../domain/entities/precheck_result.dart';

abstract class LetsEncryptEvent extends Equatable {
  const LetsEncryptEvent();

  @override
  List<Object?> get props => [];
}

/// Load current Let's Encrypt status
class LoadLetsEncryptStatus extends LetsEncryptEvent {
  const LoadLetsEncryptStatus();
}

/// Run pre-flight checks
class RunPreChecks extends LetsEncryptEvent {
  const RunPreChecks();
}

/// Auto-fix a specific issue
class AutoFixIssue extends LetsEncryptEvent {
  final PreCheckType checkType;

  const AutoFixIssue(this.checkType);

  @override
  List<Object?> get props => [checkType];
}

/// Request a Let's Encrypt certificate
class RequestCertificate extends LetsEncryptEvent {
  final String dnsName;
  final AcmeProvider provider;

  const RequestCertificate({
    required this.dnsName,
    this.provider = AcmeProvider.letsEncrypt,
  });

  @override
  List<Object?> get props => [dnsName, provider];
}

/// Revoke/delete existing certificate
class RevokeCertificate extends LetsEncryptEvent {
  final String certificateName;

  const RevokeCertificate(this.certificateName);

  @override
  List<Object?> get props => [certificateName];
}

/// Reset wizard state
class ResetWizard extends LetsEncryptEvent {
  const ResetWizard();
}
