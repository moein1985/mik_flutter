import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/hotspot/domain/repositories/hotspot_repository.dart';
import 'package:hsmik/features/hotspot/data/datasources/hotspot_remote_data_source.dart';
import 'package:hsmik/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hsmik/core/network/routeros_client.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_servers_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_users_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_active_users_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_profiles_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/toggle_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/disconnect_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/setup_hotspot_usecase.dart';

class MockHotspotRepository extends Mock implements HotspotRepository {}

class MockHotspotRemoteDataSource extends Mock implements HotspotRemoteDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockRouterOSClient extends Mock implements RouterOSClient {}

class MockGetServersUseCase extends Mock implements GetServersUseCase {}

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockGetActiveUsersUseCase extends Mock implements GetActiveUsersUseCase {}

class MockGetProfilesUseCase extends Mock implements GetProfilesUseCase {}

class MockAddUserUseCase extends Mock implements AddUserUseCase {}

class MockToggleUserUseCase extends Mock implements ToggleUserUseCase {}

class MockDisconnectUserUseCase extends Mock implements DisconnectUserUseCase {}

class MockSetupHotspotUseCase extends Mock implements SetupHotspotUseCase {}