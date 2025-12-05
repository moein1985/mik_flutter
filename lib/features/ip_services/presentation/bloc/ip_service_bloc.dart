import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../../certificates/domain/entities/certificate.dart';
import '../../domain/repositories/ip_service_repository.dart';
import 'ip_service_event.dart';
import 'ip_service_state.dart';

final _log = AppLogger.tag('IpServiceBloc');

class IpServiceBloc extends Bloc<IpServiceEvent, IpServiceState> {
  final IpServiceRepository repository;
  List<Certificate> _cachedCertificates = [];

  IpServiceBloc({required this.repository}) : super(const IpServiceInitial()) {
    on<LoadIpServices>(_onLoadServices);
    on<RefreshIpServices>(_onRefreshServices);
    on<ToggleServiceEnabled>(_onToggleServiceEnabled);
    on<UpdateServicePort>(_onUpdateServicePort);
    on<UpdateServiceCertificate>(_onUpdateServiceCertificate);
    on<UpdateServiceAddress>(_onUpdateServiceAddress);
    on<CreateAndAssignCertificateForApiSsl>(_onCreateAndAssignCertificate);
    on<LoadAvailableCertificates>(_onLoadAvailableCertificates);
    
    _log.i('IpServiceBloc initialized');
  }

  Future<void> _onLoadServices(
    LoadIpServices event,
    Emitter<IpServiceState> emit,
  ) async {
    emit(const IpServiceLoading());
    _log.i('Loading IP services...');

    // Load services and certificates in parallel
    final servicesResult = await repository.getServices();
    final certsResult = await repository.getAvailableCertificates();
    
    certsResult.fold(
      (failure) => _log.w('Failed to load certificates: ${failure.message}'),
      (certs) {
        _cachedCertificates = certs;
        _log.i('Loaded ${certs.length} available certificates');
      },
    );

    servicesResult.fold(
      (failure) {
        _log.e('Failed to load services: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (services) {
        _log.i('Loaded ${services.length} services');
        emit(IpServiceLoaded(services, availableCertificates: _cachedCertificates));
      },
    );
  }

  Future<void> _onRefreshServices(
    RefreshIpServices event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('Refreshing IP services...');
    
    // Load services and certificates
    final servicesResult = await repository.getServices();
    final certsResult = await repository.getAvailableCertificates();
    
    certsResult.fold(
      (failure) => _log.w('Failed to load certificates: ${failure.message}'),
      (certs) {
        _cachedCertificates = certs;
        _log.i('Refreshed ${certs.length} certificates');
      },
    );

    servicesResult.fold(
      (failure) {
        _log.e('Failed to refresh services: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (services) {
        _log.i('Refreshed ${services.length} services');
        emit(IpServiceLoaded(services, availableCertificates: _cachedCertificates));
      },
    );
  }
  
  Future<void> _onLoadAvailableCertificates(
    LoadAvailableCertificates event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('Loading available certificates...');
    final result = await repository.getAvailableCertificates();
    
    result.fold(
      (failure) {
        _log.e('Failed to load certificates: ${failure.message}');
      },
      (certs) {
        _cachedCertificates = certs;
        _log.i('Loaded ${certs.length} certificates for dropdown');
        for (final c in certs) {
          _log.d('  - ${c.name} (privateKey=${c.privateKey})');
        }
      },
    );
  }

  Future<void> _onToggleServiceEnabled(
    ToggleServiceEnabled event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('${event.enabled ? "Enabling" : "Disabling"} service ${event.serviceId}');

    final result = await repository.setServiceEnabled(event.serviceId, event.enabled);

    await result.fold(
      (failure) async {
        _log.e('Failed to toggle service: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (_) async {
        // Reload services to get updated state
        final servicesResult = await repository.getServices();
        servicesResult.fold(
          (failure) => emit(IpServiceError(failure.message)),
          (services) => emit(IpServiceOperationSuccess(
            'Service ${event.enabled ? "enabled" : "disabled"} successfully',
            services,
            availableCertificates: _cachedCertificates,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateServicePort(
    UpdateServicePort event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('Updating service ${event.serviceId} port to ${event.port}');

    final result = await repository.setServicePort(event.serviceId, event.port);

    await result.fold(
      (failure) async {
        _log.e('Failed to update port: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (_) async {
        final servicesResult = await repository.getServices();
        servicesResult.fold(
          (failure) => emit(IpServiceError(failure.message)),
          (services) => emit(IpServiceOperationSuccess(
            'Port updated successfully',
            services,
            availableCertificates: _cachedCertificates,
          )),
        );
      },
    );
  }

  Future<void> _onUpdateServiceCertificate(
    UpdateServiceCertificate event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('Updating service ${event.serviceId} certificate to ${event.certificateName}');

    final result = await repository.setServiceCertificate(
      event.serviceId,
      event.certificateName,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to update certificate: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (_) async {
        _log.i('Certificate set successfully, reloading services...');
        final servicesResult = await repository.getServices();
        servicesResult.fold(
          (failure) => emit(IpServiceError(failure.message)),
          (services) {
            // Find the service and log its certificate value
            final apiSslService = services.where((s) => s.id == event.serviceId).firstOrNull;
            if (apiSslService != null) {
              _log.i('Service ${apiSslService.name} certificate after update: ${apiSslService.certificate}');
            }
            emit(IpServiceOperationSuccess(
              'Certificate "${event.certificateName}" assigned successfully',
              services,
              availableCertificates: _cachedCertificates,
            ));
          },
        );
      },
    );
  }

  Future<void> _onUpdateServiceAddress(
    UpdateServiceAddress event,
    Emitter<IpServiceState> emit,
  ) async {
    _log.i('Updating service ${event.serviceId} address to ${event.address}');

    final result = await repository.setServiceAddress(event.serviceId, event.address);

    await result.fold(
      (failure) async {
        _log.e('Failed to update address: ${failure.message}');
        emit(IpServiceError(failure.message));
      },
      (_) async {
        final servicesResult = await repository.getServices();
        servicesResult.fold(
          (failure) => emit(IpServiceError(failure.message)),
          (services) => emit(IpServiceOperationSuccess(
            'Address updated successfully',
            services,
            availableCertificates: _cachedCertificates,
          )),
        );
      },
    );
  }

  Future<void> _onCreateAndAssignCertificate(
    CreateAndAssignCertificateForApiSsl event,
    Emitter<IpServiceState> emit,
  ) async {
    emit(const IpServiceCreatingCertificate('Creating and signing certificate...\nThis may take up to 60 seconds.'));
    _log.i('Creating certificate ${event.certificateName} for api-ssl service ${event.serviceId}');

    // Step 1: Create and sign the certificate
    _log.d('Step 1: Creating certificate...');
    final createResult = await repository.createSelfSignedCertificate(
      event.certificateName,
      event.commonName,
    );

    await createResult.fold(
      (failure) async {
        _log.e('Failed to create certificate: ${failure.message}');
        emit(IpServiceError('Failed to create certificate: ${failure.message}'));
      },
      (_) async {
        _log.i('Certificate created successfully, now assigning to api-ssl');
        
        // Step 2: Assign certificate to api-ssl service
        _log.d('Step 2: Assigning certificate to service ${event.serviceId}...');
        final assignResult = await repository.setServiceCertificate(
          event.serviceId,
          event.certificateName,
        );

        await assignResult.fold(
          (failure) async {
            _log.e('Failed to assign certificate: ${failure.message}');
            emit(IpServiceError('Certificate created but failed to assign: ${failure.message}'));
          },
          (_) async {
            _log.i('Certificate assignment command sent, verifying...');
            
            // Reload certificates cache
            final certsResult = await repository.getAvailableCertificates();
            certsResult.fold(
              (failure) => _log.w('Failed to reload certificates: ${failure.message}'),
              (certs) {
                _cachedCertificates = certs;
                _log.i('Reloaded ${certs.length} certificates');
              },
            );
            
            // Reload services to show updated state
            final servicesResult = await repository.getServices();
            servicesResult.fold(
              (failure) => emit(IpServiceError(failure.message)),
              (services) {
                // Find api-ssl and verify certificate
                final apiSsl = services.where((s) => s.name == 'api-ssl').firstOrNull;
                if (apiSsl != null) {
                  _log.i('api-ssl certificate after assignment: ${apiSsl.certificate}');
                  if (apiSsl.certificate == event.certificateName) {
                    _log.i('✓ Certificate assigned correctly!');
                  } else {
                    _log.w('✗ Certificate mismatch! Expected: ${event.certificateName}, Got: ${apiSsl.certificate}');
                  }
                }
                emit(IpServiceOperationSuccess(
                  'Certificate "${event.certificateName}" created and assigned to api-ssl!',
                  services,
                  availableCertificates: _cachedCertificates,
                ));
              },
            );
          },
        );
      },
    );
  }
}
