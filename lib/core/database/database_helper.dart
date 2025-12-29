import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/logger.dart';

// Conditional import for desktop FFI support
import 'database_helper_stub.dart'
    if (dart.library.ffi) 'database_helper_ffi.dart' as ffi_helper;

class DatabaseHelper {
  static final _log = AppLogger.tag('DatabaseHelper');
  static Database? _database;
  static const String _databaseName = 'mik_flutter.db';
  static const int _databaseVersion = 3;

  // Singleton pattern
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    _log.i('Initializing database...');
    
    // Initialize FFI for desktop platforms (Windows, Linux)
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      ffi_helper.initFfi();
      _log.d('Using FFI database factory for desktop');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    _log.d('Database path: $path');

    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _log.i('Database initialized successfully');
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    _log.i('Creating database tables (version $version)...');

    // Saved Routers table
    await db.execute('''
      CREATE TABLE saved_routers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL DEFAULT 8728,
        username TEXT NOT NULL,
        password TEXT NOT NULL,
        use_ssl INTEGER NOT NULL DEFAULT 0,
        is_default INTEGER NOT NULL DEFAULT 0,
        last_connected TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create unique index on host+port+username
    await db.execute('''
      CREATE UNIQUE INDEX idx_router_unique 
      ON saved_routers(host, port, username)
    ''');

    // Saved SNMP Devices table
    await db.execute('''
      CREATE TABLE saved_snmp_devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        host TEXT NOT NULL,
        port INTEGER NOT NULL DEFAULT 161,
        community TEXT NOT NULL DEFAULT 'public',
        proprietary TEXT NOT NULL DEFAULT 'general',
        is_default INTEGER NOT NULL DEFAULT 0,
        last_connected TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create unique index on host+port+community
    await db.execute('''
      CREATE UNIQUE INDEX idx_snmp_device_unique 
      ON saved_snmp_devices(host, port, community)
    ''');

    _log.i('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _log.i('Upgrading database from version $oldVersion to $newVersion');
    
    // Migration from version 1 to 2: Add use_ssl column
    if (oldVersion < 2) {
      _log.i('Adding use_ssl column to saved_routers table...');
      await db.execute('ALTER TABLE saved_routers ADD COLUMN use_ssl INTEGER NOT NULL DEFAULT 0');
      _log.i('Migration to version 2 completed');
    }

    // Migration from version 2 to 3: Add saved_snmp_devices table
    if (oldVersion < 3) {
      _log.i('Creating saved_snmp_devices table...');
      await db.execute('''
        CREATE TABLE saved_snmp_devices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          host TEXT NOT NULL,
          port INTEGER NOT NULL DEFAULT 161,
          community TEXT NOT NULL DEFAULT 'public',
          proprietary TEXT NOT NULL DEFAULT 'general',
          is_default INTEGER NOT NULL DEFAULT 0,
          last_connected TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      await db.execute('''
        CREATE UNIQUE INDEX idx_snmp_device_unique 
        ON saved_snmp_devices(host, port, community)
      ''');
      _log.i('Migration to version 3 completed');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _log.i('Database closed');
    }
  }
}
