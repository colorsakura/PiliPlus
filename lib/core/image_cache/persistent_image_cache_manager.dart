/// 持久化图片缓存管理器
///
/// 使用应用文档目录存储图片缓存，确保持久化存储
library;

import 'package:PiliPlus/core/image_cache/persistent_file_system.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 持久化图片缓存管理器
///
/// 使用单例模式 + ImageCacheManager mixin + 持久化文件系统
class PersistentImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'persistentImageCache';

  static final PersistentImageCacheManager _instance = PersistentImageCacheManager._();

  factory PersistentImageCacheManager() {
    return _instance;
  }

  PersistentImageCacheManager._() : super(
    Config(
      key,
      stalePeriod: const Duration(days: 90),  // 90天有效期
      maxNrOfCacheObjects: 1000,  // 最多1000个图片
      // 使用持久化文件系统，存储在应用文档目录
      fileSystem: PersistentFileSystem(key),
    ),
  );
}

/// 持久化图片缓存管理器实例
late final PersistentImageCacheManager persistentImageCacheManager = PersistentImageCacheManager();
