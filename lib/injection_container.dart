import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/saved_router_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/repositories/saved_router_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/repositories/saved_router_repository.dart';
import 'features/auth/domain/usecases/get_saved_credentials_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/save_credentials_usecase.dart';
import 'features/auth/domain/usecases/get_saved_routers_usecase.dart';
import 'features/auth/domain/usecases/save_router_usecase.dart';
import 'features/auth/domain/usecases/delete_router_usecase.dart';
import 'features/auth/domain/usecases/update_router_usecase.dart';
import 'features/auth/domain/usecases/set_default_router_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/saved_router_bloc.dart';

// Features - Dashboard
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_system_resources_usecase.dart';
import 'features/dashboard/domain/usecases/get_interfaces_usecase.dart';
import 'features/dashboard/domain/usecases/toggle_interface_usecase.dart';
import 'features/dashboard/domain/usecases/get_ip_addresses_usecase.dart';
import 'features/dashboard/domain/usecases/get_firewall_rules_usecase.dart';
import 'features/dashboard/domain/usecases/toggle_firewall_rule_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Features - HotSpot
import 'features/hotspot/data/datasources/hotspot_remote_data_source.dart';
import 'features/hotspot/data/repositories/hotspot_repository_impl.dart';
import 'features/hotspot/domain/repositories/hotspot_repository.dart';
import 'features/hotspot/domain/usecases/get_servers_usecase.dart';
import 'features/hotspot/domain/usecases/get_users_usecase.dart';
import 'features/hotspot/domain/usecases/get_active_users_usecase.dart';
import 'features/hotspot/domain/usecases/get_profiles_usecase.dart';
import 'features/hotspot/domain/usecases/add_user_usecase.dart';
import 'features/hotspot/domain/usecases/edit_user_usecase.dart';
import 'features/hotspot/domain/usecases/delete_user_usecase.dart';
import 'features/hotspot/domain/usecases/reset_user_counters_usecase.dart';
import 'features/hotspot/domain/usecases/toggle_user_usecase.dart';
import 'features/hotspot/domain/usecases/disconnect_user_usecase.dart';
import 'features/hotspot/domain/usecases/setup_hotspot_usecase.dart';
import 'features/hotspot/presentation/bloc/hotspot_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      saveCredentialsUseCase: sl(),
      getSavedCredentialsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SavedRouterBloc(
      getSavedRoutersUseCase: sl(),
      saveRouterUseCase: sl(),
      deleteRouterUseCase: sl(),
      updateRouterUseCase: sl(),
      setDefaultRouterUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SaveCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedCredentialsUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedRoutersUseCase(sl()));
  sl.registerLazySingleton(() => SaveRouterUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRouterUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRouterUseCase(sl()));
  sl.registerLazySingleton(() => SetDefaultRouterUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<SavedRouterRepository>(
    () => SavedRouterRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
    ),
  );

  sl.registerLazySingleton<SavedRouterLocalDataSource>(
    () => SavedRouterLocalDataSourceImpl(),
  );

  //! Features - Dashboard
  // Bloc
  sl.registerFactory(
    () => DashboardBloc(
      getSystemResourcesUseCase: sl(),
      getInterfacesUseCase: sl(),
      toggleInterfaceUseCase: sl(),
      getIpAddressesUseCase: sl(),
      getFirewallRulesUseCase: sl(),
      toggleFirewallRuleUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSystemResourcesUseCase(sl()));
  sl.registerLazySingleton(() => GetInterfacesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleInterfaceUseCase(sl()));
  sl.registerLazySingleton(() => GetIpAddressesUseCase(sl()));
  sl.registerLazySingleton(() => GetFirewallRulesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFirewallRuleUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - HotSpot
  // Bloc
  sl.registerFactory(
    () => HotspotBloc(
      getServersUseCase: sl(),
      getUsersUseCase: sl(),
      getActiveUsersUseCase: sl(),
      getProfilesUseCase: sl(),
      addUserUseCase: sl(),
      editUserUseCase: sl(),
      deleteUserUseCase: sl(),
      resetUserCountersUseCase: sl(),
      toggleUserUseCase: sl(),
      disconnectUserUseCase: sl(),
      setupHotspotUseCase: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetServersUseCase(sl()));
  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetProfilesUseCase(sl()));
  sl.registerLazySingleton(() => AddUserUseCase(sl()));
  sl.registerLazySingleton(() => EditUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => ResetUserCountersUseCase(sl()));
  sl.registerLazySingleton(() => ToggleUserUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectUserUseCase(sl()));
  sl.registerLazySingleton(() => SetupHotspotUseCase(sl()));

  // Repository
  sl.registerLazySingleton<HotspotRepository>(
    () => HotspotRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HotspotRemoteDataSource>(
    () => HotspotRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  //! External
}
