import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class AddProfileParams {
  final String name;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? sharedUsers;
  final String? rateLimit;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final String? onLogin;
  final String? onLogout;

  AddProfileParams({
    required this.name,
    this.sessionTimeout,
    this.idleTimeout,
    this.sharedUsers,
    this.rateLimit,
    this.keepaliveTimeout,
    this.statusAutorefresh,
    this.onLogin,
    this.onLogout,
  });
}

class AddProfileUseCase {
  final HotspotRepository repository;

  AddProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(AddProfileParams params) async {
    return await repository.addProfile(
      name: params.name,
      sessionTimeout: params.sessionTimeout,
      idleTimeout: params.idleTimeout,
      sharedUsers: params.sharedUsers,
      rateLimit: params.rateLimit,
      keepaliveTimeout: params.keepaliveTimeout,
      statusAutorefresh: params.statusAutorefresh,
      onLogin: params.onLogin,
      onLogout: params.onLogout,
    );
  }
}
