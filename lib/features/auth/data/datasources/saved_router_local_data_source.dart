import '../models/saved_router_model.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/logger.dart';

/// Data source for saved routers using SQLite database
abstract class SavedRouterLocalDataSource {
  /// Get all saved routers
  Future<List<SavedRouterModel>> getAllRouters();

  /// Get router by ID
  Future<SavedRouterModel?> getRouterById(int id);

  /// Get default router
  Future<SavedRouterModel?> getDefaultRouter();

  /// Save a new router
  Future<SavedRouterModel> saveRouter(SavedRouterModel router);

  /// Update an existing router
  Future<SavedRouterModel> updateRouter(SavedRouterModel router);

  /// Delete a router by ID
  Future<bool> deleteRouter(int id);

  /// Set a router as default
  Future<void> setDefaultRouter(int id);

  /// Update last connected time
  Future<void> updateLastConnected(int id);

  /// Check if router with same host/port/username exists
  Future<bool> routerExists(String host, int port, String username);
}

class SavedRouterLocalDataSourceImpl implements SavedRouterLocalDataSource {
  final _log = AppLogger.tag('SavedRouterDataSource');
  static const String _tableName = 'saved_routers';

  @override
  Future<List<SavedRouterModel>> getAllRouters() async {
    _log.d('Getting all saved routers...');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      orderBy: 'is_default DESC, last_connected DESC, name ASC',
    );
    
    final routers = results.map((map) => SavedRouterModel.fromMap(map)).toList();
    _log.i('Found ${routers.length} saved routers');
    return routers;
  }

  @override
  Future<SavedRouterModel?> getRouterById(int id) async {
    _log.d('Getting router by ID: $id');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (results.isEmpty) {
      _log.d('Router not found: $id');
      return null;
    }
    
    return SavedRouterModel.fromMap(results.first);
  }

  @override
  Future<SavedRouterModel?> getDefaultRouter() async {
    _log.d('Getting default router...');
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      _tableName,
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    
    if (results.isEmpty) {
      _log.d('No default router set');
      return null;
    }
    
    final router = SavedRouterModel.fromMap(results.first);
    _log.i('Default router: ${router.name}');
    return router;
  }

  @override
  Future<SavedRouterModel> saveRouter(SavedRouterModel router) async {
    _log.i('Saving new router: ${router.name}');
    final db = await DatabaseHelper.instance.database;
    
    // If this is set as default, unset other defaults first
    if (router.isDefault) {
      await _clearDefaultRouter(db);
    }
    
    final id = await db.insert(_tableName, router.toInsertMap());
    _log.i('Router saved with ID: $id');
    
    return SavedRouterModel(
      id: id,
      name: router.name,
      host: router.host,
      port: router.port,
      username: router.username,
      password: router.password,
      isDefault: router.isDefault,
      lastConnected: router.lastConnected,
      createdAt: router.createdAt,
      updatedAt: router.updatedAt,
    );
  }

  @override
  Future<SavedRouterModel> updateRouter(SavedRouterModel router) async {
    if (router.id == null) {
      throw ArgumentError('Router ID cannot be null for update');
    }
    
    _log.i('Updating router: ${router.id} - ${router.name}');
    final db = await DatabaseHelper.instance.database;
    
    // If this is set as default, unset other defaults first
    if (router.isDefault) {
      await _clearDefaultRouter(db, exceptId: router.id);
    }
    
    final updatedRouter = SavedRouterModel(
      id: router.id,
      name: router.name,
      host: router.host,
      port: router.port,
      username: router.username,
      password: router.password,
      isDefault: router.isDefault,
      lastConnected: router.lastConnected,
      createdAt: router.createdAt,
      updatedAt: DateTime.now(),
    );
    
    await db.update(
      _tableName,
      updatedRouter.toMap(),
      where: 'id = ?',
      whereArgs: [router.id],
    );
    
    _log.i('Router updated successfully');
    return updatedRouter;
  }

  @override
  Future<bool> deleteRouter(int id) async {
    _log.i('Deleting router: $id');
    final db = await DatabaseHelper.instance.database;
    
    final count = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    final success = count > 0;
    _log.i('Router deleted: $success');
    return success;
  }

  @override
  Future<void> setDefaultRouter(int id) async {
    _log.i('Setting default router: $id');
    final db = await DatabaseHelper.instance.database;
    
    // Clear all defaults
    await _clearDefaultRouter(db);
    
    // Set new default
    await db.update(
      _tableName,
      {'is_default': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    
    _log.i('Default router set successfully');
  }

  @override
  Future<void> updateLastConnected(int id) async {
    _log.d('Updating last connected time for router: $id');
    final db = await DatabaseHelper.instance.database;
    
    await db.update(
      _tableName,
      {
        'last_connected': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> routerExists(String host, int port, String username) async {
    _log.d('Checking if router exists: $host:$port@$username');
    final db = await DatabaseHelper.instance.database;
    
    final results = await db.query(
      _tableName,
      where: 'host = ? AND port = ? AND username = ?',
      whereArgs: [host, port, username],
      limit: 1,
    );
    
    return results.isNotEmpty;
  }

  Future<void> _clearDefaultRouter(dynamic db, {int? exceptId}) async {
    if (exceptId != null) {
      await db.update(
        _tableName,
        {'is_default': 0},
        where: 'is_default = 1 AND id != ?',
        whereArgs: [exceptId],
      );
    } else {
      await db.update(
        _tableName,
        {'is_default': 0},
        where: 'is_default = 1',
      );
    }
  }
}
