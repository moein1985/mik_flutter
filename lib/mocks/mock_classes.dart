import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/hotspot/domain/repositories/hotspot_repository.dart';
import 'package:hsmik/features/hotspot/data/datasources/hotspot_remote_data_source.dart';
import 'package:hsmik/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hsmik/core/network/routeros_client_v2.dart';
import 'package:hsmik/core/network/routeros_client.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_servers_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_users_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_active_users_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_profiles_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_user_usecase.dart';
import 'package:hsmik/features/certificates/domain/repositories/certificate_repository.dart';
import 'package:hsmik/features/certificates/data/datasources/certificate_remote_data_source.dart';
import 'package:hsmik/features/certificates/presentation/bloc/certificate_bloc.dart';
import 'package:hsmik/features/wireless/domain/repositories/wireless_repository.dart';
import 'package:hsmik/features/wireless/data/datasources/wireless_remote_data_source.dart';
import 'package:hsmik/features/hotspot/domain/usecases/edit_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/delete_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/reset_user_counters_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/toggle_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/disconnect_user_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/setup_hotspot_usecase.dart';
// New UseCases
import 'package:hsmik/features/hotspot/domain/usecases/get_ip_bindings_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_ip_binding_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/edit_ip_binding_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/delete_ip_binding_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/toggle_ip_binding_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_hosts_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/remove_host_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/make_host_binding_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/get_walled_garden_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_walled_garden_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/edit_walled_garden_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/delete_walled_garden_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/toggle_walled_garden_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/add_profile_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/edit_profile_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/delete_profile_usecase.dart';
import 'package:hsmik/features/hotspot/domain/usecases/reset_hotspot_usecase.dart';

class MockHotspotRepository extends Mock implements HotspotRepository {}

class MockHotspotRemoteDataSource extends Mock implements HotspotRemoteDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockRouterOSClientV2 extends Mock implements RouterOSClientV2 {}

class MockRouterOSClient extends Mock implements RouterOSClient {}

class MockGetServersUseCase extends Mock implements GetServersUseCase {}

class MockGetUsersUseCase extends Mock implements GetUsersUseCase {}

class MockGetActiveUsersUseCase extends Mock implements GetActiveUsersUseCase {}

class MockGetProfilesUseCase extends Mock implements GetProfilesUseCase {}

class MockAddUserUseCase extends Mock implements AddUserUseCase {}

class MockEditUserUseCase extends Mock implements EditUserUseCase {}

class MockDeleteUserUseCase extends Mock implements DeleteUserUseCase {}

class MockResetUserCountersUseCase extends Mock implements ResetUserCountersUseCase {}

class MockToggleUserUseCase extends Mock implements ToggleUserUseCase {}

class MockDisconnectUserUseCase extends Mock implements DisconnectUserUseCase {}

class MockSetupHotspotUseCase extends Mock implements SetupHotspotUseCase {}

// New Mock Classes
class MockGetIpBindingsUseCase extends Mock implements GetIpBindingsUseCase {}

class MockAddIpBindingUseCase extends Mock implements AddIpBindingUseCase {}

class MockEditIpBindingUseCase extends Mock implements EditIpBindingUseCase {}

class MockDeleteIpBindingUseCase extends Mock implements DeleteIpBindingUseCase {}

class MockToggleIpBindingUseCase extends Mock implements ToggleIpBindingUseCase {}

class MockGetHostsUseCase extends Mock implements GetHostsUseCase {}

class MockRemoveHostUseCase extends Mock implements RemoveHostUseCase {}

class MockMakeHostBindingUseCase extends Mock implements MakeHostBindingUseCase {}

class MockGetWalledGardenUseCase extends Mock implements GetWalledGardenUseCase {}

class MockAddWalledGardenUseCase extends Mock implements AddWalledGardenUseCase {}

class MockEditWalledGardenUseCase extends Mock implements EditWalledGardenUseCase {}

class MockDeleteWalledGardenUseCase extends Mock implements DeleteWalledGardenUseCase {}

class MockToggleWalledGardenUseCase extends Mock implements ToggleWalledGardenUseCase {}

class MockAddProfileUseCase extends Mock implements AddProfileUseCase {}

class MockEditProfileUseCase extends Mock implements EditProfileUseCase {}

class MockDeleteProfileUseCase extends Mock implements DeleteProfileUseCase {}

class MockResetHotspotUseCase extends Mock implements ResetHotspotUseCase {}

class MockCertificateRemoteDataSource extends Mock implements CertificateRemoteDataSource {}

class MockCertificateRepository extends Mock implements CertificateRepository {}

class MockCertificateBloc extends Mock implements CertificateBloc {}

class MockWirelessRepository extends Mock implements WirelessRepository {}

class MockWirelessRemoteDataSource extends Mock implements WirelessRemoteDataSource {}