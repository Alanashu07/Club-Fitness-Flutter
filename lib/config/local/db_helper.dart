import 'dart:async';

import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/image_cache/data/data_source/cache_image_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A singleton class for handling SQLite database operations using Sqflite.
///
/// This class ensures that only a single instance of the database is created
/// and provides methods to initialize the database, create tables, and perform other operations.
class DBHelper {
  /// Private constructor for implementing the singleton pattern.
  DBHelper._();

  /// The single instance of [DBHelper].
  static final DBHelper _helper = DBHelper._();

  /// Factory constructor to return the singleton instance of [DBHelper].
  factory DBHelper() => _helper;

  /// The database file name.
  static const String databaseName = 'club_fitness.db';

  static const String images = 'images';

  static const String failedImages = 'failed_images';

  /// Private variable to hold the database instance.
  Database? _database;

  /// Getter method to obtain the database instance.
  ///
  /// If the database is already initialized, it returns the existing instance;
  /// otherwise, it initializes and returns a new database instance.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database by opening or creating it.
  ///
  /// - Returns a [Database] instance.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), databaseName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Callback method that runs when the database is created.
  ///
  /// This is where you should create tables.
  Future<void> _onCreate(Database db, int version) async {
    await sl<CacheImageDataSource>().createImageTable(db);
  }

  // Helper function to add column if missing
  Future<void> addColumnIfNotExists(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    final exists = result.any((col) => col['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  /// Creates a table in the database if it does not already exist.
  ///
  /// - [db]: The database instance where the table will be created.
  /// - [tableName]: The name of the table to be created.
  /// - [columns]: A map containing column names as keys and their data types as values.
  ///
  /// Example usage:
  /// ```dart
  /// await dbHelper.createTable(
  ///   db: database,
  ///   tableName: 'users',
  ///   columns: {
  ///     'id': 'INTEGER PRIMARY KEY AUTOINCREMENT',
  ///     'name': 'TEXT',
  ///     'email': 'TEXT UNIQUE'
  ///   },
  /// );
  /// ```
  Future<void> createTable({
    required Database db,
    required String tableName,
    required Map<String, String> columns,
    String? additional,
  }) async {
    String columnsDef = columns.entries
        .map((e) => '${e.key} ${e.value}')
        .join(', ');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS $tableName ($columnsDef${additional != null ? ', $additional' : ''})',
    );
  }

  /// Deletes the database file from the device storage.
  ///
  /// This method removes the database file and resets the instance to null.
  Future<void> deleteDatabaseFile() async {
    // Get the path to the database
    String dbPath = join(await getDatabasesPath(), databaseName);
    final db = await database;
    db.close();

    // Delete the database
    await deleteDatabase(dbPath);

    // Set the database instance to null
    _database = null;

    if (kDebugMode) {
      print('Database deleted successfully');
    }
  }

  /// Checks if a table exists in the database.
  ///
  /// - [db]: The database instance.
  /// - [tableName]: The name of the table to check.
  ///
  /// Returns `true` if the table exists, otherwise `false`.
  Future<bool> checkIfTableExists(Database db, String tableName) async {
    // Query to check if the table exists
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );

    // If result is not empty, the table exists
    return result.isNotEmpty;
  }

  Future<List<String>> getTableNames() async {
    final db = await database;
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return tables.map((table) => table['name'] as String).toList();
  }

  Future<List<String>> getColumnNames(Database db, String tableName) async {
    final List<Map<String, dynamic>> columns = await db.rawQuery(
      "PRAGMA table_info($tableName)",
    );
    return columns.map((column) => column['name'] as String).toList();
  }

  String getSqliteDataType(dynamic value) {
    if (value is int) {
      return 'INTEGER';
    } else if (value is double) {
      return 'REAL';
    } else if (value is String) {
      return 'TEXT';
    } else if (value is bool) {
      // SQLite doesn't have a BOOLEAN type, conventionally stored as INTEGER (0 or 1)
      return 'INTEGER';
    } else if (value is List<int>) {
      // For binary blobs
      return 'BLOB';
    } else if (value == null) {
      // Default to TEXT or throw an error based on your use-case
      return 'NULL';
    } else {
      throw UnsupportedError('Unsupported value type: ${value.runtimeType}');
    }
  }
}
