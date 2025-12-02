import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class EditWalledGardenParams {
  final String id;
  final String? server;
  final String? srcAddress;
  final String? dstAddress;
  final String? dstHost;
  final String? dstPort;
  final String? path;
  final String? action;
  final String? method;
  final String? comment;

  EditWalledGardenParams({
    required this.id,
    this.server,
    this.srcAddress,
    this.dstAddress,
    this.dstHost,
    this.dstPort,
    this.path,
    this.action,
    this.method,
    this.comment,
  });
}

class EditWalledGardenUseCase {
  final HotspotRepository repository;

  EditWalledGardenUseCase(this.repository);

  Future<Either<Failure, bool>> call(EditWalledGardenParams params) async {
    return await repository.editWalledGarden(
      id: params.id,
      server: params.server,
      srcAddress: params.srcAddress,
      dstAddress: params.dstAddress,
      dstHost: params.dstHost,
      dstPort: params.dstPort,
      path: params.path,
      action: params.action,
      method: params.method,
      comment: params.comment,
    );
  }
}
