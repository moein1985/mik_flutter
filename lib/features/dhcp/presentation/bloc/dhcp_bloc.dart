import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/dhcp_repository.dart';
import 'dhcp_event.dart';
import 'dhcp_state.dart';

final _log = AppLogger.tag('DhcpBloc');

class DhcpBloc extends Bloc<DhcpEvent, DhcpState> {
  final DhcpRepository repository;

  DhcpBloc({required this.repository}) : super(const DhcpInitial()) {
    _log.i('DhcpBloc initialized');

    // Server events
    on<LoadDhcpServers>(_onLoadServers);
    on<AddDhcpServer>(_onAddServer);
    on<EditDhcpServer>(_onEditServer);
    on<RemoveDhcpServer>(_onRemoveServer);
    on<EnableDhcpServer>(_onEnableServer);
    on<DisableDhcpServer>(_onDisableServer);

    // Network events
    on<LoadDhcpNetworks>(_onLoadNetworks);
    on<AddDhcpNetwork>(_onAddNetwork);
    on<EditDhcpNetwork>(_onEditNetwork);
    on<RemoveDhcpNetwork>(_onRemoveNetwork);

    // Lease events
    on<LoadDhcpLeases>(_onLoadLeases);
    on<AddDhcpLease>(_onAddLease);
    on<RemoveDhcpLease>(_onRemoveLease);
    on<MakeDhcpLeaseStatic>(_onMakeLeaseStatic);
    on<EnableDhcpLease>(_onEnableLease);
    on<DisableDhcpLease>(_onDisableLease);

    // Setup data
    on<LoadDhcpSetupData>(_onLoadSetupData);
    on<AddIpPool>(_onAddIpPool);
  }

  // ==================== Server Handlers ====================

  Future<void> _onLoadServers(
    LoadDhcpServers event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Loading DHCP servers...');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    
    if (previousData == null) {
      emit(const DhcpLoading());
    }

    final result = await repository.getServers();

    result.fold(
      (failure) {
        _log.e('Failed to load servers: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (servers) {
        _log.i('Loaded ${servers.length} servers');
        if (previousData != null) {
          emit(previousData.copyWith(servers: servers));
        } else {
          emit(DhcpLoaded(servers: servers));
        }
      },
    );
  }

  Future<void> _onAddServer(
    AddDhcpServer event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Adding DHCP server: ${event.name}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.addServer(
      name: event.name,
      interface: event.interface,
      addressPool: event.addressPool,
      leaseTime: event.leaseTime,
      authoritative: event.authoritative,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to add server: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) async {
        _log.i('Server added successfully');
        
        // Automatically create network if network parameters provided
        if (event.networkAddress != null && event.networkAddress!.isNotEmpty) {
          _log.i('Creating network for: ${event.networkAddress}');
          final networkResult = await repository.addNetwork(
            address: event.networkAddress!,
            gateway: event.gateway,
            dnsServer: event.dnsServer,
          );
          
          networkResult.fold(
            (failure) {
              _log.w('Failed to create network (server was created): ${failure.message}');
              // Server was created but network failed - still show success with warning
              emit(DhcpOperationSuccess('DHCP server added (network creation failed: ${failure.message})', previousData: previousData));
            },
            (_) {
              _log.i('Network created successfully');
              emit(DhcpOperationSuccess('DHCP server and network added', previousData: previousData));
            },
          );
        } else {
          emit(DhcpOperationSuccess('DHCP server added', previousData: previousData));
        }
        add(const LoadDhcpServers());
      },
    );
  }

  Future<void> _onEditServer(
    EditDhcpServer event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Editing DHCP server: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.editServer(
      id: event.id,
      name: event.name,
      interface: event.interface,
      addressPool: event.addressPool,
      leaseTime: event.leaseTime,
      authoritative: event.authoritative,
    );

    result.fold(
      (failure) {
        _log.e('Failed to edit server: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Server edited successfully');
        emit(DhcpOperationSuccess('DHCP server updated', previousData: previousData));
        add(const LoadDhcpServers());
      },
    );
  }

