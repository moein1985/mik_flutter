import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/acme_provider.dart';
import '../../domain/entities/letsencrypt_status.dart';
import '../../domain/entities/precheck_result.dart';
import '../../domain/repositories/letsencrypt_repository.dart';
import '../datasources/letsencrypt_remote_data_source.dart';

class LetsEncryptRepositoryImpl implements LetsEncryptRepository {
  final LetsEncryptRemoteDataSource remoteDataSource;

  LetsEncryptRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, LetsEncryptStatus>> getStatus() async {
    try {
      final status = await remoteDataSource.getStatus();
      return Right(status);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PreCheckResult>> runPreChecks() async {
    try {
      final result = await remoteDataSource.runPreChecks();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> autoFix(PreCheckType checkType) async {
    try {
      final result = await remoteDataSource.autoFix(checkType);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestCertificate({
    required String dnsName,
    AcmeProvider provider = AcmeProvider.letsEncrypt,
  }) async {
    try {
      final result = await remoteDataSource.requestCertificate(
        dnsName: dnsName,
        provider: provider,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> addTemporaryFirewallRule() async {
    try {
      final ruleId = await remoteDataSource.addTemporaryFirewallRule();
      return Right(ruleId);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeTemporaryFirewallRule(String ruleId) async {
    try {
      final result = await remoteDataSource.removeTemporaryFirewallRule(ruleId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkPort80Accessible() async {
    try {
      final result = await remoteDataSource.checkPort80Accessible();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> revokeCertificate(String certificateName) async {
    try {
      final result = await remoteDataSource.revokeCertificate(certificateName);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
