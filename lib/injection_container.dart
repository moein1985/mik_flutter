import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

// Core
import 'core/network/routeros_client_v2.dart';
import 'core/network/routeros_client.dart';

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
// New UseCases
import 'features/hotspot/domain/usecases/get_ip_bindings_usecase.dart';
import 'features/hotspot/domain/usecases/add_ip_binding_usecase.dart';
import 'features/hotspot/domain/usecases/edit_ip_binding_usecase.dart';
import 'features/hotspot/domain/usecases/delete_ip_binding_usecase.dart';
import 'features/hotspot/domain/usecases/toggle_ip_binding_usecase.dart';
import 'features/hotspot/domain/usecases/get_hosts_usecase.dart';
import 'features/hotspot/domain/usecases/remove_host_usecase.dart';
import 'features/hotspot/domain/usecases/make_host_binding_usecase.dart';
import 'features/hotspot/domain/usecases/get_walled_garden_usecase.dart';
import 'features/hotspot/domain/usecases/add_walled_garden_usecase.dart';
import 'features/hotspot/domain/usecases/edit_walled_garden_usecase.dart';
import 'features/hotspot/domain/usecases/delete_walled_garden_usecase.dart';
import 'features/hotspot/domain/usecases/toggle_walled_garden_usecase.dart';
import 'features/hotspot/domain/usecases/add_profile_usecase.dart';
import 'features/hotspot/domain/usecases/edit_profile_usecase.dart';
import 'features/hotspot/domain/usecases/delete_profile_usecase.dart';
import 'features/hotspot/domain/usecases/reset_hotspot_usecase.dart';
import 'features/hotspot/presentation/bloc/hotspot_bloc.dart';

// Features - Firewall
import 'features/firewall/data/datasources/firewall_remote_data_source.dart';
import 'features/firewall/data/repositories/firewall_repository_impl.dart';
import 'features/firewall/domain/repositories/firewall_repository.dart';
import 'features/firewall/domain/usecases/get_firewall_rules.dart' as firewall_usecases;
import 'features/firewall/domain/usecases/toggle_firewall_rule.dart' as firewall_usecases;
import 'features/firewall/domain/usecases/get_address_list_names.dart';
import 'features/firewall/domain/usecases/get_address_list_by_name.dart';
import 'features/firewall/presentation/bloc/firewall_bloc.dart';

// Features - IP Services
import 'features/ip_services/data/datasources/ip_service_remote_data_source.dart';
import 'features/ip_services/data/repositories/ip_service_repository_impl.dart';
import 'features/ip_services/domain/repositories/ip_service_repository.dart';
import 'features/ip_services/presentation/bloc/ip_service_bloc.dart';

// Features - Certificates
import 'features/certificates/data/datasources/certificate_remote_data_source.dart';
import 'features/certificates/data/repositories/certificate_repository_impl.dart';
import 'features/certificates/domain/repositories/certificate_repository.dart';
import 'features/certificates/presentation/bloc/certificate_bloc.dart';

// Features - DHCP
import 'features/dhcp/data/datasources/dhcp_remote_data_source.dart';
import 'features/dhcp/data/repositories/dhcp_repository_impl.dart';
import 'features/dhcp/domain/repositories/dhcp_repository.dart';
import 'features/dhcp/presentation/bloc/dhcp_bloc.dart';

// Features - Tools
import 'features/tools/data/repositories/tools_repository_impl.dart';
import 'features/tools/domain/repositories/tools_repository.dart';
import 'features/tools/domain/usecases/ping_usecase.dart';
import 'features/tools/domain/usecases/traceroute_usecase.dart';
import 'features/tools/domain/usecases/dns_lookup_usecase.dart';
import 'features/tools/presentation/bloc/tools_bloc.dart';

