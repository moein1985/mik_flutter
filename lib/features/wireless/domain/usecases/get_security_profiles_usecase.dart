import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/security_profile.dart';
import '../repositories/wireless_repository.dart';

/// Use case for getting all security profiles
class GetSecurityProfilesUseCase {
  final WirelessRepository repository;

  GetSecurityProfilesUseCase(this.repository);

  /// Execute get security profiles operation
  Future<Either<Failure, List<SecurityProfile>>> call() async {
    return await repository.getSecurityProfiles();
  }
}

/// Use case for creating a security profile
class CreateSecurityProfileUseCase {
  final WirelessRepository repository;

  CreateSecurityProfileUseCase(this.repository);

  /// Execute create security profile operation
  Future<Either<Failure, void>> call(SecurityProfile profile) async {
    return await repository.createSecurityProfile(profile);
  }
}

/// Use case for updating a security profile
class UpdateSecurityProfileUseCase {
  final WirelessRepository repository;

  UpdateSecurityProfileUseCase(this.repository);

  /// Execute update security profile operation
  Future<Either<Failure, void>> call(SecurityProfile profile) async {
    return await repository.updateSecurityProfile(profile);
  }
}

/// Use case for deleting a security profile
class DeleteSecurityProfileUseCase {
  final WirelessRepository repository;

  DeleteSecurityProfileUseCase(this.repository);

  /// Execute delete security profile operation
  Future<Either<Failure, void>> call(String profileId) async {
    return await repository.deleteSecurityProfile(profileId);
  }
}