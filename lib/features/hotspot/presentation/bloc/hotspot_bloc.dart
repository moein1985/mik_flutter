import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_servers_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/get_active_users_usecase.dart';
import '../../domain/usecases/get_profiles_usecase.dart';
import '../../domain/usecases/add_user_usecase.dart';
import '../../domain/usecases/toggle_user_usecase.dart';
import '../../domain/usecases/disconnect_user_usecase.dart';
import 'hotspot_event.dart';
import 'hotspot_state.dart';

class HotspotBloc extends Bloc<HotspotEvent, HotspotState> {
  final GetServersUseCase getServersUseCase;
  final GetUsersUseCase getUsersUseCase;
  final GetActiveUsersUseCase getActiveUsersUseCase;
  final GetProfilesUseCase getProfilesUseCase;
  final AddUserUseCase addUserUseCase;
  final ToggleUserUseCase toggleUserUseCase;
  final DisconnectUserUseCase disconnectUserUseCase;

  HotspotBloc({
    required this.getServersUseCase,
    required this.getUsersUseCase,
    required this.getActiveUsersUseCase,
    required this.getProfilesUseCase,
    required this.addUserUseCase,
    required this.toggleUserUseCase,
    required this.disconnectUserUseCase,
  }) : super(const HotspotInitial()) {
    on<LoadHotspotServers>(_onLoadServers);
    on<LoadHotspotUsers>(_onLoadUsers);
    on<LoadHotspotActiveUsers>(_onLoadActiveUsers);
    on<LoadHotspotProfiles>(_onLoadProfiles);
    on<AddHotspotUser>(_onAddUser);
    on<ToggleHotspotUser>(_onToggleUser);
    on<DisconnectHotspotUser>(_onDisconnectUser);
  }

  Future<void> _onLoadServers(
    LoadHotspotServers event,
    Emitter<HotspotState> emit,
  ) async {
    final result = await getServersUseCase();

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (servers) async {
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
    final result = await getUsersUseCase();

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (users) async {
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
    final result = await getActiveUsersUseCase();

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (activeUsers) async {
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
    final result = await getProfilesUseCase();

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (profiles) async {
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
        emit(HotspotError(failure.message));
      },
      (success) async {
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
    final result = await toggleUserUseCase(id: event.id, enable: event.enable);

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (success) async {
        // Reload users
        add(const LoadHotspotUsers());
      },
    );
  }

  Future<void> _onDisconnectUser(
    DisconnectHotspotUser event,
    Emitter<HotspotState> emit,
  ) async {
    final result = await disconnectUserUseCase(event.id);

    await result.fold(
      (failure) async {
        emit(HotspotError(failure.message));
      },
      (success) async {
        emit(const HotspotOperationSuccess('User disconnected'));
        // Reload active users
        add(const LoadHotspotActiveUsers());
      },
    );
  }
}
