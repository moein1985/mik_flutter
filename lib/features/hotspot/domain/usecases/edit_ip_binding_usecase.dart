import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class EditIpBindingParams {
  final String id;
  final String? mac;
  final String? address;
  final String? toAddress;
  final String? server;
  final String? type;
  final String? comment;

  EditIpBindingParams({
    required this.id,
    this.mac,
    this.address,
    this.toAddress,
    this.server,
    this.type,
    this.comment,
  });
}

class EditIpBindingUseCase {
  final HotspotRepository repository;

  EditIpBindingUseCase(this.repository);

  Future<Either<Failure, bool>> call(EditIpBindingParams params) async {
    return await repository.editIpBinding(
      id: params.id,
      mac: params.mac,
      address: params.address,
      toAddress: params.toAddress,
      server: params.server,
      type: params.type,
      comment: params.comment,
    );
  }
}
