import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/precheck_result.dart';
import '../../domain/repositories/letsencrypt_repository.dart';
import 'letsencrypt_event.dart';
import 'letsencrypt_state.dart';

final _log = AppLogger.tag('LetsEncryptBloc');

class LetsEncryptBloc extends Bloc<LetsEncryptEvent, LetsEncryptState> {
  final LetsEncryptRepository repository;

  LetsEncryptBloc({required this.repository}) : super(const LetsEncryptInitial()) {
    on<LoadLetsEncryptStatus>(_onLoadStatus);
    on<RunPreChecks>(_onRunPreChecks);
    on<AutoFixIssue>(_onAutoFix);
    on<AutoFixAll>(_onAutoFixAll);
    on<RequestCertificate>(_onRequestCertificate);
    on<RevokeCertificate>(_onRevokeCertificate);
    on<ResetWizard>(_onResetWizard);

    _log.i('LetsEncryptBloc initialized');
  }

  Future<void> _onLoadStatus(
    LoadLetsEncryptStatus event,
    Emitter<LetsEncryptState> emit,
  ) async {
    emit(const LetsEncryptLoading(message: 'loadingStatus'));
    _log.i('Loading Let\'s Encrypt status...');

    final result = await repository.getStatus();

    result.fold(
      (failure) {
        _log.e('Failed to load status: ${failure.message}');
        emit(LetsEncryptError(failure.message, errorKey: 'loadStatusFailed'));
      },
      (status) {
        _log.i('Status loaded: hasCert=${status.hasCertificate}');
        emit(LetsEncryptStatusLoaded(status));
      },
    );
  }

  Future<void> _onRunPreChecks(
    RunPreChecks event,
    Emitter<LetsEncryptState> emit,
  ) async {
    emit(const LetsEncryptLoading(message: 'runningPreChecks'));
    _log.i('Running pre-flight checks...');

    final result = await repository.runPreChecks();

    result.fold(
      (failure) {
        _log.e('Pre-checks failed: ${failure.message}');
        emit(LetsEncryptError(failure.message, errorKey: 'preChecksFailed'));
      },
      (preCheckResult) {
        _log.i('Pre-checks completed: allPassed=${preCheckResult.allPassed}');
        emit(PreChecksCompleted(preCheckResult));
      },
    );
  }

  Future<void> _onAutoFix(
    AutoFixIssue event,
    Emitter<LetsEncryptState> emit,
  ) async {
    emit(AutoFixInProgress(event.checkType));
    _log.i('Auto-fixing: ${event.checkType}');

    final result = await repository.autoFix(event.checkType);

    final failed = result.fold(
      (failure) {
        _log.e('Auto-fix failed: ${failure.message}');
        emit(LetsEncryptError(failure.message, errorKey: 'autoFixFailed'));
        return true;
      },
      (success) {
        _log.i('Auto-fix successful for ${event.checkType}');
        emit(AutoFixSuccess(
          checkType: event.checkType,
          message: 'autoFixSuccess',
        ));
        return false;
      },
    );
    
    if (failed) return;
    
    // Add delay for RouterOS to apply changes
    // Especially important for Cloud DDNS which may take time to sync
    if (event.checkType == PreCheckType.cloudEnabled) {
      _log.d('Waiting 5 seconds for Cloud DDNS to sync...');
      await Future.delayed(const Duration(seconds: 5));
    } else {
      _log.d('Waiting 2 seconds for changes to apply...');
      await Future.delayed(const Duration(seconds: 2));
    }
    
    // Re-run pre-checks after single auto-fix
    add(const RunPreChecks());
  }

  Future<void> _onAutoFixAll(
    AutoFixAll event,
    Emitter<LetsEncryptState> emit,
  ) async {
    _log.i('Auto-fixing all ${event.checkTypes.length} issues...');
    
    for (final checkType in event.checkTypes) {
      emit(AutoFixInProgress(checkType));
      _log.i('Auto-fixing: $checkType');

      final result = await repository.autoFix(checkType);

      final failed = result.fold(
        (failure) {
          _log.e('Auto-fix failed for $checkType: ${failure.message}');
          emit(LetsEncryptError(failure.message, errorKey: 'autoFixFailed'));
          return true;
        },
        (success) {
          _log.i('Auto-fix successful for $checkType');
          return false;
        },
      );
      
      if (failed) return; // Stop on first failure
    }
    
    // All fixes successful
    _log.i('All auto-fixes completed successfully');
    emit(const AutoFixSuccess(
      checkType: PreCheckType.cloudEnabled, // dummy, won't be shown
      message: 'allIssuesFixed',
    ));
    
    // Add delay for RouterOS to apply all changes
    // Cloud DDNS may take up to 60 seconds for first update
    if (event.checkTypes.contains(PreCheckType.cloudEnabled)) {
      _log.d('Waiting 5 seconds for Cloud DDNS to sync...');
      await Future.delayed(const Duration(seconds: 5));
    } else {
      _log.d('Waiting 2 seconds for changes to apply...');
      await Future.delayed(const Duration(seconds: 2));
    }
    
    // Run pre-checks once
    add(const RunPreChecks());
  }

  Future<void> _onRequestCertificate(
    RequestCertificate event,
    Emitter<LetsEncryptState> emit,
  ) async {
    emit(CertificateRequesting(
      dnsName: event.dnsName,
      message: 'requestingCertificate',
    ));
    _log.i('Requesting certificate for: ${event.dnsName}');

    // First, add temporary firewall rule if needed
    String? tempRuleId;
    final firewallResult = await repository.addTemporaryFirewallRule();
    firewallResult.fold(
      (failure) => _log.w('Could not add temp firewall rule: ${failure.message}'),
      (ruleId) {
        tempRuleId = ruleId;
        _log.i('Added temporary firewall rule: $ruleId');
      },
    );

    // Request the certificate
    final result = await repository.requestCertificate(
      dnsName: event.dnsName,
      provider: event.provider,
    );

    // Clean up temporary firewall rule
    if (tempRuleId != null) {
      await repository.removeTemporaryFirewallRule(tempRuleId!);
      _log.i('Removed temporary firewall rule');
    }

    result.fold(
      (failure) {
        _log.e('Certificate request failed: ${failure.message}');
        emit(LetsEncryptError(failure.message, errorKey: 'certificateRequestFailed'));
      },
      (success) {
        _log.i('Certificate request successful');
        emit(const CertificateRequestSuccess('certificateIssued'));
      },
    );
  }

  Future<void> _onRevokeCertificate(
    RevokeCertificate event,
    Emitter<LetsEncryptState> emit,
  ) async {
    emit(const RevokeInProgress());
    _log.i('Revoking certificate: ${event.certificateName}');

    final result = await repository.revokeCertificate(event.certificateName);

    result.fold(
      (failure) {
        _log.e('Revoke failed: ${failure.message}');
        emit(LetsEncryptError(failure.message, errorKey: 'revokeFailed'));
      },
      (success) {
        _log.i('Certificate revoked successfully');
        emit(const RevokeSuccess('certificateRevoked'));
        // Reload status
        add(const LoadLetsEncryptStatus());
      },
    );
  }

  void _onResetWizard(
    ResetWizard event,
    Emitter<LetsEncryptState> emit,
  ) {
    _log.i('Resetting wizard state');
    emit(const LetsEncryptInitial());
  }
}
