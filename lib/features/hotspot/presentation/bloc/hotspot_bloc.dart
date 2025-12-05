import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/hotspot_repository.dart';
import '../../domain/usecases/get_servers_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/get_active_users_usecase.dart';
import '../../domain/usecases/get_profiles_usecase.dart';
import '../../domain/usecases/add_user_usecase.dart';
import '../../domain/usecases/edit_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/reset_user_counters_usecase.dart';
import '../../domain/usecases/toggle_user_usecase.dart';
import '../../domain/usecases/disconnect_user_usecase.dart';
import '../../domain/usecases/setup_hotspot_usecase.dart';
import '../../domain/usecases/reset_hotspot_usecase.dart';
// New UseCases
import '../../domain/usecases/get_ip_bindings_usecase.dart';
import '../../domain/usecases/add_ip_binding_usecase.dart';
import '../../domain/usecases/edit_ip_binding_usecase.dart';
import '../../domain/usecases/delete_ip_binding_usecase.dart';
import '../../domain/usecases/toggle_ip_binding_usecase.dart';
import '../../domain/usecases/get_hosts_usecase.dart';
import '../../domain/usecases/remove_host_usecase.dart';
import '../../domain/usecases/make_host_binding_usecase.dart';
import '../../domain/usecases/get_walled_garden_usecase.dart';
import '../../domain/usecases/add_walled_garden_usecase.dart';
import '../../domain/usecases/edit_walled_garden_usecase.dart';
import '../../domain/usecases/delete_walled_garden_usecase.dart';
import '../../domain/usecases/toggle_walled_garden_usecase.dart';
import '../../domain/usecases/add_profile_usecase.dart';
import '../../domain/usecases/edit_profile_usecase.dart';
import '../../domain/usecases/delete_profile_usecase.dart';
import 'hotspot_event.dart';
import 'hotspot_state.dart';

class HotspotBloc extends Bloc<HotspotEvent, HotspotState> {
  final _log = AppLogger.tag('HotspotBloc');
  
  final GetServersUseCase getServersUseCase;
  final GetUsersUseCase getUsersUseCase;
  final GetActiveUsersUseCase getActiveUsersUseCase;
  final GetProfilesUseCase getProfilesUseCase;
  final AddUserUseCase addUserUseCase;
  final EditUserUseCase editUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;
  final ResetUserCountersUseCase resetUserCountersUseCase;
  final ToggleUserUseCase toggleUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;
  final SetupHotspotUseCase setupHotspotUseCase;
  final HotspotRepository repository;
  
  // New UseCases
  final GetIpBindingsUseCase getIpBindingsUseCase;
  final AddIpBindingUseCase addIpBindingUseCase;
  final EditIpBindingUseCase editIpBindingUseCase;
  final DeleteIpBindingUseCase deleteIpBindingUseCase;
  final ToggleIpBindingUseCase toggleIpBindingUseCase;
  final GetHostsUseCase getHostsUseCase;
  final RemoveHostUseCase removeHostUseCase;
  final MakeHostBindingUseCase makeHostBindingUseCase;
  final GetWalledGardenUseCase getWalledGardenUseCase;
  final AddWalledGardenUseCase addWalledGardenUseCase;
  final EditWalledGardenUseCase editWalledGardenUseCase;
  final DeleteWalledGardenUseCase deleteWalledGardenUseCase;
  final ToggleWalledGardenUseCase toggleWalledGardenUseCase;
  final AddProfileUseCase addProfileUseCase;
  final EditProfileUseCase editProfileUseCase;
  final DeleteProfileUseCase deleteProfileUseCase;
  final ResetHotspotUseCase resetHotspotUseCase;

