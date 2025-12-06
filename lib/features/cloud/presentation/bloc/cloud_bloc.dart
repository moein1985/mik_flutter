import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/cloud_repository.dart';
import 'cloud_event.dart';
import 'cloud_state.dart';

final _log = AppLogger.tag('CloudBloc');

class CloudBloc extends Bloc<CloudEvent, CloudState> {
  final CloudRepository repository;

  CloudBloc({required this.repository}) : super(const CloudInitial()) {
    _log.i('CloudBloc initialized');

    on<LoadCloudStatus>(_onLoadCloudStatus);
    on<EnableCloudDdns>(_onEnableDdns);
    on<DisableCloudDdns>(_onDisableDdns);
    on<ForceUpdateDdns>(_onForceUpdate);
    on<SetDdnsUpdateInterval>(_onSetUpdateInterval);
    on<SetCloudUpdateTime>(_onSetUpdateTime);
  }

  Future<void> _onLoadCloudStatus(
    LoadCloudStatus event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Loading cloud status...');
    emit(const CloudLoading());

    final result = await repository.getCloudStatus();

    result.fold(
      (failure) {
        _log.e('Failed to load cloud status: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (status) {
        _log.i('Cloud status loaded: DDNS=${status.ddnsEnabled}, Supported=${status.isSupported}');
        emit(CloudLoaded(status));
      },
    );
  }

  Future<void> _onEnableDdns(
    EnableCloudDdns event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Enabling DDNS...');
    final previousStatus = state is CloudLoaded ? (state as CloudLoaded).status : null;
    emit(CloudOperationInProgress('Enabling DDNS...', currentStatus: previousStatus));

    final result = await repository.enableDdns();

    result.fold(
      (failure) {
        _log.e('Failed to enable DDNS: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (_) {
        _log.i('DDNS enabled successfully');
        emit(CloudOperationSuccess('DDNS enabled successfully', previousStatus: previousStatus));
        add(const LoadCloudStatus());
      },
    );
  }

  Future<void> _onDisableDdns(
    DisableCloudDdns event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Disabling DDNS...');
    final previousStatus = state is CloudLoaded ? (state as CloudLoaded).status : null;
    emit(CloudOperationInProgress('Disabling DDNS...', currentStatus: previousStatus));

    final result = await repository.disableDdns();

    result.fold(
      (failure) {
        _log.e('Failed to disable DDNS: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (_) {
        _log.i('DDNS disabled successfully');
        emit(CloudOperationSuccess('DDNS disabled successfully', previousStatus: previousStatus));
        add(const LoadCloudStatus());
      },
    );
  }

  Future<void> _onForceUpdate(
    ForceUpdateDdns event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Forcing DDNS update...');
    final previousStatus = state is CloudLoaded ? (state as CloudLoaded).status : null;
    emit(CloudOperationInProgress('Updating DDNS...', currentStatus: previousStatus));

    final result = await repository.forceUpdate();

    result.fold(
      (failure) {
        _log.e('Failed to force update DDNS: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (_) {
        _log.i('DDNS force update triggered');
        emit(CloudOperationSuccess('DDNS update triggered', previousStatus: previousStatus));
        // Wait a bit for the update to complete then reload
        Future.delayed(const Duration(seconds: 2), () {
          add(const LoadCloudStatus());
        });
      },
    );
  }

  Future<void> _onSetUpdateInterval(
    SetDdnsUpdateInterval event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Setting DDNS update interval to ${event.interval}...');
    final previousStatus = state is CloudLoaded ? (state as CloudLoaded).status : null;

    final result = await repository.setUpdateInterval(event.interval);

    result.fold(
      (failure) {
        _log.e('Failed to set update interval: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (_) {
        _log.i('Update interval set successfully');
        emit(CloudOperationSuccess('Update interval changed', previousStatus: previousStatus));
        add(const LoadCloudStatus());
      },
    );
  }

  Future<void> _onSetUpdateTime(
    SetCloudUpdateTime event,
    Emitter<CloudState> emit,
  ) async {
    _log.i('Setting update time to ${event.enabled}...');
    final previousStatus = state is CloudLoaded ? (state as CloudLoaded).status : null;

    final result = await repository.setUpdateTime(event.enabled);

    result.fold(
      (failure) {
        _log.e('Failed to set update time: ${failure.message}');
        emit(CloudError(failure.message));
      },
      (_) {
        _log.i('Update time setting changed');
        emit(CloudOperationSuccess('Update time setting changed', previousStatus: previousStatus));
        add(const LoadCloudStatus());
      },
    );
  }
}
