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
        // Reload servers
        add(const LoadHotspotServers());
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
    _log.i('Loading setup data (interfaces and pools)...');
    emit(const HotspotLoading());

    final interfacesResult = await repository.getInterfaces();
    final poolsResult = await repository.getIpPools();

    List<Map<String, String>> interfaces = [];
    List<Map<String, String>> pools = [];

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

    emit(HotspotSetupDataLoaded(interfaces: interfaces, ipPools: pools));
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
}
