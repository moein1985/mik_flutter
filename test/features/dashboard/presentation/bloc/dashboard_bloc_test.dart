import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:hsmik/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:hsmik/features/dashboard/domain/entities/system_resource.dart';
import 'package:hsmik/features/dashboard/domain/entities/router_interface.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/dashboard_mocks.dart';

void main() {
  late DashboardBloc bloc;
  late MockGetSystemResourcesUseCase mockGetSystemResourcesUseCase;
  late MockGetInterfacesUseCase mockGetInterfacesUseCase;
  late MockToggleInterfaceUseCase mockToggleInterfaceUseCase;
  late MockGetIpAddressesUseCase mockGetIpAddressesUseCase;
  late MockAddIpAddressUseCase mockAddIpAddressUseCase;
  late MockUpdateIpAddressUseCase mockUpdateIpAddressUseCase;
  late MockRemoveIpAddressUseCase mockRemoveIpAddressUseCase;
  late MockToggleIpAddressUseCase mockToggleIpAddressUseCase;
  late MockGetFirewallRulesUseCase mockGetFirewallRulesUseCase;
  late MockToggleFirewallRuleUseCase mockToggleFirewallRuleUseCase;

  setUp(() {
    mockGetSystemResourcesUseCase = MockGetSystemResourcesUseCase();
    mockGetInterfacesUseCase = MockGetInterfacesUseCase();
    mockToggleInterfaceUseCase = MockToggleInterfaceUseCase();
    mockGetIpAddressesUseCase = MockGetIpAddressesUseCase();
    mockAddIpAddressUseCase = MockAddIpAddressUseCase();
    mockUpdateIpAddressUseCase = MockUpdateIpAddressUseCase();
    mockRemoveIpAddressUseCase = MockRemoveIpAddressUseCase();
    mockToggleIpAddressUseCase = MockToggleIpAddressUseCase();
    mockGetFirewallRulesUseCase = MockGetFirewallRulesUseCase();
    mockToggleFirewallRuleUseCase = MockToggleFirewallRuleUseCase();

    bloc = DashboardBloc(
      getSystemResourcesUseCase: mockGetSystemResourcesUseCase,
      getInterfacesUseCase: mockGetInterfacesUseCase,
      toggleInterfaceUseCase: mockToggleInterfaceUseCase,
      getIpAddressesUseCase: mockGetIpAddressesUseCase,
      addIpAddressUseCase: mockAddIpAddressUseCase,
      updateIpAddressUseCase: mockUpdateIpAddressUseCase,
      removeIpAddressUseCase: mockRemoveIpAddressUseCase,
      toggleIpAddressUseCase: mockToggleIpAddressUseCase,
      getFirewallRulesUseCase: mockGetFirewallRulesUseCase,
      toggleFirewallRuleUseCase: mockToggleFirewallRuleUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('DashboardBloc', () {
    test('initial state should be DashboardInitial', () {
      expect(bloc.state, const DashboardInitial());
    });

    group('LoadDashboardData', () {
      const tSystemResource = SystemResource(
        uptime: '1d 2h 30m',
        cpuLoad: '25%',
        freeMemory: '128M',
        totalMemory: '256M',
        freeHddSpace: '50M',
        totalHddSpace: '128M',
        version: '7.10',
        architectureName: 'x86_64',
        boardName: 'RB750Gr3',
        platform: 'MikroTik',
      );

      blocTest<DashboardBloc, DashboardState>(
        'should emit [DashboardLoading, DashboardLoaded] when successful',
        build: () {
          when(() => mockGetSystemResourcesUseCase())
              .thenAnswer((_) async => const Right(tSystemResource));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDashboardData()),
        expect: () => [
          const DashboardLoading(),
          const DashboardLoaded(systemResource: tSystemResource),
        ],
        verify: (_) {
          verify(() => mockGetSystemResourcesUseCase()).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'should emit [DashboardLoading, DashboardError] when failed',
        build: () {
          when(() => mockGetSystemResourcesUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDashboardData()),
        expect: () => [
          const DashboardLoading(),
          const DashboardError('Server error'),
        ],
      );
    });

    group('LoadInterfaces', () {
      const tSystemResource = SystemResource(
        uptime: '1d 2h 30m',
        cpuLoad: '25%',
        freeMemory: '128M',
        totalMemory: '256M',
        freeHddSpace: '50M',
        totalHddSpace: '128M',
        version: '7.10',
        architectureName: 'x86_64',
        boardName: 'RB750Gr3',
        platform: 'MikroTik',
      );

      final tInterfaces = [
        const RouterInterface(
          id: '*1',
          name: 'ether1',
          type: 'ether',
          running: true,
          disabled: false,
          comment: 'WAN',
        ),
        const RouterInterface(
          id: '*2',
          name: 'ether2',
          type: 'ether',
          running: true,
          disabled: false,
          comment: 'LAN',
        ),
      ];

      blocTest<DashboardBloc, DashboardState>(
        'should emit DashboardLoaded with interfaces when successful',
        build: () {
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => Right(tInterfaces));
          return bloc;
        },
        seed: () => const DashboardLoaded(systemResource: tSystemResource),
        act: (bloc) => bloc.add(const LoadInterfaces()),
        expect: () => [
          DashboardLoaded(
            systemResource: tSystemResource,
            interfaces: tInterfaces,
          ),
        ],
        verify: (_) {
          verify(() => mockGetInterfacesUseCase()).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'should emit DashboardLoaded with error message when failed',
        build: () {
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Failed to load interfaces')));
          return bloc;
        },
        seed: () => DashboardLoaded(systemResource: tSystemResource),
        act: (bloc) => bloc.add(const LoadInterfaces()),
        expect: () => [
          const DashboardLoaded(
            systemResource: tSystemResource,
            errorMessage: 'Failed to load interfaces',
          ),
        ],
      );
    });

    group('ToggleInterface', () {
      const tSystemResource = SystemResource(
        uptime: '1d 2h 30m',
        cpuLoad: '25%',
        freeMemory: '128M',
        totalMemory: '256M',
        freeHddSpace: '50M',
        totalHddSpace: '128M',
        version: '7.10',
        architectureName: 'x86_64',
        boardName: 'RB750Gr3',
        platform: 'MikroTik',
      );

      final tInterfaces = [
        const RouterInterface(
          id: '*1',
          name: 'ether1',
          type: 'ether',
          running: true,
          disabled: false,
        ),
      ];

      final tUpdatedInterfaces = [
        const RouterInterface(
          id: '*1',
          name: 'ether1',
          type: 'ether',
          running: false,
          disabled: true,
        ),
      ];

      blocTest<DashboardBloc, DashboardState>(
        'should toggle interface and reload interfaces when successful',
        build: () {
          when(() => mockToggleInterfaceUseCase.call('*1', false))
              .thenAnswer((_) async => const Right(true));
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => Right(tUpdatedInterfaces));
          return bloc;
        },
        seed: () => DashboardLoaded(
          systemResource: tSystemResource,
          interfaces: tInterfaces,
        ),
        act: (bloc) => bloc.add(const ToggleInterface(id: '*1', enable: false)),
        expect: () => [
          DashboardLoaded(
            systemResource: tSystemResource,
            interfaces: tUpdatedInterfaces,
          ),
        ],
        verify: (_) {
          verify(() => mockToggleInterfaceUseCase.call('*1', false)).called(1);
          verify(() => mockGetInterfacesUseCase()).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'should emit error when toggle fails',
        build: () {
          when(() => mockToggleInterfaceUseCase.call('*1', false))
              .thenAnswer((_) async => const Left(ServerFailure('Toggle failed')));
          return bloc;
        },
        seed: () => DashboardLoaded(
          systemResource: tSystemResource,
          interfaces: tInterfaces,
        ),
        act: (bloc) => bloc.add(const ToggleInterface(id: '*1', enable: false)),
        expect: () => [
          DashboardLoaded(
            systemResource: tSystemResource,
            interfaces: tInterfaces,
            errorMessage: 'Toggle failed',
          ),
        ],
      );
    });

    group('ClearError', () {
      const tSystemResource = SystemResource(
        uptime: '1d 2h 30m',
        cpuLoad: '25%',
        freeMemory: '128M',
        totalMemory: '256M',
        freeHddSpace: '50M',
        totalHddSpace: '128M',
        version: '7.10',
        architectureName: 'x86_64',
        boardName: 'RB750Gr3',
        platform: 'MikroTik',
      );

      blocTest<DashboardBloc, DashboardState>(
        'should clear error message from DashboardLoaded state',
        build: () => bloc,
        seed: () => const DashboardLoaded(
          systemResource: tSystemResource,
          errorMessage: 'Some error',
        ),
        act: (bloc) => bloc.add(const ClearError()),
        expect: () => [
          const DashboardLoaded(
            systemResource: tSystemResource,
            errorMessage: null,
          ),
        ],
      );
    });
  });
}
