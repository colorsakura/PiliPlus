import 'dart:io';

import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:PiliPlus/core/image_cache/custom_file_service.dart';

/// 持久化图片缓存管理器
///
/// 使用应用文档目录存储图片缓存
class PersistentCacheManager {
  static const key = 'persistentCacheManager';
  static CacheManager? _instance;
  static Directory? _cacheDir;
  static bool _initialized = false;

  /// 获取缓存管理器实例
  ///
  /// 如果还未初始化，返回默认缓存管理器
  static CacheManager get instance {
    if (_instance == null) {
      if (!_initialized) {
        // 如果还未初始化，使用默认缓存管理器
        AppLog.fine('PersistentCacheManager not yet initialized, using DefaultCacheManager', name: 'ImageCache');
        return DefaultCacheManager();
      }
      throw Exception('PersistentCacheManager initialization failed');
    }
    return _instance!;
  }

  /// 初始化缓存管理器
  static Future<void> init() async {
    if (_initialized) {
      AppLog.fine('PersistentCacheManager already initialized', name: 'ImageCache');
      return;
    }

    try {
      // 确保缓存目录存在
      final docsDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${docsDir.path}/image_cache');
      if (!_cacheDir!.existsSync()) {
        _cacheDir!.createSync(recursive: true);
      }

      // 创建使用持久化目录的 CacheManager
      _instance = CacheManager(
        Config(
          key,
          stalePeriod: const Duration(days: 30),
          maxNrOfCacheObjects: 1000,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: CustomFileService(),
          fileSystem: IOFileSystem(_cacheDir!.path),
        ),
      );

      _initialized = true;
      AppLog.info('Persistent image cache initialized at: ${_cacheDir!.path}', name: 'ImageCache');
    } catch (e) {
      AppLog.warning('Failed to initialize persistent cache: $e', name: 'ImageCache');
      // 如果初始化失败，使用默认缓存管理器
      _instance = DefaultCacheManager();
      _initialized = true;
    }
  }
}

/// 默认的持久化缓存管理器实例
///
/// 如果还未初始化，会自动使用 DefaultCacheManager
CacheManager get persistentCacheManager => PersistentCacheManager.instance;
