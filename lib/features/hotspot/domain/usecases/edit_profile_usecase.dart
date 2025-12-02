import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class EditProfileParams {
  final String id;
  final String? name;
  final String? sessionTimeout;
  final String? idleTimeout;
  final String? sharedUsers;
  final String? rateLimit;
  final String? keepaliveTimeout;
  final String? statusAutorefresh;
  final String? onLogin;
  final String? onLogout;

  EditProfileParams({
    required this.id,
    this.name,
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

class EditProfileUseCase {
  final HotspotRepository repository;

  EditProfileUseCase(this.repository);

  Future<Either<Failure, bool>> call(EditProfileParams params) async {
    return await repository.editProfile(
      id: params.id,
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
