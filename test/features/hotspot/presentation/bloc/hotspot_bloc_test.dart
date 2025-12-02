import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_server.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_user.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_active_user.dart';
import 'package:hsmik/features/hotspot/domain/entities/hotspot_profile.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_bloc.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_event.dart';
import 'package:hsmik/features/hotspot/presentation/bloc/hotspot_state.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late HotspotBloc bloc;
  late MockGetServersUseCase mockGetServersUseCase;
  late MockGetUsersUseCase mockGetUsersUseCase;
  late MockGetActiveUsersUseCase mockGetActiveUsersUseCase;
  late MockGetProfilesUseCase mockGetProfilesUseCase;
  late MockAddUserUseCase mockAddUserUseCase;
  late MockEditUserUseCase mockEditUserUseCase;
  late MockDeleteUserUseCase mockDeleteUserUseCase;
  late MockResetUserCountersUseCase mockResetUserCountersUseCase;
  late MockToggleUserUseCase mockToggleUserUseCase;
  late MockDisconnectUserUseCase mockDisconnectUserUseCase;
  late MockSetupHotspotUseCase mockSetupHotspotUseCase;
  late MockHotspotRepository mockRepository;
  // New mocks
  late MockGetIpBindingsUseCase mockGetIpBindingsUseCase;
  late MockAddIpBindingUseCase mockAddIpBindingUseCase;
  late MockEditIpBindingUseCase mockEditIpBindingUseCase;
  late MockDeleteIpBindingUseCase mockDeleteIpBindingUseCase;
  late MockToggleIpBindingUseCase mockToggleIpBindingUseCase;
  late MockGetHostsUseCase mockGetHostsUseCase;
  late MockRemoveHostUseCase mockRemoveHostUseCase;
  late MockMakeHostBindingUseCase mockMakeHostBindingUseCase;
  late MockGetWalledGardenUseCase mockGetWalledGardenUseCase;
  late MockAddWalledGardenUseCase mockAddWalledGardenUseCase;
  late MockEditWalledGardenUseCase mockEditWalledGardenUseCase;
  late MockDeleteWalledGardenUseCase mockDeleteWalledGardenUseCase;
  late MockToggleWalledGardenUseCase mockToggleWalledGardenUseCase;
  late MockAddProfileUseCase mockAddProfileUseCase;
  late MockEditProfileUseCase mockEditProfileUseCase;
  late MockDeleteProfileUseCase mockDeleteProfileUseCase;
  late MockResetHotspotUseCase mockResetHotspotUseCase;

  setUp(() {
    mockGetServersUseCase = MockGetServersUseCase();
    mockGetUsersUseCase = MockGetUsersUseCase();
    mockGetActiveUsersUseCase = MockGetActiveUsersUseCase();
    mockGetProfilesUseCase = MockGetProfilesUseCase();
    mockAddUserUseCase = MockAddUserUseCase();
    mockEditUserUseCase = MockEditUserUseCase();
    mockDeleteUserUseCase = MockDeleteUserUseCase();
    mockResetUserCountersUseCase = MockResetUserCountersUseCase();
    mockToggleUserUseCase = MockToggleUserUseCase();
    mockDisconnectUserUseCase = MockDisconnectUserUseCase();
    mockSetupHotspotUseCase = MockSetupHotspotUseCase();
    mockRepository = MockHotspotRepository();
    // New mocks
    mockGetIpBindingsUseCase = MockGetIpBindingsUseCase();
    mockAddIpBindingUseCase = MockAddIpBindingUseCase();
    mockEditIpBindingUseCase = MockEditIpBindingUseCase();
    mockDeleteIpBindingUseCase = MockDeleteIpBindingUseCase();
    mockToggleIpBindingUseCase = MockToggleIpBindingUseCase();
    mockGetHostsUseCase = MockGetHostsUseCase();
    mockRemoveHostUseCase = MockRemoveHostUseCase();
    mockMakeHostBindingUseCase = MockMakeHostBindingUseCase();
    mockGetWalledGardenUseCase = MockGetWalledGardenUseCase();
    mockAddWalledGardenUseCase = MockAddWalledGardenUseCase();
    mockEditWalledGardenUseCase = MockEditWalledGardenUseCase();
    mockDeleteWalledGardenUseCase = MockDeleteWalledGardenUseCase();
    mockToggleWalledGardenUseCase = MockToggleWalledGardenUseCase();
    mockAddProfileUseCase = MockAddProfileUseCase();
    mockEditProfileUseCase = MockEditProfileUseCase();
    mockDeleteProfileUseCase = MockDeleteProfileUseCase();
    mockResetHotspotUseCase = MockResetHotspotUseCase();

    bloc = HotspotBloc(
      getServersUseCase: mockGetServersUseCase,
      getUsersUseCase: mockGetUsersUseCase,
      getActiveUsersUseCase: mockGetActiveUsersUseCase,
      getProfilesUseCase: mockGetProfilesUseCase,
      addUserUseCase: mockAddUserUseCase,
      editUserUseCase: mockEditUserUseCase,
      deleteUserUseCase: mockDeleteUserUseCase,
      resetUserCountersUseCase: mockResetUserCountersUseCase,
      toggleUserUseCase: mockToggleUserUseCase,
      disconnectUserUseCase: mockDisconnectUserUseCase,
      setupHotspotUseCase: mockSetupHotspotUseCase,
      repository: mockRepository,
      // New UseCases
      getIpBindingsUseCase: mockGetIpBindingsUseCase,
      addIpBindingUseCase: mockAddIpBindingUseCase,
      editIpBindingUseCase: mockEditIpBindingUseCase,
      deleteIpBindingUseCase: mockDeleteIpBindingUseCase,
      toggleIpBindingUseCase: mockToggleIpBindingUseCase,
      getHostsUseCase: mockGetHostsUseCase,
      removeHostUseCase: mockRemoveHostUseCase,
      makeHostBindingUseCase: mockMakeHostBindingUseCase,
      getWalledGardenUseCase: mockGetWalledGardenUseCase,
      addWalledGardenUseCase: mockAddWalledGardenUseCase,
      editWalledGardenUseCase: mockEditWalledGardenUseCase,
      deleteWalledGardenUseCase: mockDeleteWalledGardenUseCase,
      toggleWalledGardenUseCase: mockToggleWalledGardenUseCase,
      addProfileUseCase: mockAddProfileUseCase,
      editProfileUseCase: mockEditProfileUseCase,
      deleteProfileUseCase: mockDeleteProfileUseCase,
      resetHotspotUseCase: mockResetHotspotUseCase,
    );
  });

  const tServers = [
    HotspotServer(
      id: '*1',
      name: 'hotspot1',
      interfaceName: 'ether1',
      addressPool: 'hs-pool',
      disabled: false,
    ),
  ];

  const tUsers = [
    HotspotUser(
      id: '*1',
      name: 'user1',
      disabled: false,
    ),
  ];

  const tActiveUsers = [
    HotspotActiveUser(
      id: '*1',
      user: 'user1',
      server: 'hotspot1',
      address: '192.168.1.100',
      macAddress: 'AA:BB:CC:DD:EE:FF',
      loginBy: 'http-chap',
      uptime: '1d2h3m',
      sessionTimeLeft: '2h30m',
      idleTime: '5m',
      bytesIn: '1024',
      bytesOut: '2048',
      packetsIn: '100',
      packetsOut: '200',
    ),
  ];

  const tProfiles = [
    HotspotProfile(
      id: '*1',
      name: 'default',
    ),
  ];

  group('HotspotBloc', () {
    test('initial state should be HotspotInitial', () {
      expect(bloc.state, const HotspotInitial());
    });

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotLoaded] with servers when LoadHotspotServers succeeds',
      build: () {
        when(() => mockGetServersUseCase())
            .thenAnswer((_) async => const Right(tServers));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotServers()),
      expect: () => [
        HotspotLoaded(servers: tServers),
      ],
      verify: (_) {
        verify(() => mockGetServersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotError] when LoadHotspotServers fails',
      build: () {
        when(() => mockGetServersUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotServers()),
      expect: () => [
        const HotspotError('Server error'),
      ],
      verify: (_) {
        verify(() => mockGetServersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotLoaded] with users when LoadHotspotUsers succeeds',
      build: () {
        when(() => mockGetUsersUseCase())
            .thenAnswer((_) async => const Right(tUsers));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotUsers()),
      expect: () => [
        HotspotLoaded(users: tUsers),
      ],
      verify: (_) {
        verify(() => mockGetUsersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotError] when LoadHotspotUsers fails',
      build: () {
        when(() => mockGetUsersUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotUsers()),
      expect: () => [
        const HotspotError('Server error'),
      ],
      verify: (_) {
        verify(() => mockGetUsersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotLoaded] with activeUsers when LoadHotspotActiveUsers succeeds',
      build: () {
        when(() => mockGetActiveUsersUseCase())
            .thenAnswer((_) async => const Right(tActiveUsers));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotActiveUsers()),
      expect: () => [
        HotspotLoaded(activeUsers: tActiveUsers),
      ],
      verify: (_) {
        verify(() => mockGetActiveUsersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotError] when LoadHotspotActiveUsers fails',
      build: () {
        when(() => mockGetActiveUsersUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotActiveUsers()),
      expect: () => [
        const HotspotError('Server error'),
      ],
      verify: (_) {
        verify(() => mockGetActiveUsersUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotLoaded] with profiles when LoadHotspotProfiles succeeds',
      build: () {
        when(() => mockGetProfilesUseCase())
            .thenAnswer((_) async => const Right(tProfiles));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotProfiles()),
      expect: () => [
        HotspotLoaded(profiles: tProfiles),
      ],
      verify: (_) {
        verify(() => mockGetProfilesUseCase()).called(1);
      },
    );

    blocTest<HotspotBloc, HotspotState>(
      'should emit [HotspotError] when LoadHotspotProfiles fails',
      build: () {
        when(() => mockGetProfilesUseCase())
            .thenAnswer((_) async => const Left(ServerFailure('Server error')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadHotspotProfiles()),
      expect: () => [
        const HotspotError('Server error'),
      ],
      verify: (_) {
        verify(() => mockGetProfilesUseCase()).called(1);
      },
    );

    // Add more tests for other events similarly
  });
}