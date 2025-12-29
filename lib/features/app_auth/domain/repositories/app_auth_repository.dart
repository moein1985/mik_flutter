import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_user.dart';

abstract class AppAuthRepository {
  Future<Either<Failure, AppUser?>> getLoggedInUser();
  Future<Either<Failure, AppUser>> login(String username, String password);
  Future<Either<Failure, AppUser>> register(String username, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> authenticateWithBiometric();
  Future<Either<Failure, void>> enableBiometric(String userId);
  Future<Either<Failure, void>> disableBiometric(String userId);
  Future<Either<Failure, bool>> canAuthenticateWithBiometric();
}
