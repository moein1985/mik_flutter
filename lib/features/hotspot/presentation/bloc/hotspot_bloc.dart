import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/get_servers_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/get_active_users_usecase.dart';
import '../../domain/usecases/get_profiles_usecase.dart';
import '../../domain/usecases/add_user_usecase.dart';
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
  final ToggleUserUseCase toggleUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;
  final SetupHotspotUseCase setupHotspotUseCase;

  HotspotBloc({
    required this.getServersUseCase,
    required this.getUsersUseCase,
    required this.getActiveUsersUseCase,
    required this.getProfilesUseCase,
    required this.addUserUseCase,
    required this.toggleUserUseCase,
    required this.disconnectUserUseCase,
    required this.setupHotspotUseCase,
  }) : super(const HotspotInitial()) {
    _log.i('HotspotBloc initialized');
    on<LoadHotspotServers>(_onLoadServers);
    on<LoadHotspotUsers>(_onLoadUsers);
    on<LoadHotspotActiveUsers>(_onLoadActiveUsers);
    on<LoadHotspotProfiles>(_onLoadProfiles);
    on<AddHotspotUser>(_onAddUser);
    on<ToggleHotspotUser>(_onToggleUser);
    on<DisconnectHotspotUser>(_onDisconnectUser);
    on<SetupHotspot>(_onSetupHotspot);
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
        if (state is HotspotLoaded) {
          final currentState = state as HotspotLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(servers: servers));
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
        if (state is HotspotLoaded) {
          final currentState = state as HotspotLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(users: users));
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
        if (state is HotspotLoaded) {
          final currentState = state as HotspotLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(activeUsers: activeUsers));
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
        if (state is HotspotLoaded) {
          final currentState = state as HotspotLoaded;
          if (!emit.isDone) {
            emit(currentState.copyWith(profiles: profiles));
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
    emit(const HotspotLoading());

    final result = await addUserUseCase(
      name: event.name,
      password: event.password,
      profile: event.profile,
      server: event.server,
      comment: event.comment,
    );

    await result.fold(
      (failure) async {
        _log.e('Failed to add user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User added successfully');
        emit(const HotspotOperationSuccess('User added successfully'));
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
    final result = await disconnectUserUseCase(event.id);

    await result.fold(
      (failure) async {
        _log.e('Failed to disconnect user: ${failure.message}');
        emit(HotspotError(failure.message));
      },
      (success) async {
        _log.i('User disconnected successfully');
        emit(const HotspotOperationSuccess('User disconnected'));
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
        emit(const HotspotOperationSuccess('HotSpot setup completed'));
        // Reload servers
        add(const LoadHotspotServers());
      },
    );
  }
}
