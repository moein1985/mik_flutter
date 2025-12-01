import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/saved_router.dart';

/// Repository interface for saved routers
abstract class SavedRouterRepository {
  /// Get all saved routers
  Future<Either<Failure, List<SavedRouter>>> getAllRouters();

  /// Get router by ID
  Future<Either<Failure, SavedRouter?>> getRouterById(int id);

  /// Get default router
  Future<Either<Failure, SavedRouter?>> getDefaultRouter();

  /// Save a new router
  Future<Either<Failure, SavedRouter>> saveRouter(SavedRouter router);

  /// Update an existing router
  Future<Either<Failure, SavedRouter>> updateRouter(SavedRouter router);

  /// Delete a router by ID
  Future<Either<Failure, bool>> deleteRouter(int id);

  /// Set a router as default
  Future<Either<Failure, void>> setDefaultRouter(int id);

  /// Update last connected time
  Future<Either<Failure, void>> updateLastConnected(int id);

  /// Check if router with same host/port/username exists
  Future<Either<Failure, bool>> routerExists(String host, int port, String username);
}