  HotspotBloc({
    required this.getServersUseCase,
    required this.getUsersUseCase,
    required this.getActiveUsersUseCase,
    required this.getProfilesUseCase,
    required this.addUserUseCase,
    required this.editUserUseCase,
    required this.deleteUserUseCase,
    required this.resetUserCountersUseCase,
    required this.toggleUserUseCase,
    required this.disconnectUserUseCase,
    required this.setupHotspotUseCase,
    required this.repository,
    // New UseCases
    required this.getIpBindingsUseCase,
    required this.addIpBindingUseCase,
    required this.editIpBindingUseCase,
    required this.deleteIpBindingUseCase,
    required this.toggleIpBindingUseCase,
    required this.getHostsUseCase,
    required this.removeHostUseCase,
    required this.makeHostBindingUseCase,
    required this.getWalledGardenUseCase,
    required this.addWalledGardenUseCase,
    required this.editWalledGardenUseCase,
    required this.deleteWalledGardenUseCase,
    required this.toggleWalledGardenUseCase,
    required this.addProfileUseCase,
    required this.editProfileUseCase,
    required this.deleteProfileUseCase,
    required this.resetHotspotUseCase,
  }) : super(const HotspotInitial()) {
    _log.i('HotspotBloc initialized');
    on<LoadHotspotServers>(_onLoadServers);
    on<LoadHotspotUsers>(_onLoadUsers);
    on<LoadHotspotActiveUsers>(_onLoadActiveUsers);
    on<LoadHotspotProfiles>(_onLoadProfiles);
    on<AddHotspotUser>(_onAddUser);
    on<EditHotspotUser>(_onEditUser);
    on<DeleteHotspotUser>(_onDeleteUser);
    on<ResetHotspotUserCounters>(_onResetUserCounters);
    on<ToggleHotspotUser>(_onToggleUser);
    on<DisconnectHotspotUser>(_onDisconnectUser);
    on<SetupHotspot>(_onSetupHotspot);
    on<CheckHotspotPackage>(_onCheckHotspotPackage);
    on<LoadSetupData>(_onLoadSetupData);
    on<AddIpPool>(_onAddIpPool);
    // New Event Handlers
    on<LoadIpBindings>(_onLoadIpBindings);
    on<AddIpBinding>(_onAddIpBinding);
    on<EditIpBinding>(_onEditIpBinding);
    on<DeleteIpBinding>(_onDeleteIpBinding);
    on<ToggleIpBinding>(_onToggleIpBinding);
    on<LoadHosts>(_onLoadHosts);
    on<RemoveHost>(_onRemoveHost);
    on<MakeHostBinding>(_onMakeHostBinding);
    on<LoadWalledGarden>(_onLoadWalledGarden);
    on<AddWalledGarden>(_onAddWalledGarden);
    on<EditWalledGarden>(_onEditWalledGarden);
    on<DeleteWalledGarden>(_onDeleteWalledGarden);
    on<ToggleWalledGarden>(_onToggleWalledGarden);
    on<AddHotspotProfile>(_onAddProfile);
    on<EditHotspotProfile>(_onEditProfile);
    on<DeleteHotspotProfile>(_onDeleteProfile);
    on<ResetHotspot>(_onResetHotspot);
  }

