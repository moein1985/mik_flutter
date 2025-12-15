import 'package:mocktail/mocktail.dart';
import 'package:hsmik/features/wireless/domain/usecases/get_wireless_interfaces_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/get_wireless_registrations_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/scan_wireless_networks_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/get_access_list_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/add_access_list_entry_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/remove_access_list_entry_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/update_access_list_entry_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/update_wireless_ssid_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/get_wireless_password_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/update_wireless_password_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/add_virtual_wireless_interface_usecase.dart';
import 'package:hsmik/features/wireless/domain/usecases/get_security_profiles_usecase.dart';

class MockGetWirelessInterfacesUseCase extends Mock implements GetWirelessInterfacesUseCase {}

class MockGetWirelessRegistrationsUseCase extends Mock implements GetWirelessRegistrationsUseCase {}

class MockGetRegistrationsByInterfaceUseCase extends Mock implements GetRegistrationsByInterfaceUseCase {}

class MockDisconnectClientUseCase extends Mock implements DisconnectClientUseCase {}

class MockGetSecurityProfilesUseCase extends Mock implements GetSecurityProfilesUseCase {}

class MockEnableWirelessInterfaceUseCase extends Mock implements EnableWirelessInterfaceUseCase {}

class MockDisableWirelessInterfaceUseCase extends Mock implements DisableWirelessInterfaceUseCase {}

class MockCreateSecurityProfileUseCase extends Mock implements CreateSecurityProfileUseCase {}

class MockUpdateSecurityProfileUseCase extends Mock implements UpdateSecurityProfileUseCase {}

class MockDeleteSecurityProfileUseCase extends Mock implements DeleteSecurityProfileUseCase {}

class MockScanWirelessNetworksUseCase extends Mock implements ScanWirelessNetworksUseCase {}

class MockGetAccessListUseCase extends Mock implements GetAccessListUseCase {}

class MockAddAccessListEntryUseCase extends Mock implements AddAccessListEntryUseCase {}

class MockRemoveAccessListEntryUseCase extends Mock implements RemoveAccessListEntryUseCase {}

class MockUpdateAccessListEntryUseCase extends Mock implements UpdateAccessListEntryUseCase {}

class MockUpdateWirelessSsidUseCase extends Mock implements UpdateWirelessSsidUseCase {}

class MockGetWirelessPasswordUseCase extends Mock implements GetWirelessPasswordUseCase {}

class MockUpdateWirelessPasswordUseCase extends Mock implements UpdateWirelessPasswordUseCase {}

class MockAddVirtualWirelessInterfaceUseCase extends Mock implements AddVirtualWirelessInterfaceUseCase {}
