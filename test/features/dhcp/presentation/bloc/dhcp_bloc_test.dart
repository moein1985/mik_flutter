import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/dhcp/presentation/bloc/dhcp_bloc.dart';
import 'package:hsmik/features/dhcp/presentation/bloc/dhcp_event.dart';
import 'package:hsmik/features/dhcp/presentation/bloc/dhcp_state.dart';
import 'package:hsmik/features/dhcp/domain/entities/dhcp_server.dart';
import 'package:hsmik/features/dhcp/domain/entities/dhcp_network.dart';
import 'package:hsmik/features/dhcp/domain/entities/dhcp_lease.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/dhcp_mocks.dart';

void main() {
  late DhcpBloc bloc;
  late MockDhcpRepository mockRepository;

  setUp(() {
    mockRepository = MockDhcpRepository();
    bloc = DhcpBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('DhcpBloc', () {
    test('initial state should be DhcpInitial', () {
      expect(bloc.state, const DhcpInitial());
    });

    group('LoadDhcpServers', () {
      final tServers = [
        const DhcpServer(
          id: '*1',
          name: 'dhcp1',
          interface: 'bridge1',
          addressPool: 'pool1',
          leaseTime: '10m',
          disabled: false,          invalid: false,
          authoritative: true,        ),
      ];

      blocTest<DhcpBloc, DhcpState>(
        'should emit [DhcpLoading, DhcpLoaded] when successful',
        build: () {
          when(() => mockRepository.getServers())
              .thenAnswer((_) async => Right(tServers));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDhcpServers()),
        expect: () => [
          const DhcpLoading(),
          DhcpLoaded(servers: tServers),
        ],
        verify: (_) {
          verify(() => mockRepository.getServers()).called(1);
        },
      );

      blocTest<DhcpBloc, DhcpState>(
        'should emit [DhcpLoading, DhcpError] when failed',
        build: () {
          when(() => mockRepository.getServers())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadDhcpServers()),
        expect: () => [
          const DhcpLoading(),
          const DhcpError('Server error'),
        ],
      );
    });

    group('LoadDhcpNetworks', () {
      final tNetworks = [
        const DhcpNetwork(
          id: '*1',
          address: '192.168.88.0/24',
          gateway: '192.168.88.1',
          dnsServer: '8.8.8.8',
        ),
      ];

      blocTest<DhcpBloc, DhcpState>(
        'should update DhcpLoaded with networks when successful',
        build: () {
          when(() => mockRepository.getNetworks())
              .thenAnswer((_) async => Right(tNetworks));
          return bloc;
        },
        seed: () => const DhcpLoaded(servers: []),
        act: (bloc) => bloc.add(const LoadDhcpNetworks()),
        expect: () => [
          DhcpLoaded(servers: const [], networks: tNetworks),
        ],
        verify: (_) {
          verify(() => mockRepository.getNetworks()).called(1);
        },
      );

      blocTest<DhcpBloc, DhcpState>(
        'should emit DhcpError when failed',
        build: () {
          when(() => mockRepository.getNetworks())
              .thenAnswer((_) async => const Left(ServerFailure('Failed to load networks')));
          return bloc;
        },
        seed: () => const DhcpLoaded(servers: []),
        act: (bloc) => bloc.add(const LoadDhcpNetworks()),
        expect: () => [
          const DhcpError('Failed to load networks'),
        ],
      );
    });

    group('LoadDhcpLeases', () {
      final tLeases = <DhcpLease>[
        const DhcpLease(
          id: '*1',
          address: '192.168.88.100',
          macAddress: '00:11:22:33:44:55',
          server: 'dhcp1',
          status: 'bound',
          dynamic: true,
          disabled: false,
          blocked: false,
        ),
      ];

      blocTest<DhcpBloc, DhcpState>(
        'should update DhcpLoaded with leases when successful',
        build: () {
          when(() => mockRepository.getLeases())
              .thenAnswer((_) async => Right(tLeases));
          return bloc;
        },
        seed: () => const DhcpLoaded(servers: []),
        act: (bloc) => bloc.add(const LoadDhcpLeases()),
        expect: () => [
          DhcpLoaded(servers: const [], leases: tLeases),
        ],
        verify: (_) {
          verify(() => mockRepository.getLeases()).called(1);
        },
      );
    });
  });
}