  Future<void> _onLoadServers(
    LoadHotspotServers event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading hotspot servers...');
    final result = await getServersUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load servers: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (servers) async {
        _log.i('Loaded ${servers.length} servers');
        // Get previous data from current state
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) {
            emit(previousData.copyWith(servers: servers));
          }
        } else {
          if (!emit.isDone) {
            emit(HotspotLoaded(servers: servers));
          }
        }
      },
    );
  }

  Future<void> _onLoadUsers(
    LoadHotspotUsers event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading hotspot users...');
    final result = await getUsersUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load users: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (users) async {
        _log.i('Loaded ${users.length} users');
        // Get previous data from current state
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) {
            emit(previousData.copyWith(users: users));
          }
        } else {
          if (!emit.isDone) {
            emit(HotspotLoaded(users: users));
          }
        }
      },
    );
  }

  Future<void> _onLoadActiveUsers(
    LoadHotspotActiveUsers event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading active hotspot users...');
    final result = await getActiveUsersUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load active users: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (activeUsers) async {
        _log.i('Loaded ${activeUsers.length} active users');
        // Get previous data from current state
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) {
            emit(previousData.copyWith(activeUsers: activeUsers));
          }
        } else {
          if (!emit.isDone) {
            emit(HotspotLoaded(activeUsers: activeUsers));
          }
        }
      },
    );
  }

  Future<void> _onLoadProfiles(
    LoadHotspotProfiles event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading hotspot profiles...');
    final result = await getProfilesUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load profiles: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (profiles) async {
        _log.i('Loaded ${profiles.length} profiles');
        // Get previous data from current state
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) {
            emit(previousData.copyWith(profiles: profiles));
          }
        } else {
          if (!emit.isDone) {
            emit(HotspotLoaded(profiles: profiles));
          }
        }
      },
    );
  }

  Future<void> _onAddUser(
    AddHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Adding hotspot user: ${event.name}');
    // Preserve current data before showing loading
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await addUserUseCase(
      name: event.name,
      password: event.password,
      profile: event.profile,
      server: event.server,
      comment: event.comment,
      limitUptime: event.limitUptime,
      limitBytesIn: event.limitBytesIn,
      limitBytesOut: event.limitBytesOut,
      limitBytesTotal: event.limitBytesTotal,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to add user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User added successfully');
        emit(HotspotOperationSuccess('User added successfully', previousData: previousData));
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onEditUser(
    EditHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Editing hotspot user: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await editUserUseCase(
      id: event.id,
      name: event.name,
      password: event.password,
      profile: event.profile,
      server: event.server,
      comment: event.comment,
      limitUptime: event.limitUptime,
      limitBytesIn: event.limitBytesIn,
      limitBytesOut: event.limitBytesOut,
      limitBytesTotal: event.limitBytesTotal,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to edit user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User edited successfully');
        emit(HotspotOperationSuccess('User updated successfully', previousData: previousData));
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onDeleteUser(
    DeleteHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Deleting hotspot user: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await deleteUserUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User deleted successfully');
        emit(HotspotOperationSuccess('User deleted successfully', previousData: previousData));
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onResetUserCounters(
    ResetHotspotUserCounters event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Resetting counters for user: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await resetUserCountersUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to reset user counters: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User counters reset successfully');
        emit(HotspotOperationSuccess('User statistics reset successfully', previousData: previousData));
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onToggleUser(
    ToggleHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Toggling user ${event.id}: enable=${event.enable}');
    final result = await toggleUserUseCase(id: event.id, enable: event.enable);

    await result.fold(
      (failure) async {
        _log.e('Failed to toggle user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User toggled successfully');
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onDisconnectUser(
    DisconnectHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Disconnecting user: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    final result = await disconnectUserUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to disconnect user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User disconnected successfully');
        emit(HotspotOperationSuccess('User disconnected', previousData: previousData));
        // Reload active users
        add(const LoadHotspotActiveUsers());
      },
    );
  }

  Future<void> _onSetupHotspot(
    SetupHotspot event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Setting up hotspot on interface: ${event.interface}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await setupHotspotUseCase(
      interface: event.interface,
      addressPool: event.addressPool,
      dnsName: event.dnsName,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to setup hotspot: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('HotSpot setup completed successfully');
        emit(HotspotOperationSuccess('HotSpot setup completed', previousData: previousData));
        // UI will handle reloading servers
      },
    );
  }

  Future<void> _onCheckHotspotPackage(
    CheckHotspotPackage event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Checking hotspot package status...');
    final result = await repository.isHotspotPackageEnabled();

    await result.fold(
      (failure) async {
        _log.e('Failed to check hotspot package: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (enabled) async {
        _log.i('Hotspot package enabled: $enabled');
        if (!enabled) {
          emit(const HotspotPackageDisabled());
        } else {
          // Load servers if package is enabled
          add(const LoadHotspotServers());
        }
      },
    );
  }

  Future<void> _onLoadSetupData(
    LoadSetupData event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading setup data (interfaces, pools and addresses)...');
    emit(const HotspotLoading());

    final interfacesResult = await repository.getInterfaces();
    final poolsResult = await repository.getIpPools();
    final addressesResult = await repository.getIpAddresses();

    List<Map<String, String>> interfaces = [];
    List<Map<String, String>> pools = [];
    List<Map<String, String>> addresses = [];

    interfacesResult.fold(
      (failure) {
        _log.e('Failed to load interfaces: ${failure.message}');
      },
      (data) {
        interfaces = data;
        _log.i('Loaded ${data.length} interfaces');
      },
    );

    poolsResult.fold(
      (failure) {
        _log.e('Failed to load pools: ${failure.message}');
      },
      (data) {
        pools = data;
        _log.i('Loaded ${data.length} pools');
      },
    );

    addressesResult.fold(
      (failure) {
        _log.e('Failed to load IP addresses: ${failure.message}');
      },
      (data) {
        addresses = data;
        _log.i('Loaded ${data.length} IP addresses');
      },
    );

    emit(HotspotSetupDataLoaded(interfaces: interfaces, ipPools: pools, ipAddresses: addresses));
  }

  Future<void> _onAddIpPool(
    AddIpPool event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Adding IP pool: ${event.name}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    
    final result = await repository.addIpPool(
      name: event.name,
      ranges: event.ranges,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to add IP pool: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('IP pool added successfully');
        emit(HotspotOperationSuccess('IP Pool added successfully', previousData: previousData));
        // Reload setup data
        add(const LoadSetupData());
      },
    );
  }

  // ==================== IP Binding Handlers ====================

  Future<void> _onLoadIpBindings(
    LoadIpBindings event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading IP bindings...');
    final result = await getIpBindingsUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load IP bindings: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (bindings) async {
        _log.i('Loaded ${bindings.length} IP bindings');
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) emit(previousData.copyWith(ipBindings: bindings));
        } else {
          if (!emit.isDone) emit(HotspotLoaded(ipBindings: bindings));
        }
      },
    );
  }

  Future<void> _onAddIpBinding(
    AddIpBinding event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Adding IP binding: ${event.mac}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await addIpBindingUseCase(AddIpBindingParams(
      mac: event.mac,
      address: event.address,
      toAddress: event.toAddress,
      server: event.server,
      type: event.type,
      comment: event.comment,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to add IP binding: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('IP binding added successfully');
        emit(HotspotOperationSuccess('IP Binding added', previousData: previousData));
        add(const LoadIpBindings());
      },
    );
  }

  Future<void> _onEditIpBinding(
    EditIpBinding event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Editing IP binding: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await editIpBindingUseCase(EditIpBindingParams(
      id: event.id,
      mac: event.mac,
      address: event.address,
      toAddress: event.toAddress,
      server: event.server,
      type: event.type,
      comment: event.comment,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to edit IP binding: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('IP binding updated successfully');
        emit(HotspotOperationSuccess('IP Binding updated', previousData: previousData));
        add(const LoadIpBindings());
      },
    );
  }

  Future<void> _onDeleteIpBinding(
    DeleteIpBinding event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Deleting IP binding: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await deleteIpBindingUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete IP binding: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('IP binding deleted successfully');
        emit(HotspotOperationSuccess('IP Binding deleted', previousData: previousData));
        add(const LoadIpBindings());
      },
    );
  }

  Future<void> _onToggleIpBinding(
    ToggleIpBinding event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Toggling IP binding ${event.id}: enable=${event.enable}');
    final result = await toggleIpBindingUseCase(id: event.id, enable: event.enable);

    await result.fold(
      (failure) async {
        _log.e('Failed to toggle IP binding: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('IP binding toggled successfully');
        add(const LoadIpBindings());
      },
    );
  }

  // ==================== Hosts Handlers ====================

  Future<void> _onLoadHosts(
    LoadHosts event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading hosts...');
    final result = await getHostsUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load hosts: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (hosts) async {
        _log.i('Loaded ${hosts.length} hosts');
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) emit(previousData.copyWith(hosts: hosts));
        } else {
          if (!emit.isDone) emit(HotspotLoaded(hosts: hosts));
        }
      },
    );
  }

  Future<void> _onRemoveHost(
    RemoveHost event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Removing host: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await removeHostUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to remove host: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Host removed successfully');
        emit(HotspotOperationSuccess('Host removed', previousData: previousData));
        add(const LoadHosts());
      },
    );
  }

  Future<void> _onMakeHostBinding(
    MakeHostBinding event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Making host binding: ${event.id} -> ${event.type}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await makeHostBindingUseCase(MakeHostBindingParams(
      id: event.id,
      type: event.type,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to make host binding: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Host binding created successfully');
        emit(HotspotOperationSuccess('Host binding created', previousData: previousData));
        add(const LoadHosts());
        add(const LoadIpBindings());
      },
    );
  }

  // ==================== Walled Garden Handlers ====================

  Future<void> _onLoadWalledGarden(
    LoadWalledGarden event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Loading walled garden...');
    final result = await getWalledGardenUseCase();

    await result.fold(
      (failure) async {
        _log.e('Failed to load walled garden: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (entries) async {
        _log.i('Loaded ${entries.length} walled garden entries');
        HotspotLoaded? previousData;
        if (state is HotspotLoaded) {
          previousData = state as HotspotLoaded;
        } else if (state is HotspotOperationSuccess) {
          previousData = (state as HotspotOperationSuccess).previousData;
        }
        
        if (previousData != null) {
          if (!emit.isDone) emit(previousData.copyWith(walledGarden: entries));
        } else {
          if (!emit.isDone) emit(HotspotLoaded(walledGarden: entries));
        }
      },
    );
  }

  Future<void> _onAddWalledGarden(
    AddWalledGarden event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Adding walled garden entry: ${event.dstHost}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await addWalledGardenUseCase(AddWalledGardenParams(
      server: event.server,
      srcAddress: event.srcAddress,
      dstAddress: event.dstAddress,
      dstHost: event.dstHost,
      dstPort: event.dstPort,
      path: event.path,
      action: event.action,
      method: event.method,
      comment: event.comment,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to add walled garden: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Walled garden entry added');
        emit(HotspotOperationSuccess('Walled Garden entry added', previousData: previousData));
        add(const LoadWalledGarden());
      },
    );
  }

  Future<void> _onEditWalledGarden(
    EditWalledGarden event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Editing walled garden: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await editWalledGardenUseCase(EditWalledGardenParams(
      id: event.id,
      server: event.server,
      srcAddress: event.srcAddress,
      dstAddress: event.dstAddress,
      dstHost: event.dstHost,
      dstPort: event.dstPort,
      path: event.path,
      action: event.action,
      method: event.method,
      comment: event.comment,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to edit walled garden: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Walled garden updated');
        emit(HotspotOperationSuccess('Walled Garden updated', previousData: previousData));
        add(const LoadWalledGarden());
      },
    );
  }

  Future<void> _onDeleteWalledGarden(
    DeleteWalledGarden event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Deleting walled garden: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await deleteWalledGardenUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete walled garden: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Walled garden deleted');
        emit(HotspotOperationSuccess('Walled Garden deleted', previousData: previousData));
        add(const LoadWalledGarden());
      },
    );
  }

  Future<void> _onToggleWalledGarden(
    ToggleWalledGarden event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Toggling walled garden ${event.id}: enable=${event.enable}');
    final result = await toggleWalledGardenUseCase(id: event.id, enable: event.enable);

    await result.fold(
      (failure) async {
        _log.e('Failed to toggle walled garden: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Walled garden toggled');
        add(const LoadWalledGarden());
      },
    );
  }

  // ==================== Profile CRUD Handlers ====================

  Future<void> _onAddProfile(
    AddHotspotProfile event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Adding profile: ${event.name}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await addProfileUseCase(AddProfileParams(
      name: event.name,
      sessionTimeout: event.sessionTimeout,
      idleTimeout: event.idleTimeout,
      sharedUsers: event.sharedUsers,
      rateLimit: event.rateLimit,
      keepaliveTimeout: event.keepaliveTimeout,
      statusAutorefresh: event.statusAutorefresh,
      onLogin: event.onLogin,
      onLogout: event.onLogout,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to add profile: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Profile added successfully');
        emit(HotspotOperationSuccess('Profile added', previousData: previousData));
        add(const LoadHotspotProfiles());
      },
    );
  }

  Future<void> _onEditProfile(
    EditHotspotProfile event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Editing profile: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;
    emit(const HotspotLoading());

    final result = await editProfileUseCase(EditProfileParams(
      id: event.id,
      name: event.name,
      sessionTimeout: event.sessionTimeout,
      idleTimeout: event.idleTimeout,
      sharedUsers: event.sharedUsers,
      rateLimit: event.rateLimit,
      keepaliveTimeout: event.keepaliveTimeout,
      statusAutorefresh: event.statusAutorefresh,
      onLogin: event.onLogin,
      onLogout: event.onLogout,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to edit profile: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Profile updated successfully');
        emit(HotspotOperationSuccess('Profile updated', previousData: previousData));
        add(const LoadHotspotProfiles());
      },
    );
  }

  Future<void> _onDeleteProfile(
    DeleteHotspotProfile event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Deleting profile: ${event.id}');
    final previousData = state is HotspotLoaded ? state as HotspotLoaded : null;

    final result = await deleteProfileUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to delete profile: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('Profile deleted successfully');
        emit(HotspotOperationSuccess('Profile deleted', previousData: previousData));
        add(const LoadHotspotProfiles());
      },
    );
  }

  // ==================== Reset HotSpot Handler ====================

  Future<void> _onResetHotspot(
    ResetHotspot event,
    Emitter<HotspotState> emit,
  ) async {
    _log.i('Starting HotSpot reset...');
    emit(const HotspotResetInProgress('Resetting HotSpot...'));

    final result = await resetHotspotUseCase(ResetHotspotParams(
      deleteUsers: event.deleteUsers,
      deleteProfiles: event.deleteProfiles,
      deleteIpBindings: event.deleteIpBindings,
      deleteWalledGarden: event.deleteWalledGarden,
      deleteServers: event.deleteServers,
      deleteServerProfiles: event.deleteServerProfiles,
      deleteIpPools: event.deleteIpPools,
    ));

    await result.fold(
      (failure) async {
        _log.e('Failed to reset hotspot: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('HotSpot reset completed successfully');
        emit(const HotspotResetSuccess());
        // UI will handle reloading servers
      },
    );
  }
}
