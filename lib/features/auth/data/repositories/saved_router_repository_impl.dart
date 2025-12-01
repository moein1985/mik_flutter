import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/saved_router.dart';
import '../../domain/repositories/saved_router_repository.dart';
import '../datasources/saved_router_local_data_source.dart';
import '../models/saved_router_model.dart';

class SavedRouterRepositoryImpl implements SavedRouterRepository {
  final _log = AppLogger.tag('SavedRouterRepository');
  final SavedRouterLocalDataSource localDataSource;

  SavedRouterRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SavedRouter>>> getAllRouters() async {
    try {
      final routers = await localDataSource.getAllRouters();
      return Right(routers);
    } catch (e) {
      _log.e('Failed to get all routers: $e');
      return Left(CacheFailure('Failed to load saved routers: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouter?>> getRouterById(int id) async {
    try {
      final router = await localDataSource.getRouterById(id);
      return Right(router);
    } catch (e) {
      _log.e('Failed to get router by ID: $e');
      return Left(CacheFailure('Failed to load router: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouter?>> getDefaultRouter() async {
    try {
      final router = await localDataSource.getDefaultRouter();
      return Right(router);
    } catch (e) {
      _log.e('Failed to get default router: $e');
      return Left(CacheFailure('Failed to load default router: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouter>> saveRouter(SavedRouter router) async {
    try {
      // Check if router already exists
      final exists = await localDataSource.routerExists(
        router.host,
        router.port,
        router.username,
      );
      
      if (exists) {
        return Left(CacheFailure('Router with same host, port, and username already exists'));
      }
      
      final model = SavedRouterModel.fromEntity(router);
      final savedRouter = await localDataSource.saveRouter(model);
      return Right(savedRouter);
    } catch (e) {
      _log.e('Failed to save router: $e');
      return Left(CacheFailure('Failed to save router: $e'));
    }
  }

  @override
  Future<Either<Failure, SavedRouter>> updateRouter(SavedRouter router) async {
    try {
      final model = SavedRouterModel.fromEntity(router);
      final updatedRouter = await localDataSource.updateRouter(model);
      return Right(updatedRouter);
    } catch (e) {
      _log.e('Failed to update router: $e');
      return Left(CacheFailure('Failed to update router: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRouter(int id) async {
    try {
      final result = await localDataSource.deleteRouter(id);
      return Right(result);
    } catch (e) {
      _log.e('Failed to delete router: $e');
      return Left(CacheFailure('Failed to delete router: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultRouter(int id) async {
    try {
      await localDataSource.setDefaultRouter(id);
      return const Right(null);
    } catch (e) {
      _log.e('Failed to set default router: $e');
      return Left(CacheFailure('Failed to set default router: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastConnected(int id) async {
    try {
      await localDataSource.updateLastConnected(id);
      return const Right(null);
    } catch (e) {
      _log.e('Failed to update last connected: $e');
      return Left(CacheFailure('Failed to update last connected: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> routerExists(
    String host,
    int port,
    String username,
  ) async {
    try {
      final exists = await localDataSource.routerExists(host, port, username);
      return Right(exists);
    } catch (e) {
      _log.e('Failed to check router existence: $e');
      return Left(CacheFailure('Failed to check router: $e'));
    }
  }
}
