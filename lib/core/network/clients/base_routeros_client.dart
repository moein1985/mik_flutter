import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../errors/exceptions.dart';
import '../routeros_client.dart';

/// Base class for domain-specific RouterOS API clients
abstract class BaseRouterOSClient {
  final RouterOSClient _client;

  BaseRouterOSClient(this._client);

  /// Execute a command and return the result
  Future<Either<Failure, List<Map<String, String>>>> executeCommand(
    List<String> command, {
    Map<String, String>? params,
  }) async {
    try {
      final result = await _client.sendCommand(command);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Execute a command that doesn't return data (like set operations)
  Future<Either<Failure, void>> executeVoidCommand(
    List<String> command, {
    Map<String, String>? params,
  }) async {
    try {
      await _client.sendCommand(command);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ConnectionException catch (e) {
      return Left(ConnectionFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}