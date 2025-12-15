import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/wireless/presentation/bloc/wireless_bloc.dart';
import 'package:hsmik/features/wireless/presentation/bloc/wireless_event.dart';
import 'package:hsmik/features/wireless/presentation/bloc/wireless_state.dart';
import 'package:hsmik/features/wireless/domain/entities/wireless_interface.dart';
import 'package:hsmik/features/wireless/domain/entities/wireless_registration.dart';
import 'package:hsmik/features/wireless/domain/entities/security_profile.dart';
import 'package:hsmik/features/wireless/domain/entities/access_list_entry.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/wireless_mocks.dart';

void main() {
  late WirelessBloc bloc;
  late MockGetWirelessInterfacesUseCase mockGetInterfacesUseCase;
  late MockGetWirelessRegistrationsUseCase mockGetRegistrationsUseCase;
  late MockGetRegistrationsByInterfaceUseCase mockGetRegistrationsByInterfaceUseCase;
  late MockDisconnectClientUseCase mockDisconnectClientUseCase;
  late MockGetSecurityProfilesUseCase mockGetSecurityProfilesUseCase;
  late MockEnableWirelessInterfaceUseCase mockEnableInterfaceUseCase;
  late MockDisableWirelessInterfaceUseCase mockDisableInterfaceUseCase;
  late MockCreateSecurityProfileUseCase mockCreateProfileUseCase;
  late MockUpdateSecurityProfileUseCase mockUpdateProfileUseCase;
  late MockDeleteSecurityProfileUseCase mockDeleteProfileUseCase;
  late MockScanWirelessNetworksUseCase mockScanNetworksUseCase;
  late MockGetAccessListUseCase mockGetAccessListUseCase;
  late MockAddAccessListEntryUseCase mockAddAccessListUseCase;
  late MockRemoveAccessListEntryUseCase mockRemoveAccessListUseCase;
  late MockUpdateAccessListEntryUseCase mockUpdateAccessListUseCase;
  late MockUpdateWirelessSsidUseCase mockUpdateSsidUseCase;
  late MockGetWirelessPasswordUseCase mockGetPasswordUseCase;
  late MockUpdateWirelessPasswordUseCase mockUpdatePasswordUseCase;
  late MockAddVirtualWirelessInterfaceUseCase mockAddVirtualInterfaceUseCase;

  setUp(() {
    mockGetInterfacesUseCase = MockGetWirelessInterfacesUseCase();
    mockGetRegistrationsUseCase = MockGetWirelessRegistrationsUseCase();
    mockGetRegistrationsByInterfaceUseCase = MockGetRegistrationsByInterfaceUseCase();
    mockDisconnectClientUseCase = MockDisconnectClientUseCase();
    mockGetSecurityProfilesUseCase = MockGetSecurityProfilesUseCase();
    mockEnableInterfaceUseCase = MockEnableWirelessInterfaceUseCase();
    mockDisableInterfaceUseCase = MockDisableWirelessInterfaceUseCase();
    mockCreateProfileUseCase = MockCreateSecurityProfileUseCase();
    mockUpdateProfileUseCase = MockUpdateSecurityProfileUseCase();
    mockDeleteProfileUseCase = MockDeleteSecurityProfileUseCase();
    mockScanNetworksUseCase = MockScanWirelessNetworksUseCase();
    mockGetAccessListUseCase = MockGetAccessListUseCase();
    mockAddAccessListUseCase = MockAddAccessListEntryUseCase();
    mockRemoveAccessListUseCase = MockRemoveAccessListEntryUseCase();
    mockUpdateAccessListUseCase = MockUpdateAccessListEntryUseCase();
    mockUpdateSsidUseCase = MockUpdateWirelessSsidUseCase();
    mockGetPasswordUseCase = MockGetWirelessPasswordUseCase();
    mockUpdatePasswordUseCase = MockUpdateWirelessPasswordUseCase();
    mockAddVirtualInterfaceUseCase = MockAddVirtualWirelessInterfaceUseCase();

    bloc = WirelessBloc(
      getWirelessInterfacesUseCase: mockGetInterfacesUseCase,
      getWirelessRegistrationsUseCase: mockGetRegistrationsUseCase,
      getRegistrationsByInterfaceUseCase: mockGetRegistrationsByInterfaceUseCase,
      disconnectClientUseCase: mockDisconnectClientUseCase,
      getSecurityProfilesUseCase: mockGetSecurityProfilesUseCase,
      enableWirelessInterfaceUseCase: mockEnableInterfaceUseCase,
      disableWirelessInterfaceUseCase: mockDisableInterfaceUseCase,
      createSecurityProfileUseCase: mockCreateProfileUseCase,
      updateSecurityProfileUseCase: mockUpdateProfileUseCase,
      deleteSecurityProfileUseCase: mockDeleteProfileUseCase,
      scanWirelessNetworksUseCase: mockScanNetworksUseCase,
      getAccessListUseCase: mockGetAccessListUseCase,
      addAccessListEntryUseCase: mockAddAccessListUseCase,
      removeAccessListEntryUseCase: mockRemoveAccessListUseCase,
      updateAccessListEntryUseCase: mockUpdateAccessListUseCase,
      updateWirelessSsidUseCase: mockUpdateSsidUseCase,
      getWirelessPasswordUseCase: mockGetPasswordUseCase,
      updateWirelessPasswordUseCase: mockUpdatePasswordUseCase,
      addVirtualWirelessInterfaceUseCase: mockAddVirtualInterfaceUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('WirelessBloc', () {
    test('initial state should have empty lists', () {
      expect(bloc.state, WirelessState.initial());
      expect(bloc.state.interfaces, isEmpty);
      expect(bloc.state.registrations, isEmpty);
      expect(bloc.state.profiles, isEmpty);
    });

    group('LoadWirelessInterfaces', () {
      final tInterfaces = [
        const WirelessInterface(
          id: '*1',
          name: 'wlan1',
          ssid: 'TestNetwork',
          mode: 'ap-bridge',
          band: '2ghz-b/g/n',
          channelWidth: 20,
          frequency: '2412',
          disabled: false,
          status: 'running',
          clients: 0,
          macAddress: 'AA:BB:CC:DD:EE:FF',
          security: 'wpa2-psk',
          txPower: 20,
        ),
      ];

      blocTest<WirelessBloc, WirelessState>(
        'should load interfaces successfully',
        build: () {
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => Right(tInterfaces));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWirelessInterfaces()),
        expect: () => [
          WirelessState.initial().copyWith(interfacesLoading: true),
          WirelessState.initial().copyWith(
            interfacesLoading: false,
            interfaces: tInterfaces,
          ),
        ],
        verify: (_) {
          verify(() => mockGetInterfacesUseCase()).called(1);
        },
      );

      blocTest<WirelessBloc, WirelessState>(
        'should emit error when loading fails',
        build: () {
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWirelessInterfaces()),
        expect: () => [
          WirelessState.initial().copyWith(interfacesLoading: true),
          WirelessState.initial().copyWith(
            interfacesLoading: false,
            interfacesError: 'Load failed',
          ),
        ],
      );
    });

    group('LoadWirelessRegistrations', () {
      final tRegistrations = <WirelessRegistration>[
        const WirelessRegistration(
          id: '*1',
          interface: 'wlan1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          uptime: '1h',
          signalStrength: -45,
          txRate: 144,
          rxRate: 72,
          ipAddress: '192.168.1.100',
          hostname: 'client1',
          comment: '',
        ),
      ];

      blocTest<WirelessBloc, WirelessState>(
        'should load registrations successfully',
        build: () {
          when(() => mockGetRegistrationsUseCase())
              .thenAnswer((_) async => Right(tRegistrations));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadWirelessRegistrations()),
        expect: () => [
          WirelessState.initial().copyWith(registrationsLoading: true),
          WirelessState.initial().copyWith(
            registrationsLoading: false,
            registrations: tRegistrations,
          ),
        ],
        verify: (_) {
          verify(() => mockGetRegistrationsUseCase()).called(1);
        },
      );
    });

    group('DisconnectWirelessClient', () {
      final tRegistrations = [
        const WirelessRegistration(
          id: '*1',
          interface: 'wlan1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          ipAddress: '192.168.1.100',
          uptime: '1h',
          signalStrength: -45,
          txRate: 144,
          rxRate: 72,
          hostname: 'client1',
          comment: '',
        ),
      ];

      blocTest<WirelessBloc, WirelessState>(
        'should disconnect client and reload registrations',
        build: () {
          when(() => mockDisconnectClientUseCase('AA:BB:CC:DD:EE:FF', 'wlan1'))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetRegistrationsUseCase())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => WirelessState.initial().copyWith(registrations: tRegistrations),
        act: (bloc) => bloc.add(const DisconnectWirelessClient('AA:BB:CC:DD:EE:FF', 'wlan1')),
        expect: () => [
          WirelessState.initial().copyWith(
            registrations: tRegistrations,
            operationSuccess: 'Wireless client disconnected successfully',
          ),
          WirelessState.initial().copyWith(
            registrations: tRegistrations,
            registrationsLoading: true,
          ),
          WirelessState.initial().copyWith(
            registrations: [],
            registrationsLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockDisconnectClientUseCase('AA:BB:CC:DD:EE:FF', 'wlan1')).called(1);
          verify(() => mockGetRegistrationsUseCase()).called(1);
        },
      );
    });

    group('LoadSecurityProfiles', () {
      final tProfiles = [
        const SecurityProfile(
          id: '*1',
          name: 'test-profile',
          mode: 'dynamic-keys',
          authentication: 'wpa2-psk',
          encryption: 'aes-ccm',
          password: 'test123',
          managementProtection: false,
          wpaPreSharedKey: 0,
          wpa2PreSharedKey: 0,
        ),
      ];

      blocTest<WirelessBloc, WirelessState>(
        'should load security profiles successfully',
        build: () {
          when(() => mockGetSecurityProfilesUseCase())
              .thenAnswer((_) async => Right(tProfiles));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadSecurityProfiles()),
        expect: () => [
          WirelessState.initial().copyWith(profilesLoading: true),
          WirelessState.initial().copyWith(
            profilesLoading: false,
            profiles: tProfiles,
          ),
        ],
        verify: (_) {
          verify(() => mockGetSecurityProfilesUseCase()).called(1);
        },
      );
    });

    group('LoadAccessList', () {
      final tAccessList = [
        const AccessListEntry(
          id: '*1',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          interface: 'wlan1',
          comment: 'Test device',
          authentication: true,
          forwarding: true,
        ),
      ];

      blocTest<WirelessBloc, WirelessState>(
        'should load access list successfully',
        build: () {
          when(() => mockGetAccessListUseCase())
              .thenAnswer((_) async => Right(tAccessList));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAccessList()),
        expect: () => [
          WirelessState.initial().copyWith(accessListLoading: true),
          WirelessState.initial().copyWith(
            accessListLoading: false,
            accessList: tAccessList,
          ),
        ],
        verify: (_) {
          verify(() => mockGetAccessListUseCase()).called(1);
        },
      );
    });
  });
}
