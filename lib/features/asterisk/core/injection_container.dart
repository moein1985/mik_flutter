import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';
import 'ssh_config.dart';
import 'services/asterisk_ssh_manager.dart';
import '../data/datasources/ami_datasource.dart';
import '../data/datasources/ssh_cdr_datasource.dart';
import '../data/repositories/mock/extension_repository_mock.dart';
import '../data/repositories/mock/monitor_repository_mock.dart';
import '../data/repositories/mock/cdr_repository_mock.dart';
import '../data/repositories/extension_repository_impl.dart';
import '../data/repositories/monitor_repository_impl.dart';
import '../data/repositories/cdr_repository_impl.dart';
import '../domain/repositories/iextension_repository.dart';
import '../domain/repositories/imonitor_repository.dart';
import '../domain/repositories/icdr_repository.dart';
import '../domain/usecases/get_extensions_usecase.dart';
import '../domain/usecases/get_active_calls_usecase.dart';
import '../domain/usecases/get_dashboard_stats_usecase.dart';
import '../domain/usecases/get_cdr_records_usecase.dart';
import '../domain/usecases/get_queue_status_usecase.dart';
import '../domain/usecases/get_trunks_usecase.dart';
import '../domain/usecases/hangup_call_usecase.dart';
import '../domain/usecases/transfer_call_usecase.dart';
import '../domain/usecases/pause_agent_usecase.dart';
import '../domain/usecases/unpause_agent_usecase.dart';
import '../domain/usecases/get_parked_calls_usecase.dart';
import '../domain/usecases/get_agent_details_usecase.dart';
import '../domain/usecases/export_cdr_to_csv_usecase.dart';
import '../presentation/blocs/dashboard_bloc.dart';
import '../presentation/blocs/extension_bloc.dart';
import '../presentation/blocs/cdr_bloc.dart';
import '../presentation/blocs/active_call_bloc.dart';
import '../presentation/blocs/queue_bloc.dart';
import '../presentation/blocs/trunk_bloc.dart';
import '../presentation/blocs/parking_bloc.dart';
import '../presentation/blocs/agent_detail_bloc.dart';

/// Asterisk module dependency injection setup
/// 
/// Call `setupAsteriskDependencies()` to register all Asterisk module dependencies
/// with GetIt service locator.
Future<void> setupAsteriskDependencies(GetIt sl, {bool useMock = true}) async {
  // Load saved settings if using real repositories
  String amiHost = AppConfig.defaultAmiHost;
  int amiPort = AppConfig.defaultAmiPort;
  String amiUsername = AppConfig.defaultAmiUsername;
  String amiPassword = AppConfig.defaultAmiSecret;
  String sshHost = AppConfig.defaultSshHost;
  int sshPort = AppConfig.defaultSshPort;
  String sshUsername = AppConfig.defaultSshUsername;
  String sshPassword = AppConfig.defaultSshPassword;

  if (!useMock) {
    // Try to load saved settings
    try {
      final prefs = await SharedPreferences.getInstance();
      const secureStorage = FlutterSecureStorage();
      
      // Load SSH settings
      sshHost = prefs.getString('asterisk_ssh_host') ?? AppConfig.defaultSshHost;
      sshPort = prefs.getInt('asterisk_ssh_port') ?? AppConfig.defaultSshPort;
      sshUsername = prefs.getString('asterisk_ssh_username') ?? AppConfig.defaultSshUsername;
      sshPassword = await secureStorage.read(key: 'asterisk_ssh_password') ?? '';
      
      // Load AMI settings
      amiHost = prefs.getString('asterisk_ami_host') ?? AppConfig.defaultAmiHost;
      amiPort = prefs.getInt('asterisk_ami_port') ?? AppConfig.defaultAmiPort;
      amiUsername = prefs.getString('asterisk_ami_username') ?? AppConfig.defaultAmiUsername;
      amiPassword = await secureStorage.read(key: 'asterisk_ami_password') ?? AppConfig.defaultAmiSecret;
    } catch (e) {
      // Use defaults if loading fails
    }

    // SSH Config & Manager for CDR
    sl.registerLazySingleton<SshConfig>(
      () => SshConfig(
        host: sshHost,
        port: sshPort,
        username: sshUsername,
        authMethod: 'password',
        password: sshPassword,
        recordingsPath: AppConfig.defaultRecordingsPath,
      ),
    );
    
    sl.registerLazySingleton<AsteriskSshManager>(
      () => AsteriskSshManager(sl<SshConfig>()),
    );

    // AMI DataSource
    sl.registerFactory<AmiDataSource>(
      () => AmiDataSource(
        host: amiHost,
        port: amiPort,
        username: amiUsername,
        secret: amiPassword,
      ),
    );
    
    // SSH CDR DataSource
    sl.registerFactory<SshCdrDataSource>(
      () => SshCdrDataSource(sshManager: sl<AsteriskSshManager>()),
    );
  }

  // Repositories
  if (useMock) {
    sl.registerLazySingleton<IExtensionRepository>(() => ExtensionRepositoryMock());
    sl.registerLazySingleton<IMonitorRepository>(() => MonitorRepositoryMock());
    sl.registerLazySingleton<ICdrRepository>(() => CdrRepositoryMock());
  } else {
    sl.registerLazySingleton<IExtensionRepository>(
      () => ExtensionRepositoryImpl(sl<AmiDataSource>()),
    );
    sl.registerLazySingleton<IMonitorRepository>(
      () => MonitorRepositoryImpl(sl<AmiDataSource>()),
    );
    sl.registerLazySingleton<ICdrRepository>(
      () => CdrRepositoryImpl(sl<SshCdrDataSource>()),
    );
  }

  // Use Cases
  sl.registerLazySingleton(() => GetExtensionsUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveCallsUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardStatsUseCase(sl(), sl()));
  sl.registerLazySingleton(() => GetCdrRecordsUseCase(sl()));
  sl.registerLazySingleton(() => GetQueueStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetTrunksUseCase(sl()));
  sl.registerLazySingleton(() => HangupCallUseCase(sl()));
  sl.registerLazySingleton(() => TransferCallUseCase(sl()));
  sl.registerLazySingleton(() => PauseAgentUseCase(sl()));
  sl.registerLazySingleton(() => UnpauseAgentUseCase(sl()));
  sl.registerLazySingleton(() => GetParkedCallsUseCase(sl()));
  sl.registerLazySingleton(() => GetAgentDetailsUseCase(sl()));
  sl.registerLazySingleton(() => ExportCdrToCsvUseCase());

  // Blocs - registered as factory for fresh instances
  sl.registerFactory(() => DashboardBloc(sl(), sl()));
  sl.registerFactory(() => ExtensionBloc(sl()));
  sl.registerFactory(() => CdrBloc(getCdrRecordsUseCase: sl(), exportCdrToCsvUseCase: sl()));
  sl.registerFactory(() => ActiveCallBloc(sl(), sl(), sl()));
  sl.registerFactory(() => QueueBloc(
    getQueueStatusUseCase: sl(),
    pauseAgentUseCase: sl(),
    unpauseAgentUseCase: sl(),
  ));
  sl.registerFactory(() => TrunkBloc(getTrunksUseCase: sl()));
  sl.registerFactory(() => ParkingBloc(getParkedCallsUseCase: sl()));
  sl.registerFactory(() => AgentDetailBloc(
    getAgentDetailsUseCase: sl(),
    pauseAgentUseCase: sl(),
    unpauseAgentUseCase: sl(),
  ));
}
