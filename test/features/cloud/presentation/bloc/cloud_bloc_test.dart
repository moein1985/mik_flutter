import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/cloud/presentation/bloc/cloud_bloc.dart';
import 'package:hsmik/features/cloud/presentation/bloc/cloud_event.dart';
import 'package:hsmik/features/cloud/presentation/bloc/cloud_state.dart';
import 'package:hsmik/features/cloud/domain/entities/cloud_status.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/cloud_mocks.dart';

void main() {
  late CloudBloc bloc;
  late MockCloudRepository mockRepository;

  setUp(() {
    mockRepository = MockCloudRepository();
    bloc = CloudBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('CloudBloc', () {
    test('initial state should be CloudInitial', () {
      expect(bloc.state, const CloudInitial());
    });

    group('LoadCloudStatus', () {
      final tCloudStatus = const CloudStatus(
        isSupported: true,
        ddnsEnabled: true,
        ddnsUpdateInterval: '1d',
        publicAddress: '203.0.113.1',
        status: 'updated',
        updateTime: true,
      );

      blocTest<CloudBloc, CloudState>(
        'should emit [CloudLoading, CloudLoaded] when successful',
        build: () {
          when(() => mockRepository.getCloudStatus())
              .thenAnswer((_) async => Right(tCloudStatus));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCloudStatus()),
        expect: () => [
          const CloudLoading(),
          CloudLoaded(tCloudStatus),
        ],
        verify: (_) {
          verify(() => mockRepository.getCloudStatus()).called(1);
        },
      );

      blocTest<CloudBloc, CloudState>(
        'should emit [CloudLoading, CloudError] when failed',
        build: () {
          when(() => mockRepository.getCloudStatus())
              .thenAnswer((_) async => const Left(ServerFailure('Load failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCloudStatus()),
        expect: () => [
          const CloudLoading(),
          const CloudError('Load failed'),
        ],
      );
    });

    group('EnableCloudDdns', () {
      final tCloudStatus = const CloudStatus(
        isSupported: true,
        ddnsEnabled: true,
        ddnsUpdateInterval: '1d',
        publicAddress: '203.0.113.1',
        status: 'updated',
        updateTime: true,
      );

      blocTest<CloudBloc, CloudState>(
        'should enable DDNS and reload status',
        build: () {
          when(() => mockRepository.enableDdns())
              .thenAnswer((_) async => const Right(true));
          when(() => mockRepository.getCloudStatus())
              .thenAnswer((_) async => Right(tCloudStatus));
          return bloc;
        },
        act: (bloc) => bloc.add(const EnableCloudDdns()),
        expect: () => [
          isA<CloudOperationInProgress>()
              .having((s) => s.operation, 'operation', 'Enabling DDNS...'),
          isA<CloudOperationSuccess>()
              .having((s) => s.message, 'message', 'DDNS enabled successfully'),
          const CloudLoading(),
          CloudLoaded(tCloudStatus),
        ],
        verify: (_) {
          verify(() => mockRepository.enableDdns()).called(1);
          verify(() => mockRepository.getCloudStatus()).called(1);
        },
      );

      blocTest<CloudBloc, CloudState>(
        'should emit error when enabling fails',
        build: () {
          when(() => mockRepository.enableDdns())
              .thenAnswer((_) async => const Left(ServerFailure('Enable failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const EnableCloudDdns()),
        expect: () => [
          isA<CloudOperationInProgress>(),
          const CloudError('Enable failed'),
        ],
      );
    });

    group('DisableCloudDdns', () {
      final tCloudStatus = const CloudStatus(
        isSupported: true,
        ddnsEnabled: false,
        ddnsUpdateInterval: '1d',
        publicAddress: '203.0.113.1',
        status: 'updated',
        updateTime: true,
      );

      blocTest<CloudBloc, CloudState>(
        'should disable DDNS and reload status',
        build: () {
          when(() => mockRepository.disableDdns())
              .thenAnswer((_) async => const Right(true));
          when(() => mockRepository.getCloudStatus())
              .thenAnswer((_) async => Right(tCloudStatus));
          return bloc;
        },
        seed: () => const CloudLoaded(
          CloudStatus(
            isSupported: true,
            ddnsEnabled: true,
            ddnsUpdateInterval: '1d',
            publicAddress: '203.0.113.1',
            status: 'updated',
            updateTime: true,
          ),
        ),
        act: (bloc) => bloc.add(const DisableCloudDdns()),
        expect: () => [
          isA<CloudOperationInProgress>()
              .having((s) => s.operation, 'operation', 'Disabling DDNS...'),
          isA<CloudOperationSuccess>()
              .having((s) => s.message, 'message', 'DDNS disabled successfully'),
          const CloudLoading(),
          CloudLoaded(tCloudStatus),
        ],
        verify: (_) {
          verify(() => mockRepository.disableDdns()).called(1);
          verify(() => mockRepository.getCloudStatus()).called(1);
        },
      );
    });




  });
}
