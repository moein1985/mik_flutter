import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:hsmik/features/logs/presentation/bloc/logs_event.dart';
import 'package:hsmik/features/logs/presentation/bloc/logs_state.dart';
import 'package:hsmik/features/logs/domain/entities/log_entry.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/logs_mocks.dart';

void main() {
  late LogsBloc bloc;
  late MockGetLogsUseCase mockGetLogsUseCase;
  late MockFollowLogsUseCase mockFollowLogsUseCase;
  late MockClearLogsUseCase mockClearLogsUseCase;
  late MockSearchLogsUseCase mockSearchLogsUseCase;

  setUp(() {
    mockGetLogsUseCase = MockGetLogsUseCase();
    mockFollowLogsUseCase = MockFollowLogsUseCase();
    mockClearLogsUseCase = MockClearLogsUseCase();
    mockSearchLogsUseCase = MockSearchLogsUseCase();

    bloc = LogsBloc(
      getLogsUseCase: mockGetLogsUseCase,
      followLogsUseCase: mockFollowLogsUseCase,
      clearLogsUseCase: mockClearLogsUseCase,
      searchLogsUseCase: mockSearchLogsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LogsBloc', () {
    test('initial state should be LogsInitial', () {
      expect(bloc.state, const LogsInitial());
    });

    group('LoadLogs', () {
      final tLogs = [
        const LogEntry(
          time: '2024-01-01 10:00:00',
          topics: 'system,info',
          message: 'System started',
        ),
        const LogEntry(
          time: '2024-01-01 10:01:00',
          topics: 'system,warning',
          message: 'Low memory',
        ),
      ];

      blocTest<LogsBloc, LogsState>(
        'should emit [LogsLoading, LogsLoaded] when successful',
        build: () {
          when(() => mockGetLogsUseCase.call(
                count: null,
                topics: null,
                since: null,
                until: null,
              )).thenAnswer((_) async => Right(tLogs));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadLogs()),
        expect: () => [
          const LogsLoading(),
          isA<LogsLoaded>()
              .having((s) => s.logs.length, 'logs length', 2)
              .having((s) => s.isFollowing, 'isFollowing', false),
        ],
        verify: (_) {
          verify(() => mockGetLogsUseCase.call(
                count: null,
                topics: null,
                since: null,
                until: null,
              )).called(1);
        },
      );

      blocTest<LogsBloc, LogsState>(
        'should emit [LogsLoading, LogsLoaded] with filtered logs',
        build: () {
          when(() => mockGetLogsUseCase.call(
                count: null,
                topics: 'system',
                since: null,
                until: null,
              )).thenAnswer((_) async => Right(tLogs));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadLogs(topics: 'system')),
        expect: () => [
          const LogsLoading(),
          isA<LogsLoaded>()
              .having((s) => s.currentFilter, 'currentFilter', 'system'),
        ],
        verify: (_) {
          verify(() => mockGetLogsUseCase.call(
                count: null,
                topics: 'system',
                since: null,
                until: null,
              )).called(1);
        },
      );

      blocTest<LogsBloc, LogsState>(
        'should emit [LogsLoading, LogsError] when failed',
        build: () {
          when(() => mockGetLogsUseCase.call(
                count: null,
                topics: null,
                since: null,
                until: null,
              )).thenAnswer((_) async => const Left(ServerFailure('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadLogs()),
        expect: () => [
          const LogsLoading(),
          const LogsError('Load failed'),
        ],
      );
    });

    group('ClearLogs', () {
      final tLogs = [
        const LogEntry(
          time: '2024-01-01 10:00:00',
          topics: 'system,info',
          message: 'System started',
        ),
      ];

      blocTest<LogsBloc, LogsState>(
        'should clear logs and reload empty list',
        build: () {
          when(() => mockClearLogsUseCase.call())
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetLogsUseCase.call(
                count: null,
                topics: null,
              )).thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => LogsLoaded(logs: tLogs),
        act: (bloc) => bloc.add(const ClearLogs()),
        expect: () => [
          const LogsOperationSuccess('Logs cleared successfully'),
          const LogsLoading(),
          const LogsLoaded(logs: []),
        ],
        verify: (_) {
          verify(() => mockClearLogsUseCase.call()).called(1);
          verify(() => mockGetLogsUseCase.call(
                count: null,
                topics: null,
              )).called(1);
        },
      );

      blocTest<LogsBloc, LogsState>(
        'should emit error when clearing fails',
        build: () {
          when(() => mockClearLogsUseCase.call())
              .thenAnswer((_) async => const Left(ServerFailure('Clear failed')));
          return bloc;
        },
        seed: () => LogsLoaded(logs: tLogs),
        act: (bloc) => bloc.add(const ClearLogs()),
        expect: () => [
          const LogsError('Clear failed'),
        ],
      );
    });

    group('SearchLogs', () {
      final tSearchResults = [
        const LogEntry(
          time: '2024-01-01 10:00:00',
          topics: 'system,error',
          message: 'Critical error occurred',
        ),
      ];

      blocTest<LogsBloc, LogsState>(
        'should search logs successfully',
        build: () {
          when(() => mockSearchLogsUseCase.call(
                query: 'error',
                count: null,
                topics: null,
              )).thenAnswer((_) async => Right(tSearchResults));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchLogs(query: 'error')),
        expect: () => [
          const LogsLoading(),
          isA<LogsLoaded>()
              .having((s) => s.logs.length, 'logs length', 1)
              .having((s) => s.logs.first.message, 'message', contains('error')),
        ],
        verify: (_) {
          verify(() => mockSearchLogsUseCase.call(
                query: 'error',
                count: null,
                topics: null,
              )).called(1);
        },
      );

      blocTest<LogsBloc, LogsState>(
        'should emit error when search fails',
        build: () {
          when(() => mockSearchLogsUseCase.call(
                query: 'test',
                count: null,
                topics: null,
              )).thenAnswer((_) async => const Left(ServerFailure('Search failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchLogs(query: 'test')),
        expect: () => [
          const LogsLoading(),
          const LogsError('Search failed'),
        ],
      );
    });
  });
}
