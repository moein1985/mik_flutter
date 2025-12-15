import 'package:equatable/equatable.dart';
import '../../domain/entities/letsencrypt_status.dart';
import '../../domain/entities/precheck_result.dart';

sealed class LetsEncryptState extends Equatable {
  const LetsEncryptState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class LetsEncryptInitial extends LetsEncryptState {
  const LetsEncryptInitial();
}

/// Loading status
final class LetsEncryptLoading extends LetsEncryptState {
  final String? message;

  const LetsEncryptLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Status loaded successfully
final class LetsEncryptStatusLoaded extends LetsEncryptState {
  final LetsEncryptStatus status;

  const LetsEncryptStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

/// Pre-checks completed
final class PreChecksCompleted extends LetsEncryptState {
  final PreCheckResult result;

  const PreChecksCompleted(this.result);

  @override
  List<Object?> get props => [result];
}

/// Auto-fix in progress
final class AutoFixInProgress extends LetsEncryptState {
  final PreCheckType checkType;

  const AutoFixInProgress(this.checkType);

  @override
  List<Object?> get props => [checkType];
}

/// Auto-fix completed successfully
final class AutoFixSuccess extends LetsEncryptState {
  final PreCheckType checkType;
  final String message;

  const AutoFixSuccess({required this.checkType, required this.message});

  @override
  List<Object?> get props => [checkType, message];
}

/// Requesting certificate
final class CertificateRequesting extends LetsEncryptState {
  final String dnsName;
  final String message;

  const CertificateRequesting({required this.dnsName, required this.message});

  @override
  List<Object?> get props => [dnsName, message];
}

/// Certificate request successful
final class CertificateRequestSuccess extends LetsEncryptState {
  final String message;

  const CertificateRequestSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Revoke in progress
class RevokeInProgress extends LetsEncryptState {
  const RevokeInProgress();
}

/// Revoke successful
class RevokeSuccess extends LetsEncryptState {
  final String message;

  const RevokeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class LetsEncryptError extends LetsEncryptState {
  final String message;
  final String? errorKey; // Localization key for error

  const LetsEncryptError(this.message, {this.errorKey});

  @override
  List<Object?> get props => [message, errorKey];
}
