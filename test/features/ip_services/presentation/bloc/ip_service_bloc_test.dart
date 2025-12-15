import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_bloc.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_event.dart';
import 'package:hsmik/features/ip_services/presentation/bloc/ip_service_state.dart';
import 'package:hsmik/features/ip_services/domain/entities/ip_service.dart';
import 'package:hsmik/features/certificates/domain/entities/certificate.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/ip_services_mocks.dart';

void main() {
  late IpServiceBloc bloc;
  late MockIpServiceRepository mockRepository;

  setUp(() {
    mockRepository = MockIpServiceRepository();
    bloc = IpServiceBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('IpServiceBloc', () {
    test('initial state should be IpServiceInitial', () {
      expect(bloc.state, const IpServiceInitial());
    });

    group('LoadIpServices', () {
      final tServices = [
        const IpService(
          id: '*1',
          name: 'www',
          port: 80,
          disabled: false,
        ),
        const IpService(
          id: '*2',
          name: 'api',
          port: 8728,
          disabled: false,
        ),
      ];

      final tCertificates = [
        const Certificate(
          id: '*1',
          name: 'test-cert',
          commonName: 'test.local',
          keySize: 2048,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
        ),
      ];

      blocTest<IpServiceBloc, IpServiceState>(
        'should emit [IpServiceLoading, IpServiceLoaded] with services and certificates',
        build: () {
          when(() => mockRepository.getServices())
              .thenAnswer((_) async => Right(tServices));
          when(() => mockRepository.getAvailableCertificates())
              .thenAnswer((_) async => Right(tCertificates));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadIpServices()),
        expect: () => [
          const IpServiceLoading(),
          IpServiceLoaded(tServices, availableCertificates: tCertificates),
        ],
        verify: (_) {
          verify(() => mockRepository.getServices()).called(1);
          verify(() => mockRepository.getAvailableCertificates()).called(1);
        },
      );

      blocTest<IpServiceBloc, IpServiceState>(
        'should emit [IpServiceLoading, IpServiceError] when failed',
        build: () {
          when(() => mockRepository.getServices())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          when(() => mockRepository.getAvailableCertificates())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadIpServices()),
        expect: () => [
          const IpServiceLoading(),
          const IpServiceError('Server error'),
        ],
      );
    });

    group('ToggleServiceEnabled', () {
      final tServices = [
        const IpService(
          id: '*1',
          name: 'www',
          port: 80,
          disabled: false,
        ),
      ];

      final tUpdatedServices = [
        const IpService(
          id: '*1',
          name: 'www',
          port: 80,
          disabled: true,
        ),
      ];

      blocTest<IpServiceBloc, IpServiceState>(
        'should toggle service and reload when successful',
        build: () {
          when(() => mockRepository.setServiceEnabled('*1', false))
              .thenAnswer((_) async => const Right(null));
          when(() => mockRepository.getServices())
              .thenAnswer((_) async => Right(tUpdatedServices));
          when(() => mockRepository.getAvailableCertificates())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => IpServiceLoaded(tServices),
        act: (bloc) => bloc.add(const ToggleServiceEnabled(serviceId: '*1', enabled: false)),
        expect: () => [
          IpServiceOperationSuccess(
            'Service disabled successfully',
            tUpdatedServices,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.setServiceEnabled('*1', false)).called(1);
          verify(() => mockRepository.getServices()).called(1);
        },
      );

      blocTest<IpServiceBloc, IpServiceState>(
        'should emit error when toggle fails',
        build: () {
          when(() => mockRepository.setServiceEnabled('*1', false))
              .thenAnswer((_) async => const Left(ServerFailure('Toggle failed')));
          return bloc;
        },
        seed: () => IpServiceLoaded(tServices),
        act: (bloc) => bloc.add(const ToggleServiceEnabled(serviceId: '*1', enabled: false)),
        expect: () => [
          const IpServiceError('Toggle failed'),
        ],
      );
    });
  });
}
