import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/hotspot_repository.dart';

class AddWalledGardenParams {
  final String? server;
  final String? srcAddress;
  final String? dstAddress;
  final String? dstHost;
  final String? dstPort;
  final String? path;
  final String action;
  final String? method;
  final String? comment;

  AddWalledGardenParams({
    this.server,
    this.srcAddress,
    this.dstAddress,
    this.dstHost,
    this.dstPort,
    this.path,
    this.action = 'allow',
    this.method,
    this.comment,
  });
}

class AddWalledGardenUseCase {
  final HotspotRepository repository;

  AddWalledGardenUseCase(this.repository);

  Future<Either<Failure, bool>> call(AddWalledGardenParams params) async {
    return await repository.addWalledGarden(
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
