import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/certificate_repository.dart';
import 'certificate_event.dart';
import 'certificate_state.dart';

final _log = AppLogger.tag('CertificateBloc');

class CertificateBloc extends Bloc<CertificateEvent, CertificateState> {
  final CertificateRepository repository;

  CertificateBloc({required this.repository}) : super(const CertificateInitial()) {
    on<LoadCertificates>(_onLoadCertificates);
    on<RefreshCertificates>(_onRefreshCertificates);
    on<CreateSelfSignedCertificate>(_onCreateSelfSignedCertificate);
    on<DeleteCertificate>(_onDeleteCertificate);
    
    _log.i('CertificateBloc initialized');
  }

  Future<void> _onLoadCertificates(
    LoadCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateLoading());
    _log.i('Loading certificates...');

    final result = await repository.getCertificates();

    result.fold(
      (failure) {
        _log.e('Failed to load certificates: ${failure.message}');
        emit(CertificateError(failure.message));
      },
      (certificates) {
        _log.i('Loaded ${certificates.length} certificates');
        emit(CertificateLoaded(certificates));
      },
    );
  }

  Future<void> _onRefreshCertificates(
    RefreshCertificates event,
    Emitter<CertificateState> emit,
  ) async {
    _log.i('Refreshing certificates...');
    final result = await repository.getCertificates();

    result.fold(
      (failure) {
        _log.e('Failed to refresh certificates: ${failure.message}');
        emit(CertificateError(failure.message));
      },
      (certificates) {
        _log.i('Refreshed ${certificates.length} certificates');
        emit(CertificateLoaded(certificates));
      },
    );
  }

  Future<void> _onCreateSelfSignedCertificate(
    CreateSelfSignedCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    emit(const CertificateCreating('Creating and signing certificate...'));
    _log.i('Creating self-signed certificate: ${event.name}');

    final result = await repository.createSelfSignedCertificate(
      name: event.name,
      commonName: event.commonName,
      keySize: event.keySize,
      daysValid: event.daysValid,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to create certificate: ${failure.message}');
        emit(CertificateError(failure.message));
      },
      (_) async {
        _log.i('Certificate created successfully');
        // Reload certificates
        final certificatesResult = await repository.getCertificates();
        certificatesResult.fold(
          (failure) => emit(CertificateError(failure.message)),
          (certificates) => emit(CertificateOperationSuccess(
            'Certificate "${event.name}" created successfully',
            certificates,
          )),
        );
      },
    );
  }

  Future<void> _onDeleteCertificate(
    DeleteCertificate event,
    Emitter<CertificateState> emit,
  ) async {
    _log.i('Deleting certificate: ${event.id}');

    final result = await repository.deleteCertificate(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete certificate: ${failure.message}');
        emit(CertificateError(failure.message));
      },
      (_) async {
        _log.i('Certificate deleted successfully');
        // Reload certificates
        final certificatesResult = await repository.getCertificates();
        certificatesResult.fold(
          (failure) => emit(CertificateError(failure.message)),
          (certificates) => emit(CertificateOperationSuccess(
            'Certificate deleted successfully',
            certificates,
          )),
        );
      },
    );
  }
}
