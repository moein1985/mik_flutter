import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/firewall/presentation/bloc/firewall_bloc.dart';
import 'package:hsmik/features/firewall/presentation/bloc/firewall_event.dart';
import 'package:hsmik/features/firewall/presentation/bloc/firewall_state.dart';
import 'package:hsmik/features/firewall/domain/entities/firewall_rule.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/firewall_mocks.dart';

void main() {
  late FirewallBloc bloc;
  late MockGetFirewallRulesUseCase mockGetRulesUseCase;
  late MockToggleFirewallRuleUseCase mockToggleRuleUseCase;
  late MockGetAddressListNamesUseCase mockGetAddressListNamesUseCase;
  late MockGetAddressListByNameUseCase mockGetAddressListByNameUseCase;

  setUp(() {
    mockGetRulesUseCase = MockGetFirewallRulesUseCase();
    mockToggleRuleUseCase = MockToggleFirewallRuleUseCase();
    mockGetAddressListNamesUseCase = MockGetAddressListNamesUseCase();
    mockGetAddressListByNameUseCase = MockGetAddressListByNameUseCase();

    bloc = FirewallBloc(
      getFirewallRulesUseCase: mockGetRulesUseCase,
      toggleFirewallRuleUseCase: mockToggleRuleUseCase,
      getAddressListNamesUseCase: mockGetAddressListNamesUseCase,
      getAddressListByNameUseCase: mockGetAddressListByNameUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FirewallBloc', () {
    test('initial state should be FirewallInitial', () {
      expect(bloc.state, const FirewallInitial());
    });

    group('LoadFirewallRules', () {
      final tRules = <FirewallRule>[
        const FirewallRule(
          id: '*1',
          type: FirewallRuleType.filter,
          chain: 'forward',
          action: 'accept',
          disabled: false,
          dynamic: false,
          invalid: false,
          allParameters: {
            'chain': 'forward',
            'action': 'accept',
            'protocol': 'tcp',
            'src-address': '192.168.1.0/24',
            'dst-port': '80',
            'comment': 'Allow HTTP',
          },
        ),
      ];

      blocTest<FirewallBloc, FirewallState>(
        'should emit [FirewallLoading, FirewallLoaded] when successful',
        build: () {
          when(() => mockGetRulesUseCase(FirewallRuleType.filter))
              .thenAnswer((_) async => Right(tRules));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadFirewallRules(FirewallRuleType.filter)),
        expect: () => [
          isA<FirewallLoaded>()
              .having((s) => s.loadingType, 'loadingType', FirewallRuleType.filter),
          isA<FirewallLoaded>()
              .having((s) => s.rulesByType[FirewallRuleType.filter], 'rules', tRules)
              .having((s) => s.loadingType, 'loadingType', null),
        ],
        verify: (_) {
          verify(() => mockGetRulesUseCase(FirewallRuleType.filter)).called(1);
        },
      );

      blocTest<FirewallBloc, FirewallState>(
        'should emit [FirewallLoading, FirewallError] when failed',
        build: () {
          when(() => mockGetRulesUseCase(FirewallRuleType.filter))
              .thenAnswer((_) async => const Left(ServerFailure('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadFirewallRules(FirewallRuleType.filter)),
        expect: () => [
          isA<FirewallLoaded>()
              .having((s) => s.loadingType, 'loadingType', FirewallRuleType.filter),
          isA<FirewallError>()
              .having((s) => s.message, 'message', 'Load failed'),
        ],
      );

      blocTest<FirewallBloc, FirewallState>(
        'should load NAT rules separately',
        build: () {
          when(() => mockGetRulesUseCase(FirewallRuleType.nat))
              .thenAnswer((_) async => Right(tRules));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadFirewallRules(FirewallRuleType.nat)),
        expect: () => [
          isA<FirewallLoaded>()
              .having((s) => s.loadingType, 'loadingType', FirewallRuleType.nat),
          isA<FirewallLoaded>()
              .having((s) => s.rulesByType[FirewallRuleType.nat], 'rules', tRules),
        ],
        verify: (_) {
          verify(() => mockGetRulesUseCase(FirewallRuleType.nat)).called(1);
        },
      );
    });

    group('ToggleFirewallRule', () {
      final tRules = <FirewallRule>[
        const FirewallRule(
          id: '*1',
          type: FirewallRuleType.filter,
          disabled: false,
          dynamic: false,
          invalid: false,
          chain: 'forward',
          action: 'accept',
          allParameters: {
            'chain': 'forward',
            'action': 'accept',
            'protocol': 'tcp',
            'src-address': '192.168.1.0/24',
            'dst-port': '80',
            'comment': 'Allow HTTP',
          },
        ),
      ];

      blocTest<FirewallBloc, FirewallState>(
        'should toggle rule and reload rules',
        build: () {
          when(() => mockToggleRuleUseCase(
                type: FirewallRuleType.filter,
                id: '*1',
                enable: false,
              )).thenAnswer((_) async => const Right(true));
          when(() => mockGetRulesUseCase(FirewallRuleType.filter))
              .thenAnswer((_) async => Right(tRules));
          return bloc;
        },
        seed: () => FirewallLoaded(
          rulesByType: {FirewallRuleType.filter: tRules},
        ),
        act: (bloc) => bloc.add(const ToggleFirewallRule(
          type: FirewallRuleType.filter,
          id: '*1',
          enable: false,
        )),
        expect: () => [
          isA<FirewallLoaded>(),
          isA<FirewallOperationSuccess>()
              .having((s) => s.message, 'message', contains('Rule')),
        ],
        verify: (_) {
          verify(() => mockToggleRuleUseCase(
                type: FirewallRuleType.filter,
                id: '*1',
                enable: false,
              )).called(1);
        },
      );

      blocTest<FirewallBloc, FirewallState>(
        'should emit error when toggle fails',
        build: () {
          when(() => mockToggleRuleUseCase(
                type: FirewallRuleType.filter,
                id: '*1',
                enable: false,
              )).thenAnswer((_) async => const Left(ServerFailure('Toggle failed')));
          return bloc;
        },
        seed: () => FirewallLoaded(
          rulesByType: {FirewallRuleType.filter: tRules},
        ),
        act: (bloc) => bloc.add(const ToggleFirewallRule(
          type: FirewallRuleType.filter,
          id: '*1',
          enable: false,
        )),
        expect: () => [
          isA<FirewallLoaded>(),
          isA<FirewallError>()
              .having((s) => s.message, 'message', 'Toggle failed'),
        ],
      );
    });

    group('LoadAddressListNames', () {
      final tNames = ['whitelist', 'blacklist', 'vpn-clients'];

      blocTest<FirewallBloc, FirewallState>(
        'should load address list names successfully',
        build: () {
          when(() => mockGetAddressListNamesUseCase())
              .thenAnswer((_) async => Right(tNames));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAddressListNames()),
        expect: () => [
          isA<FirewallLoaded>()
              .having((s) => s.addressListNames, 'names', tNames),
        ],
        verify: (_) {
          verify(() => mockGetAddressListNamesUseCase()).called(1);
        },
      );

      blocTest<FirewallBloc, FirewallState>(
        'should emit error when loading names fails',
        build: () {
          when(() => mockGetAddressListNamesUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAddressListNames()),
        expect: () => [
          isA<FirewallError>()
              .having((s) => s.message, 'message', 'Load failed'),
        ],
      );
    });
  });
}
