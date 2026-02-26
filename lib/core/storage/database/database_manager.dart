import 'dart:io';

import 'package:PiliPlus/core/storage/database/database_provider.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:path/path.dart' as path;

/// 数据库名称常量
class DatabaseNames {
  /// 首页缓存数据库
  static const String homeCache = 'home_cache.db';
}

/// 数据库版本常量
class DatabaseVersions {
  /// 首页缓存数据库版本
  static const int homeCache = 1;
}

/// 数据库管理器
///
/// 负责管理应用中所有数据库的初始化和生命周期
abstract final class DatabaseManager {
  /// 数据库实例缓存（公开访问，供 DAO 使用）
  static final Map<String, DatabaseProvider> databases = {};

  /// 是否已初始化
  static bool _isInitialized = false;

  /// 数据库基础路径
  static late final String _databasePath;

  /// 初始化数据库管理器
  static Future<void> init() async {
    if (_isInitialized) {
      AppLog.warning('DatabaseManager already initialized', name: 'Database');
      return;
    }

    final stopwatch = Stopwatch()..start();
    AppLog.info('Initializing DatabaseManager', name: 'Database');

    // 设置数据库路径
    _databasePath = path.join(appSupportDirPath, 'databases');

    // 确保数据库目录存在
    final dbDir = Directory(_databasePath);
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
      AppLog.info('Created database directory: $_databasePath', name: 'Database');
    }

    _isInitialized = true;
    stopwatch.stop();
    AppLog.info(
      'DatabaseManager initialized in ${stopwatch.elapsedMilliseconds}ms',
      name: 'Database',
    );
  }

  /// 获取数据库提供者
  ///
  /// [name] 数据库名称
  /// [version] 数据库版本
  /// [onCreate] 数据库创建时的回调
  /// [onUpgrade] 数据库升级时的回调
  static Future<DatabaseProvider> getDatabase(
    String name, {
    required int version,
    void Function(DatabaseProvider provider)? onCreate,
    void Function(
      DatabaseProvider provider,
      int oldVersion,
      int newVersion,
    )? onUpgrade,
  }) async {
    if (!_isInitialized) {
      throw StateError('DatabaseManager not initialized. Call init() first.');
    }

    // 检查缓存
    if (databases.containsKey(name)) {
      return databases[name]!;
    }

    // 创建新的数据库提供者
    final provider = DatabaseProvider.create(
      databasePath: _databasePath,
      databaseName: name,
      version: version,
    );

    // 初始化数据库
    await provider.init(
      onCreate: (db) => onCreate?.call(provider),
      onUpgrade: (db, oldVersion, newVersion) =>
          onUpgrade?.call(provider, oldVersion, newVersion),
    );

    // 缓存数据库提供者
    databases[name] = provider;

    return provider;
  }

  /// 获取首页缓存数据库
  static Future<DatabaseProvider> getHomeCacheDatabase() async {
    return getDatabase(
      DatabaseNames.homeCache,
      version: DatabaseVersions.homeCache,
      onCreate: (provider) {
        AppLog.info('Creating home cache database', name: 'Database');
        // 表的创建由各自的 DAO 负责
      },
    );
  }

  /// 关闭指定数据库
  static Future<void> closeDatabase(String name) async {
    final provider = databases.remove(name);
    if (provider != null) {
      await provider.close();
      AppLog.info('Closed database: $name', name: 'Database');
    }
  }

  /// 关闭所有数据库
  static Future<void> closeAll() async {
    final closers = databases.values.map((provider) => provider.close());
    await Future.wait(closers);
    databases.clear();
    _isInitialized = false;
    AppLog.info('All databases closed', name: 'Database');
  }

  /// 检查数据库是否已打开
  static bool isDatabaseOpen(String name) {
    return databases.containsKey(name);
  }

  /// 获取数据库路径（用于调试）
  static String getDatabasePath(String name) {
    return path.join(_databasePath, name);
  }
}
