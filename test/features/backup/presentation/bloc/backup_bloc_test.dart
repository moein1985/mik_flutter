import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:hsmik/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:hsmik/features/backup/presentation/bloc/backup_event.dart';
import 'package:hsmik/features/backup/presentation/bloc/backup_state.dart';
import 'package:hsmik/features/backup/domain/entities/backup_file.dart';
import 'package:hsmik/core/errors/failures.dart';
import '../../../../mocks/backup_mocks.dart';

void main() {
  late BackupBloc bloc;
  late MockGetBackupsUseCase mockGetBackupsUseCase;
  late MockCreateBackupUseCase mockCreateBackupUseCase;
  late MockDeleteBackupUseCase mockDeleteBackupUseCase;
  late MockRestoreBackupUseCase mockRestoreBackupUseCase;
  late MockExportConfigUseCase mockExportConfigUseCase;

  setUp(() {
    mockGetBackupsUseCase = MockGetBackupsUseCase();
    mockCreateBackupUseCase = MockCreateBackupUseCase();
    mockDeleteBackupUseCase = MockDeleteBackupUseCase();
    mockRestoreBackupUseCase = MockRestoreBackupUseCase();
    mockExportConfigUseCase = MockExportConfigUseCase();

    bloc = BackupBloc(
      getBackupsUseCase: mockGetBackupsUseCase,
      createBackupUseCase: mockCreateBackupUseCase,
      deleteBackupUseCase: mockDeleteBackupUseCase,
      restoreBackupUseCase: mockRestoreBackupUseCase,
      exportConfigUseCase: mockExportConfigUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('BackupBloc', () {
    test('initial state should be BackupInitial', () {
      expect(bloc.state, const BackupInitial());
    });

    group('LoadBackupsEvent', () {
      final tBackups = [
        BackupFile(
          name: 'backup-2024-01-01',
          size: '1024KB',
          created: DateTime.now(),
          type: 'backup',
        ),
      ];

      blocTest<BackupBloc, BackupState>(
        'should emit [BackupLoading, BackupLoaded] when successful',
        build: () {
          when(() => mockGetBackupsUseCase())
              .thenAnswer((_) async => Right(tBackups));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadBackupsEvent()),
        expect: () => [
          const BackupLoading(),
          BackupLoaded(tBackups),
        ],
        verify: (_) {
          verify(() => mockGetBackupsUseCase()).called(1);
        },
      );

      blocTest<BackupBloc, BackupState>(
        'should emit [BackupLoading, BackupError] when failed',
        build: () {
          when(() => mockGetBackupsUseCase())
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadBackupsEvent()),
        expect: () => [
          const BackupLoading(),
          const BackupError('Server error'),
        ],
      );
    });

    group('DeleteBackupEvent', () {
      final tBackups = [
        BackupFile(
          name: 'backup-2024-01-01',
          size: '1024KB',
          created: DateTime.now(),
          type: 'backup',
        ),
      ];

      blocTest<BackupBloc, BackupState>(
        'should delete backup and reload list when successful',
        build: () {
          when(() => mockDeleteBackupUseCase('backup-2024-01-01'))
              .thenAnswer((_) async => const Right(true));
          when(() => mockGetBackupsUseCase())
              .thenAnswer((_) async => const Right([]));
          return bloc;
        },
        seed: () => BackupLoaded(tBackups),
        act: (bloc) => bloc.add(const DeleteBackupEvent('backup-2024-01-01')),
        expect: () => [
          const BackupLoading(),
          const BackupOperationSuccess('Backup deleted successfully'),
          const BackupLoading(),
          const BackupLoaded([]),
        ],
        verify: (_) {
          verify(() => mockDeleteBackupUseCase('backup-2024-01-01')).called(1);
          verify(() => mockGetBackupsUseCase()).called(1);
        },
      );

      blocTest<BackupBloc, BackupState>(
        'should emit error when deletion fails',
        build: () {
          when(() => mockDeleteBackupUseCase('backup-2024-01-01'))
              .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
          return bloc;
        },
        seed: () => BackupLoaded(tBackups),
        act: (bloc) => bloc.add(const DeleteBackupEvent('backup-2024-01-01')),
        expect: () => [
          const BackupLoading(),
          const BackupError('Delete failed'),
        ],
      );
    });
  });
}
