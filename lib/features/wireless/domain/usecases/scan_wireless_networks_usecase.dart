import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/wireless_scan_result.dart';
import '../repositories/wireless_repository.dart';

class ScanWirelessNetworksUseCase {
  final WirelessRepository repository;

  ScanWirelessNetworksUseCase(this.repository);

  Future<Either<Failure, List<WirelessScanResult>>> call({
    required String interfaceId,
    int? duration,
  }) async {
    return await repository.scanWirelessNetworks(
      interfaceId: interfaceId,
      duration: duration,
    );
  }
}
