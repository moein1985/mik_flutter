import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ping_result.dart';
import '../repositories/tools_repository.dart';

/// Use case for ping operations
class PingUseCase {
  final ToolsRepository repository;

  PingUseCase(this.repository);

  /// Execute ping operation
  Future<Either<Failure, PingResult>> call({
    required String target,
    int count = 4,
    int timeout = 1000,
  }) async {
    return await repository.ping(
      target: target,
      count: count,
      timeout: timeout,
    );
  }

  /// Stop ongoing ping operation
  Future<Either<Failure, void>> stop() async {
    return await repository.stopPing();
  }

  /// Execute continuous ping operation with streaming updates
  /// Returns a stream that emits ping results as packets arrive
  /// 
  /// Parameters:
  /// - [target]: Target IP or hostname
  /// - [interval]: Interval between packets in seconds (default: 1)
  /// - [count]: Number of packets to send (default: 100 for continuous)
  /// - [size]: Packet size in bytes (default: 56)
  /// - [ttl]: Time to live (default: 64)
  /// - [srcAddress]: Source address (default: auto)
  /// - [interfaceName]: Interface to use (default: auto)
  /// - [doNotFragment]: Set DF flag (default: false)
  Stream<PingResult> callStream({
    required String target,
    int interval = 1,
    int count = 100,
    int? size,
    int? ttl,
    String? srcAddress,
    String? interfaceName,
    bool doNotFragment = false,
  }) {
    return repository.pingStream(
      target: target,
      interval: interval,
      count: count,
      size: size,
      ttl: ttl,
      srcAddress: srcAddress,
      interfaceName: interfaceName,
      doNotFragment: doNotFragment,
    );
  }
}