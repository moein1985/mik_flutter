import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/dashboard_repository.dart';

class AddIpAddressUseCase {
  final DashboardRepository repository;

  AddIpAddressUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String address,
    required String interfaceName,
    String? comment,
  }) async {
    return await repository.addIpAddress(
      address: address,
      interfaceName: interfaceName,
      comment: comment,
    );
  }
}

class UpdateIpAddressUseCase {
  final DashboardRepository repository;

  UpdateIpAddressUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String id,
    String? address,
    String? interfaceName,
    String? comment,
  }) async {
    return await repository.updateIpAddress(
      id: id,
      address: address,
      interfaceName: interfaceName,
      comment: comment,
    );
  }
}

class RemoveIpAddressUseCase {
  final DashboardRepository repository;

  RemoveIpAddressUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id) async {
    return await repository.removeIpAddress(id);
  }
}

class ToggleIpAddressUseCase {
  final DashboardRepository repository;

  ToggleIpAddressUseCase(this.repository);

  Future<Either<Failure, bool>> call(String id, bool enable) async {
    return await repository.toggleIpAddress(id, enable);
  }
}