// Features - Wireless
import 'features/wireless/data/datasources/wireless_remote_data_source.dart';
import 'features/wireless/data/repositories/wireless_repository_impl.dart';
import 'features/wireless/domain/repositories/wireless_repository.dart';
import 'features/wireless/domain/usecases/get_wireless_interfaces_usecase.dart';
import 'features/wireless/domain/usecases/get_wireless_registrations_usecase.dart';
import 'features/wireless/domain/usecases/get_security_profiles_usecase.dart';
import 'features/wireless/presentation/bloc/wireless_bloc.dart';

// Features - Logs
import 'features/logs/data/datasources/logs_remote_data_source.dart';
import 'features/logs/data/repositories/logs_repository_impl.dart';
import 'features/logs/domain/repositories/logs_repository.dart';
import 'features/logs/domain/usecases/get_logs_usecase.dart';
import 'features/logs/domain/usecases/follow_logs_usecase.dart';
import 'features/logs/domain/usecases/clear_logs_usecase.dart';
import 'features/logs/domain/usecases/search_logs_usecase.dart';
import 'features/logs/presentation/bloc/logs_bloc.dart';

// Features - Backup
import 'features/backup/data/datasources/backup_remote_data_source.dart';
import 'features/backup/data/repositories/backup_repository_impl.dart';
import 'features/backup/domain/repositories/backup_repository.dart';
import 'features/backup/domain/usecases/get_backups_usecase.dart';
import 'features/backup/domain/usecases/create_backup_usecase.dart';
import 'features/backup/domain/usecases/delete_backup_usecase.dart';
import 'features/backup/domain/usecases/restore_backup_usecase.dart';
import 'features/backup/domain/usecases/download_backup_usecase.dart';
import 'features/backup/presentation/bloc/backup_bloc.dart';

// Features - Queues
import 'features/queues/data/repositories/queues_repository_impl.dart';
import 'features/queues/domain/repositories/queues_repository.dart';
import 'features/queues/domain/usecases/get_queues_usecase.dart';
import 'features/queues/domain/usecases/add_queue_usecase.dart';
import 'features/queues/domain/usecases/edit_queue_usecase.dart';
import 'features/queues/domain/usecases/delete_queue_usecase.dart';
import 'features/queues/domain/usecases/toggle_queue_usecase.dart';
import 'features/queues/domain/usecases/get_queue_by_id_usecase.dart';
import 'features/queues/presentation/bloc/queues_bloc.dart';

// Features - Cloud
import 'features/cloud/data/datasources/cloud_remote_data_source.dart';
import 'features/cloud/data/repositories/cloud_repository_impl.dart';
import 'features/cloud/domain/repositories/cloud_repository.dart';
import 'features/cloud/presentation/bloc/cloud_bloc.dart';

