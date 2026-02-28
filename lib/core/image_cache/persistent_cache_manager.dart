import 'dart:io';

import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// 持久化图片缓存管理器
///
/// 使用应用文档目录存储图片缓存
class PersistentCacheManager {
  static const key = 'persistentCacheManager';
  static CacheManager? _instance;
  static Directory? _cacheDir;
  static bool _initialized = false;

  /// 获取缓存管理器实例
  static CacheManager get instance {
    _instance ??= CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 500, // 性能优化：减少缓存对象数量，降低内存压力
      ),
    );
    return _instance!;
  }

  /// 初始化缓存管理器（异步设置缓存目录）
  static Future<void> init() async {
    if (_initialized) return;

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${docsDir.path}/image_cache');
      if (!_cacheDir!.existsSync()) {
        _cacheDir!.createSync(recursive: true);
      }
      _initialized = true;
      AppLog.info('Persistent cache directory: ${_cacheDir!.path}', name: 'ImageCache');
    } catch (e) {
      AppLog.warning('Failed to create cache directory: $e', name: 'ImageCache');
      _initialized = true;
    }
  }
}

/// 持久化缓存管理器实例
CacheManager get persistentCacheManager => PersistentCacheManager.instance;
