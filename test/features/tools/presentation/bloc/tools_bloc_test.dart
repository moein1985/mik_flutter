import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/tools/presentation/bloc/tools_bloc.dart';
import 'package:hsmik/features/tools/presentation/bloc/tools_event.dart';
import 'package:hsmik/features/tools/presentation/bloc/tools_state.dart';
import 'package:hsmik/features/tools/domain/entities/dns_lookup_result.dart';
import 'package:hsmik/features/dashboard/domain/entities/router_interface.dart';
import 'package:hsmik/features/dashboard/domain/entities/ip_address.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/tools_mocks.dart';

void main() {
  late ToolsBloc bloc;
  late MockPingUseCase mockPingUseCase;
  late MockTracerouteUseCase mockTracerouteUseCase;
  late MockDnsLookupUseCase mockDnsLookupUseCase;
  late MockGetInterfacesUseCase mockGetInterfacesUseCase;
  late MockGetIpAddressesUseCase mockGetIpAddressesUseCase;

  setUp(() {
    mockPingUseCase = MockPingUseCase();
    mockTracerouteUseCase = MockTracerouteUseCase();
    mockDnsLookupUseCase = MockDnsLookupUseCase();
    mockGetInterfacesUseCase = MockGetInterfacesUseCase();
    mockGetIpAddressesUseCase = MockGetIpAddressesUseCase();

    // Setup mock for stop methods
    when(() => mockPingUseCase.stop()).thenAnswer((_) async => const Right(null));
    when(() => mockTracerouteUseCase.stop()).thenAnswer((_) async => const Right(null));

    bloc = ToolsBloc(
      pingUseCase: mockPingUseCase,
      tracerouteUseCase: mockTracerouteUseCase,
      dnsLookupUseCase: mockDnsLookupUseCase,
      getInterfacesUseCase: mockGetInterfacesUseCase,
      getIpAddressesUseCase: mockGetIpAddressesUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ToolsBloc', () {
    test('initial state should be ToolsInitial', () {
      expect(bloc.state, const ToolsInitial());
    });

    group('LoadNetworkInfo', () {
      final tInterfaces = [
        const RouterInterface(
          id: '*1',
          name: 'ether1',
          type: 'ether',
          disabled: false,
          running: true,
        ),
      ];

      final tIpAddresses = <IpAddress>[
        const IpAddress(
          id: '*1',
          address: '192.168.1.1/24',
          interfaceName: 'ether1',
          network: '192.168.1.0',
          disabled: false,
          invalid: false,
          dynamic: false,
        ),
      ];

      blocTest<ToolsBloc, ToolsState>(
        'should cache interfaces and IP addresses',
        build: () {
          when(() => mockGetInterfacesUseCase())
              .thenAnswer((_) async => Right(tInterfaces));
          when(() => mockGetIpAddressesUseCase())
              .thenAnswer((_) async => Right(tIpAddresses));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadNetworkInfo()),
        wait: const Duration(milliseconds: 100),
        verify: (_) {
          expect(bloc.interfaces, ['ether1']);
          expect(bloc.ipAddresses, ['192.168.1.1']);
          verify(() => mockGetInterfacesUseCase()).called(1);
          verify(() => mockGetIpAddressesUseCase()).called(1);
        },
      );
    });

    group('StartDnsLookup', () {
      final tLookupResult = const DnsLookupResult(
        domain: '8.8.8.8',
        ipv4Addresses: ['8.8.8.8'],
      );

      blocTest<ToolsBloc, ToolsState>(
        'should perform DNS lookup successfully',
        build: () {
          when(() => mockDnsLookupUseCase(domain: '8.8.8.8', timeout: 5000))
              .thenAnswer((_) async => Right(tLookupResult));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartDnsLookup(domain: '8.8.8.8')),
        expect: () => [
          const DnsLookupInProgress(),
          DnsLookupCompleted(tLookupResult),
        ],
        verify: (_) {
          verify(() => mockDnsLookupUseCase(domain: '8.8.8.8', timeout: 5000)).called(1);
        },
      );

      blocTest<ToolsBloc, ToolsState>(
        'should emit error when DNS lookup fails',
        build: () {
          when(() => mockDnsLookupUseCase(domain: 'invalid', timeout: 5000))
              .thenAnswer((_) async => const Left(ServerFailure('DNS lookup failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const StartDnsLookup(domain: 'invalid')),
        expect: () => [
          const DnsLookupInProgress(),
          const DnsLookupFailed('DNS lookup failed'),
        ],
      );
    });

    group('ClearResults', () {
      blocTest<ToolsBloc, ToolsState>(
        'should return to initial state',
        build: () => bloc,
        seed: () => const DnsLookupCompleted(
          DnsLookupResult(
            domain: '8.8.8.8',
            ipv4Addresses: ['8.8.8.8'],
          ),
        ),
        act: (bloc) => bloc.add(const ClearResults()),
        expect: () => [
          const ToolsInitial(),
        ],
      );
    });
  });
}