// Features - Let's Encrypt
import 'features/letsencrypt/data/datasources/letsencrypt_remote_data_source.dart';
import 'features/letsencrypt/data/repositories/letsencrypt_repository_impl.dart';
import 'features/letsencrypt/domain/repositories/letsencrypt_repository.dart';
import 'features/letsencrypt/presentation/bloc/letsencrypt_bloc.dart';

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
      // New UseCases
      getIpBindingsUseCase: sl(),
      addIpBindingUseCase: sl(),
      editIpBindingUseCase: sl(),
      deleteIpBindingUseCase: sl(),
      toggleIpBindingUseCase: sl(),
      getHostsUseCase: sl(),
      removeHostUseCase: sl(),
      makeHostBindingUseCase: sl(),
      getWalledGardenUseCase: sl(),
      addWalledGardenUseCase: sl(),
      editWalledGardenUseCase: sl(),
      deleteWalledGardenUseCase: sl(),
      toggleWalledGardenUseCase: sl(),
      addProfileUseCase: sl(),
      editProfileUseCase: sl(),
      deleteProfileUseCase: sl(),
      resetHotspotUseCase: sl(),
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
  // New UseCases
  sl.registerLazySingleton(() => GetIpBindingsUseCase(sl()));
  sl.registerLazySingleton(() => AddIpBindingUseCase(sl()));
  sl.registerLazySingleton(() => EditIpBindingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteIpBindingUseCase(sl()));
  sl.registerLazySingleton(() => ToggleIpBindingUseCase(sl()));
  sl.registerLazySingleton(() => GetHostsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveHostUseCase(sl()));
  sl.registerLazySingleton(() => MakeHostBindingUseCase(sl()));
  sl.registerLazySingleton(() => GetWalledGardenUseCase(sl()));
  sl.registerLazySingleton(() => AddWalledGardenUseCase(sl()));
  sl.registerLazySingleton(() => EditWalledGardenUseCase(sl()));
  sl.registerLazySingleton(() => DeleteWalledGardenUseCase(sl()));
  sl.registerLazySingleton(() => ToggleWalledGardenUseCase(sl()));
  sl.registerLazySingleton(() => AddProfileUseCase(sl()));
  sl.registerLazySingleton(() => EditProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProfileUseCase(sl()));
  sl.registerLazySingleton(() => ResetHotspotUseCase(sl()));

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

  //! Features - Firewall
  // Bloc
  sl.registerFactory(
    () => FirewallBloc(
      getFirewallRulesUseCase: sl(),
      toggleFirewallRuleUseCase: sl(),
      getAddressListNamesUseCase: sl(),
      getAddressListByNameUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => firewall_usecases.GetFirewallRulesUseCase(sl()));
  sl.registerLazySingleton(() => firewall_usecases.ToggleFirewallRuleUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressListNamesUseCase(sl()));
  sl.registerLazySingleton(() => GetAddressListByNameUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FirewallRepository>(
    () => FirewallRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<FirewallRemoteDataSource>(
    () => FirewallRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - IP Services
  // Bloc
  sl.registerFactory(
    () => IpServiceBloc(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<IpServiceRepository>(
    () => IpServiceRepositoryImpl(
      remoteDataSource: sl(),
      certificateDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<IpServiceRemoteDataSource>(
    () => IpServiceRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Certificates
  // Bloc
  sl.registerFactory(
    () => CertificateBloc(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CertificateRepository>(
    () => CertificateRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CertificateRemoteDataSource>(
    () => CertificateRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - DHCP
  // Bloc
  sl.registerFactory(
    () => DhcpBloc(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<DhcpRepository>(
    () => DhcpRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DhcpRemoteDataSource>(
    () => DhcpRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Cloud
  // Bloc
  sl.registerFactory(
    () => CloudBloc(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CloudRepository>(
    () => CloudRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CloudRemoteDataSource>(
    () => CloudRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Let's Encrypt
  // Bloc
  sl.registerFactory(
    () => LetsEncryptBloc(
      repository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<LetsEncryptRepository>(
    () => LetsEncryptRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LetsEncryptRemoteDataSource>(
    () => LetsEncryptRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Tools
  // Bloc
  sl.registerFactory(
    () => ToolsBloc(
      pingUseCase: sl(),
      tracerouteUseCase: sl(),
      dnsLookupUseCase: sl(),
      getInterfacesUseCase: sl(),
      getIpAddressesUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => PingUseCase(sl()));
  sl.registerLazySingleton(() => TracerouteUseCase(sl()));
  sl.registerLazySingleton(() => DnsLookupUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ToolsRepository>(
    () => ToolsRepositoryImpl(
      routerOsClient: sl(),
      legacyClient: sl(),  // Legacy client for streaming (package has bugs)
    ),
  );

  //! Features - Queues
  // Bloc
  sl.registerFactory(
    () => QueuesBloc(
      getQueuesUseCase: sl(),
      getQueueByIdUseCase: sl(),
      addQueueUseCase: sl(),
      editQueueUseCase: sl(),
      deleteQueueUseCase: sl(),
      toggleQueueUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetQueuesUseCase(sl()));
  sl.registerLazySingleton(() => GetQueueByIdUseCase(sl()));
  sl.registerLazySingleton(() => AddQueueUseCase(sl()));
  sl.registerLazySingleton(() => EditQueueUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQueueUseCase(sl()));
  sl.registerLazySingleton(() => ToggleQueueUseCase(sl()));

  // Repository
  sl.registerLazySingleton<QueuesRepository>(
    () => QueuesRepositoryImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Wireless
  // Data sources
  sl.registerLazySingleton<WirelessRemoteDataSource>(
    () => WirelessRemoteDataSourceImpl(authRemoteDataSource: sl()),
  );

  // Repository
  sl.registerLazySingleton<WirelessRepository>(
    () => WirelessRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWirelessInterfacesUseCase(sl()));
  sl.registerLazySingleton(() => GetWirelessRegistrationsUseCase(sl()));
  sl.registerLazySingleton(() => GetRegistrationsByInterfaceUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectClientUseCase(sl()));
  sl.registerLazySingleton(() => GetSecurityProfilesUseCase(sl()));
  sl.registerLazySingleton(() => EnableWirelessInterfaceUseCase(sl()));
  sl.registerLazySingleton(() => DisableWirelessInterfaceUseCase(sl()));
  sl.registerLazySingleton(() => CreateSecurityProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSecurityProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSecurityProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => WirelessBloc(
      getWirelessInterfacesUseCase: sl(),
      getWirelessRegistrationsUseCase: sl(),
      getRegistrationsByInterfaceUseCase: sl(),
      disconnectClientUseCase: sl(),
      getSecurityProfilesUseCase: sl(),
      enableWirelessInterfaceUseCase: sl(),
      disableWirelessInterfaceUseCase: sl(),
      createSecurityProfileUseCase: sl(),
      updateSecurityProfileUseCase: sl(),
      deleteSecurityProfileUseCase: sl(),
    ),
  );

  //! Features - Logs
  // Bloc
  sl.registerFactory(
    () => LogsBloc(
      getLogsUseCase: sl(),
      followLogsUseCase: sl(),
      clearLogsUseCase: sl(),
      searchLogsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLogsUseCase(sl()));
  sl.registerLazySingleton(() => FollowLogsUseCase(sl()));
  sl.registerLazySingleton(() => ClearLogsUseCase(sl()));
  sl.registerLazySingleton(() => SearchLogsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<LogsRepository>(
    () => LogsRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<LogsRemoteDataSource>(
    () => LogsRemoteDataSourceImpl(
      authRemoteDataSource: sl(),
    ),
  );

  //! Features - Backup
  // Bloc
  sl.registerFactory(
    () => BackupBloc(
      getBackupsUseCase: sl(),
      createBackupUseCase: sl(),
      deleteBackupUseCase: sl(),
      restoreBackupUseCase: sl(),
      downloadBackupUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetBackupsUseCase(sl()));
  sl.registerLazySingleton(() => CreateBackupUseCase(sl()));
  sl.registerLazySingleton(() => DeleteBackupUseCase(sl()));
  sl.registerLazySingleton(() => RestoreBackupUseCase(sl()));
  sl.registerLazySingleton(() => DownloadBackupUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BackupRepository>(
    () => BackupRepositoryImpl(
      sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BackupRemoteDataSource>(
    () => BackupRemoteDataSourceImpl(
      sl(),
    ),
  );

  //! Core
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  // RouterOS Client V2 - gets the client from auth remote data source
  sl.registerLazySingleton<RouterOSClientV2>(
    () => sl<AuthRemoteDataSource>().client!,
  );
  
  // Legacy RouterOS Client - for streaming operations (package has bugs)
  sl.registerLazySingleton<RouterOSClient>(
    () => sl<AuthRemoteDataSource>().legacyClient!,
  );

  // Domain-specific RouterOS Clients (using old client for now - will migrate later)
  // For now, we'll comment them out as they depend on RouterOSClient

  //! External
}
