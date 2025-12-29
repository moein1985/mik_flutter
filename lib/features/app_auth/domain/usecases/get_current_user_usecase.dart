import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../entities/app_user.dart';
import '../repositories/app_auth_repository.dart';

class GetCurrentUserUseCase {
  final AppAuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, AppUser?>> call() async {
    final _log = AppLogger.tag('GetCurrentUserUseCase');
    _log.i('GetCurrentUserUseCase: START');
    final result = await repository.getLoggedInUser();
    result.fold(
      (failure) => _log.i('GetCurrentUserUseCase: failure ${failure.message}'),
      (user) => _log.i('GetCurrentUserUseCase: returned user=${user != null}'),
    );
    return result;
  }
}