  Future<void> _onRemoveServer(
    RemoveDhcpServer event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Removing DHCP server: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.removeServer(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to remove server: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Server removed successfully');
        emit(DhcpOperationSuccess('DHCP server removed', previousData: previousData));
        add(const LoadDhcpServers());
      },
    );
  }

  Future<void> _onEnableServer(
    EnableDhcpServer event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Enabling DHCP server: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;

    final result = await repository.enableServer(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to enable server: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Server enabled successfully');
        emit(DhcpOperationSuccess('DHCP server enabled', previousData: previousData));
        add(const LoadDhcpServers());
      },
    );
  }

  Future<void> _onDisableServer(
    DisableDhcpServer event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Disabling DHCP server: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;

    final result = await repository.disableServer(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to disable server: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Server disabled successfully');
        emit(DhcpOperationSuccess('DHCP server disabled', previousData: previousData));
        add(const LoadDhcpServers());
      },
    );
  }

  // ==================== Network Handlers ====================

  Future<void> _onLoadNetworks(
    LoadDhcpNetworks event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Loading DHCP networks...');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    
    if (previousData == null) {
      emit(const DhcpLoading());
    }

    final result = await repository.getNetworks();

    result.fold(
      (failure) {
        _log.e('Failed to load networks: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (networks) {
        _log.i('Loaded ${networks.length} networks');
        if (previousData != null) {
          emit(previousData.copyWith(networks: networks));
        } else {
          emit(DhcpLoaded(networks: networks));
        }
      },
    );
  }

  Future<void> _onAddNetwork(
    AddDhcpNetwork event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Adding DHCP network: ${event.address}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.addNetwork(
      address: event.address,
      gateway: event.gateway,
      netmask: event.netmask,
      dnsServer: event.dnsServer,
      domain: event.domain,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        _log.e('Failed to add network: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Network added successfully');
        emit(DhcpOperationSuccess('DHCP network added', previousData: previousData));
        add(const LoadDhcpNetworks());
      },
    );
  }

  Future<void> _onEditNetwork(
    EditDhcpNetwork event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Editing DHCP network: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.editNetwork(
      id: event.id,
      address: event.address,
      gateway: event.gateway,
      netmask: event.netmask,
      dnsServer: event.dnsServer,
      domain: event.domain,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        _log.e('Failed to edit network: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Network edited successfully');
        emit(DhcpOperationSuccess('DHCP network updated', previousData: previousData));
        add(const LoadDhcpNetworks());
      },
    );
  }

  Future<void> _onRemoveNetwork(
    RemoveDhcpNetwork event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Removing DHCP network: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.removeNetwork(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to remove network: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Network removed successfully');
        emit(DhcpOperationSuccess('DHCP network removed', previousData: previousData));
        add(const LoadDhcpNetworks());
      },
    );
  }

  // ==================== Lease Handlers ====================

  Future<void> _onLoadLeases(
    LoadDhcpLeases event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Loading DHCP leases...');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    
    if (previousData == null) {
      emit(const DhcpLoading());
    }

    final result = await repository.getLeases();

    result.fold(
      (failure) {
        _log.e('Failed to load leases: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (leases) {
        _log.i('Loaded ${leases.length} leases');
        if (previousData != null) {
          emit(previousData.copyWith(leases: leases));
        } else {
          emit(DhcpLoaded(leases: leases));
        }
      },
    );
  }

  Future<void> _onAddLease(
    AddDhcpLease event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Adding DHCP lease: ${event.address}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.addLease(
      address: event.address,
      macAddress: event.macAddress,
      server: event.server,
      comment: event.comment,
    );

    result.fold(
      (failure) {
        _log.e('Failed to add lease: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Lease added successfully');
        emit(DhcpOperationSuccess('DHCP lease added', previousData: previousData));
        add(const LoadDhcpLeases());
      },
    );
  }

  Future<void> _onRemoveLease(
    RemoveDhcpLease event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Removing DHCP lease: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;
    emit(const DhcpLoading());

    final result = await repository.removeLease(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to remove lease: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Lease removed successfully');
        emit(DhcpOperationSuccess('DHCP lease removed', previousData: previousData));
        add(const LoadDhcpLeases());
      },
    );
  }

  Future<void> _onMakeLeaseStatic(
    MakeDhcpLeaseStatic event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Making lease static: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;

    final result = await repository.makeStatic(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to make lease static: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Lease made static successfully');
        emit(DhcpOperationSuccess('Lease made static', previousData: previousData));
        add(const LoadDhcpLeases());
      },
    );
  }

  Future<void> _onEnableLease(
    EnableDhcpLease event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Enabling DHCP lease: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;

    final result = await repository.enableLease(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to enable lease: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Lease enabled successfully');
        emit(DhcpOperationSuccess('Lease enabled', previousData: previousData));
        add(const LoadDhcpLeases());
      },
    );
  }

  Future<void> _onDisableLease(
    DisableDhcpLease event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Disabling DHCP lease: ${event.id}');
    final previousData = state is DhcpLoaded ? state as DhcpLoaded : null;

    final result = await repository.disableLease(event.id);

    result.fold(
      (failure) {
        _log.e('Failed to disable lease: ${failure.message}');
        emit(DhcpError(failure.message));
      },
      (_) {
        _log.i('Lease disabled successfully');
        emit(DhcpOperationSuccess('Lease disabled', previousData: previousData));
        add(const LoadDhcpLeases());
      },
    );
  }

  // ==================== Setup Data Handler ====================

  Future<void> _onLoadSetupData(
    LoadDhcpSetupData event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Loading DHCP setup data...');
    emit(const DhcpLoading());

    final interfacesResult = await repository.getInterfaces();
    final poolsResult = await repository.getIpPools();

    List<Map<String, String>> interfaces = [];
    List<Map<String, String>> pools = [];

    interfacesResult.fold(
      (failure) => _log.e('Failed to load interfaces: ${failure.message}'),
      (data) {
        interfaces = data;
        _log.i('Loaded ${data.length} interfaces');
      },
    );

    poolsResult.fold(
      (failure) => _log.e('Failed to load pools: ${failure.message}'),
      (data) {
        pools = data;
        _log.i('Loaded ${data.length} pools');
      },
    );

    emit(DhcpSetupDataLoaded(interfaces: interfaces, ipPools: pools));
  }

  Future<void> _onAddIpPool(
    AddIpPool event,
    Emitter<DhcpState> emit,
  ) async {
    _log.i('Adding IP pool: ${event.name}');
    
    // Keep current setup data if available
    DhcpSetupDataLoaded? currentSetupData;
    if (state is DhcpSetupDataLoaded) {
      currentSetupData = state as DhcpSetupDataLoaded;
    }

    final result = await repository.addIpPool(
      name: event.name,
      ranges: event.ranges,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to add IP pool: ${failure.message}');
        emit(DhcpError(failure.message));
        // Restore setup data if we had it
        if (currentSetupData != null) {
          emit(currentSetupData);
        }
      },
      (_) async {
        _log.i('IP pool added successfully');
        
        // Reload pools to get updated list
        final poolsResult = await repository.getIpPools();
        
        poolsResult.fold(
          (failure) {
            _log.e('Failed to reload pools: ${failure.message}');
            // Still emit success with old data
            if (currentSetupData != null) {
              final updatedPools = [
                ...currentSetupData.ipPools,
                {'name': event.name, 'ranges': event.ranges},
              ];
              emit(IpPoolCreated(
                poolName: event.name,
                setupData: currentSetupData.copyWith(ipPools: updatedPools),
              ));
            }
          },
          (pools) {
            _log.i('Reloaded ${pools.length} pools');
            final newSetupData = DhcpSetupDataLoaded(
              interfaces: currentSetupData?.interfaces ?? [],
              ipPools: pools,
            );
            emit(IpPoolCreated(
              poolName: event.name,
              setupData: newSetupData,
            ));
          },
        );
      },
    );
  }
}
