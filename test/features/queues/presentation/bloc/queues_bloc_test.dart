import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_bloc.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_event.dart';
import 'package:hsmik/features/queues/presentation/bloc/queues_state.dart';
import 'package:hsmik/features/queues/domain/entities/simple_queue.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/queues_mocks.dart';

void main() {
  late QueuesBloc bloc;
  late MockGetQueuesUseCase mockGetQueuesUseCase;
  late MockGetQueueByIdUseCase mockGetQueueByIdUseCase;
  late MockAddQueueUseCase mockAddQueueUseCase;
  late MockEditQueueUseCase mockEditQueueUseCase;
  late MockDeleteQueueUseCase mockDeleteQueueUseCase;
  late MockToggleQueueUseCase mockToggleQueueUseCase;

  setUp(() {
    mockGetQueuesUseCase = MockGetQueuesUseCase();
    mockGetQueueByIdUseCase = MockGetQueueByIdUseCase();
    mockAddQueueUseCase = MockAddQueueUseCase();
    mockEditQueueUseCase = MockEditQueueUseCase();
    mockDeleteQueueUseCase = MockDeleteQueueUseCase();
    mockToggleQueueUseCase = MockToggleQueueUseCase();

    bloc = QueuesBloc(
      getQueuesUseCase: mockGetQueuesUseCase,
      getQueueByIdUseCase: mockGetQueueByIdUseCase,
      addQueueUseCase: mockAddQueueUseCase,
      editQueueUseCase: mockEditQueueUseCase,
      deleteQueueUseCase: mockDeleteQueueUseCase,
      toggleQueueUseCase: mockToggleQueueUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('QueuesBloc', () {
    test('initial state should be QueuesInitial', () {
      expect(bloc.state, const QueuesInitial());
    });

    group('LoadQueues', () {
      final tQueues = [
        const SimpleQueue(
          id: '*1',
          name: 'default',
          target: '192.168.88.0/24',
          maxLimit: '10M/10M',
          burstLimit: '15M/15M',
          disabled: false,
        ),
        const SimpleQueue(
          id: '*2',
          name: 'guest',
          target: '192.168.89.0/24',
          maxLimit: '5M/5M',
          burstLimit: '7M/7M',
          disabled: false,
        ),
      ];

      blocTest<QueuesBloc, QueuesState>(
        'should emit [QueuesLoading, QueuesLoaded] when successful',
        build: () {
          when(() => mockGetQueuesUseCase.call())
              .thenAnswer((_) async => Right(tQueues));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadQueues()),
        expect: () => [
          const QueuesLoading(),
          QueuesLoaded(tQueues),
        ],
        verify: (_) {
          verify(() => mockGetQueuesUseCase.call()).called(1);
        },
      );

      blocTest<QueuesBloc, QueuesState>(
        'should emit [QueuesLoading, QueuesError] when failed',
        build: () {
          when(() => mockGetQueuesUseCase.call())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadQueues()),
        expect: () => [
          const QueuesLoading(),
          const QueuesError('Server error'),
        ],
      );
    });

    group('DeleteQueue', () {
      final tQueues = [
        const SimpleQueue(
          id: '*1',
          name: 'default',
          target: '192.168.88.0/24',
          maxLimit: '10M/10M',
          disabled: false,
        ),
      ];

      blocTest<QueuesBloc, QueuesState>(
        'should emit success state and reload queues when deletion successful',
        build: () {
          when(() => mockDeleteQueueUseCase.call('*1'))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetQueuesUseCase.call())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => QueuesLoaded(tQueues),
        act: (bloc) => bloc.add(const DeleteQueue('*1')),
        expect: () => [
          const QueueOperationInProgress(),
          const QueueOperationSuccess('Queue deleted successfully'),
          const QueuesLoading(),
          const QueuesLoaded([]),
        ],
        verify: (_) {
          verify(() => mockDeleteQueueUseCase.call('*1')).called(1);
          verify(() => mockGetQueuesUseCase.call()).called(1);
        },
      );

      blocTest<QueuesBloc, QueuesState>(
        'should emit error when deletion fails',
        build: () {
          when(() => mockDeleteQueueUseCase.call('*1'))
              .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
          return bloc;
        },
        seed: () => QueuesLoaded(tQueues),
        act: (bloc) => bloc.add(const DeleteQueue('*1')),
        expect: () => [
          const QueueOperationInProgress(),
          const QueuesError('Delete failed'),
        ],
      );
    });

    group('ToggleQueue', () {
      final tQueues = [
        const SimpleQueue(
          id: '*1',
          name: 'default',
          target: '192.168.88.0/24',
          maxLimit: '10M/10M',
          disabled: false,
        ),
      ];

      final tUpdatedQueues = [
        const SimpleQueue(
          id: '*1',
          name: 'default',
          target: '192.168.88.0/24',
          maxLimit: '10M/10M',
          disabled: true,
        ),
      ];

      blocTest<QueuesBloc, QueuesState>(
        'should toggle queue and reload when successful',
        build: () {
          when(() => mockToggleQueueUseCase.call('*1', false))
              .thenAnswer((_) async => const Right(null));
          when(() => mockGetQueuesUseCase.call())
              .thenAnswer((_) async => Right(tUpdatedQueues));
          return bloc;
        },
        seed: () => QueuesLoaded(tQueues),
        act: (bloc) => bloc.add(const ToggleQueue('*1', false)),
        expect: () => [
          const QueueOperationInProgress(),
          const QueueOperationSuccess('Queue disabled successfully'),
          const QueuesLoading(),
          QueuesLoaded(tUpdatedQueues),
        ],
        verify: (_) {
          verify(() => mockToggleQueueUseCase.call('*1', false)).called(1);
          verify(() => mockGetQueuesUseCase.call()).called(1);
        },
      );
    });
  });
}
