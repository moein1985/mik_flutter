import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class AddIpBindingParams {
  final String? mac;
  final String? address;
  final String? toAddress;
  final String? server;
  final String type;
  final String? comment;

  AddIpBindingParams({
    this.mac,
    this.address,
    this.toAddress,
    this.server,
    this.type = 'regular',
    this.comment,
  });
}

class AddIpBindingUseCase {
  final HotspotRepository repository;

  AddIpBindingUseCase(this.repository);

  Future<Either<Failure, bool>> call(AddIpBindingParams params) async {
    return await repository.addIpBinding(
      mac: params.mac,
      address: params.address,
      toAddress: params.toAddress,
      server: params.server,
      type: params.type,
      comment: params.comment,
    );
  }
}
