import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/certificates/presentation/bloc/certificate_bloc.dart';
import 'package:hsmik/features/certificates/presentation/bloc/certificate_event.dart';
import 'package:hsmik/features/certificates/presentation/bloc/certificate_state.dart';
import 'package:hsmik/features/certificates/domain/entities/certificate.dart';
import 'package:hsmik/core/errors/failures.dart';
import 'package:hsmik/mocks/mock_classes.dart';

void main() {
  late CertificateBloc bloc;
  late MockCertificateRepository mockRepository;

  setUp(() {
    mockRepository = MockCertificateRepository();
    bloc = CertificateBloc(repository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const LoadCertificates());
    registerFallbackValue(const RefreshCertificates());
    registerFallbackValue(const CreateSelfSignedCertificate(
      name: 'test',
      commonName: 'test.local',
    ));
    registerFallbackValue(const DeleteCertificate('test-id'));
  });

  tearDown(() {
    bloc.close();
  });

  group('CertificateBloc', () {
    test('initial state should be CertificateInitial', () {
      expect(bloc.state, const CertificateInitial());
    });

    group('LoadCertificates', () {
      final tCertificates = [
        Certificate(
          id: '1',
          name: 'test-cert',
          commonName: 'test.local',
          keySize: 2048,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
          issuer: 'local-ca',
        ),
      ];

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateLoading, CertificateLoaded] when successful',
        build: () {
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Right(tCertificates));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCertificates()),
        expect: () => [
          const CertificateLoading(),
          CertificateLoaded(tCertificates),
        ],
        verify: (_) {
          verify(() => mockRepository.getCertificates()).called(1);
        },
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateLoading, CertificateError] when failed',
        build: () {
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadCertificates()),
        expect: () => [
          const CertificateLoading(),
          const CertificateError('Server error'),
        ],
      );
    });

    group('RefreshCertificates', () {
      final tCertificates = [
        Certificate(
          id: '1',
          name: 'test-cert',
          commonName: 'test.local',
          keySize: 2048,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
          issuer: 'local-ca',
        ),
      ];

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateLoaded] when successful',
        build: () {
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Right(tCertificates));
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshCertificates()),
        expect: () => [
          CertificateLoaded(tCertificates),
        ],
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateError] when failed',
        build: () {
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshCertificates()),
        expect: () => [
          const CertificateError('Server error'),
        ],
      );
    });

    group('CreateSelfSignedCertificate', () {
      const tName = 'test-cert';
      const tCommonName = 'test.local';
      const tKeySize = 2048;
      const tDaysValid = 365;

      final tCertificates = [
        Certificate(
          id: '1',
          name: tName,
          commonName: tCommonName,
          keySize: tKeySize,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
          issuer: 'local-ca',
        ),
      ];

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateCreating, CertificateOperationSuccess] when successful',
        build: () {
          when(() => mockRepository.createSelfSignedCertificate(
            name: tName,
            commonName: tCommonName,
            keySize: tKeySize,
            daysValid: tDaysValid,
          )).thenAnswer((_) async => const Right(null));
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Right(tCertificates));
          return bloc;
        },
        act: (bloc) => bloc.add(const CreateSelfSignedCertificate(
          name: tName,
          commonName: tCommonName,
          keySize: tKeySize,
          daysValid: tDaysValid,
        )),
        expect: () => [
          const CertificateCreating('Creating and signing certificate...'),
          CertificateOperationSuccess('Certificate "$tName" created successfully', tCertificates),
        ],
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateCreating, CertificateError] when creation fails',
        build: () {
          when(() => mockRepository.createSelfSignedCertificate(
            name: any(named: 'name'),
            commonName: any(named: 'commonName'),
            keySize: any(named: 'keySize'),
            daysValid: any(named: 'daysValid'),
          )).thenAnswer((_) async => Left(ServerFailure('Creation failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const CreateSelfSignedCertificate(
          name: tName,
          commonName: tCommonName,
        )),
        expect: () => [
          const CertificateCreating('Creating and signing certificate...'),
          const CertificateError('Creation failed'),
        ],
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateCreating, CertificateError] when reload fails',
        build: () {
          when(() => mockRepository.createSelfSignedCertificate(
            name: any(named: 'name'),
            commonName: any(named: 'commonName'),
            keySize: any(named: 'keySize'),
            daysValid: any(named: 'daysValid'),
          )).thenAnswer((_) async => const Right(null));
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Left(ServerFailure('Reload failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const CreateSelfSignedCertificate(
          name: tName,
          commonName: tCommonName,
        )),
        expect: () => [
          const CertificateCreating('Creating and signing certificate...'),
          const CertificateError('Reload failed'),
        ],
      );
    });

    group('DeleteCertificate', () {
      const tId = '*1';
      final tCertificates = [
        Certificate(
          id: '2',
          name: 'remaining-cert',
          commonName: 'remaining.local',
          keySize: 2048,
          privateKey: true,
          trusted: false,
          ca: false,
          expired: false,
          revoked: false,
        ),
      ];

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateOperationSuccess] when successful',
        build: () {
          when(() => mockRepository.deleteCertificate(tId))
              .thenAnswer((_) async => const Right(null));
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Right(tCertificates));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCertificate(tId)),
        expect: () => [
          CertificateOperationSuccess('Certificate deleted successfully', tCertificates),
        ],
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateError] when deletion fails',
        build: () {
          when(() => mockRepository.deleteCertificate(any()))
              .thenAnswer((_) async => Left(ServerFailure('Deletion failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCertificate(tId)),
        expect: () => [
          const CertificateError('Deletion failed'),
        ],
      );

      blocTest<CertificateBloc, CertificateState>(
        'should emit [CertificateError] when reload fails',
        build: () {
          when(() => mockRepository.deleteCertificate(any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockRepository.getCertificates())
              .thenAnswer((_) async => Left(ServerFailure('Reload failed')));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCertificate(tId)),
        expect: () => [
          const CertificateError('Reload failed'),
        ],
      );
    });
  });
}