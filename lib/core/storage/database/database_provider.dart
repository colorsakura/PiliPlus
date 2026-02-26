import 'dart:io';

import 'package:PiliPlus/utils/log.dart';
import 'package:path/path.dart' as path;
import 'package:sqlite3/sqlite3.dart';

/// 数据库提供者
///
/// 管理数据库连接和生命周期
class DatabaseProvider {
  /// 数据库实例
  Database? _database;

  /// 数据库文件路径
  final String databasePath;

  /// 数据库名称
  final String databaseName;

  /// 数据库版本
  final int version;

  /// 是否已初始化
  bool get isInitialized => _database != null;

  /// 私有构造函数
  DatabaseProvider._({
    required this.databasePath,
    required this.databaseName,
    required this.version,
  });

  /// 创建数据库提供者
  ///
  /// [databasePath] 数据库文件存放目录
  /// [databaseName] 数据库文件名
  /// [version] 数据库版本号
  factory DatabaseProvider.create({
    required String databasePath,
    required String databaseName,
    required int version,
  }) {
    return DatabaseProvider._(
      databasePath: databasePath,
      databaseName: databaseName,
      version: version,
    );
  }

  /// 获取数据库实例
  ///
  /// 如果数据库未初始化，会先执行初始化
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  /// 初始化数据库
  ///
  /// [onCreate] 数据库创建时的回调
  /// [onUpgrade] 数据库升级时的回调
  Future<void> init({
    void Function(Database db)? onCreate,
    void Function(Database db, int oldVersion, int newVersion)? onUpgrade,
  }) async {
    if (_database != null) {
      AppLog.warning('Database already initialized', name: 'Database');
      return;
    }

    try {
      // 确保数据库目录存在
      final dbDir = Directory(databasePath);
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      final dbPath = path.join(databasePath, databaseName);
      final file = File(dbPath);
      final isNewDatabase = !await file.exists();

      // 打开数据库
      _database = sqlite3.open(dbPath);

      // 设置数据库参数
      _database!.execute('PRAGMA foreign_keys = ON');
      _database!.execute('PRAGMA journal_mode = WAL');
      _database!.execute('PRAGMA synchronous = NORMAL');
      _database!.execute('PRAGMA cache_size = -64000'); // 64MB cache
      _database!.execute('PRAGMA temp_store = MEMORY');

      if (isNewDatabase) {
        AppLog.info('Creating new database', name: 'Database');
        onCreate?.call(_database!);

        // 设置版本号
        _database!.execute(
          'PRAGMA user_version = $version',
        );
      } else {
        // 检查版本并执行升级
        final resultSet = _database!.select('PRAGMA user_version');
        final oldVersion = resultSet.first['user_version'] as int;

        if (oldVersion < version) {
          AppLog.info(
            'Upgrading database from $oldVersion to $version',
            name: 'Database',
          );
          onUpgrade?.call(_database!, oldVersion, version);

          // 更新版本号
          _database!.execute(
            'PRAGMA user_version = $version',
          );
        }
      }

      AppLog.info('Database initialized successfully', name: 'Database');
    } catch (e, stackTrace) {
      AppLog.severe(
        'Failed to initialize database: $e',
        name: 'Database',
        error: e,
        stackTrace: stackTrace,
      );
      await close();
      rethrow;
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    _database?.close();
    _database = null;
    AppLog.info('Database closed', name: 'Database');
  }

  /// 执行事务
  ///
  /// [action] 事务内执行的操作，返回操作结果
  /// 返回操作结果，如果事务失败则返回 null
  T? runInTransaction<T>(T Function(Database db) action) {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }

    try {
      _database!.execute('BEGIN TRANSACTION');
      final result = action(_database!);
      _database!.execute('COMMIT');
      return result;
    } catch (e) {
      _database!.execute('ROLLBACK');
      AppLog.warning('Transaction failed, rolled back: $e', name: 'Database');
      rethrow;
    }
  }

  /// 检查表是否存在
  bool tableExists(String tableName) {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }

    final resultSet = _database!.select('''
      SELECT name FROM sqlite_master
      WHERE type='table' AND name=?
    ''', [tableName]);

    return resultSet.isNotEmpty;
  }

  /// 获取表的列信息
  List<Map<String, dynamic>> getTableColumns(String tableName) {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }

    final resultSet = _database!.select('PRAGMA table_info($tableName)');

    return resultSet.map((row) {
      return {
        'cid': row['cid'],
        'name': row['name'],
        'type': row['type'],
        'notnull': row['notnull'] == 1,
        'dflt_value': row['dflt_value'],
        'pk': row['pk'] == 1,
      };
    }).toList();
  }
}
