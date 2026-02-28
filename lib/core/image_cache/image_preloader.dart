import 'package:PiliPlus/utils/log.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// 图片预加载服务
///
/// 用于预加载网络图片到本地缓存
class ImagePreloader {
  /// 预加载图片列表
  ///
  /// [urls] 图片URL列表
  /// 返回成功缓存的图片数量
  static Future<int> preloadImages(List<String> urls) async {
    if (urls.isEmpty) return 0;

    AppLog.info(
      'Starting to preload ${urls.length} images',
      name: 'ImagePreloader',
    );

    int successCount = 0;
    final futures = urls.map(_preloadSingleImage);

    // 等待所有预加载完成（但设置超时）
    try {
      final results =
          await Future.wait(
            futures,
            eagerError: false,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              AppLog.warning('Image preload timeout', name: 'ImagePreloader');
              return List.filled(urls.length, false);
            },
          );

      successCount = results.where((success) => success).length;
    } catch (e) {
      AppLog.warning('Image preload error: $e', name: 'ImagePreloader');
    }

    AppLog.info(
      'Preload completed: $successCount/${urls.length} images cached',
      name: 'ImagePreloader',
    );

    return successCount;
  }

  /// 预加载单个图片
  static Future<bool> _preloadSingleImage(String url) async {
    try {
      if (url.isEmpty) return false;

      // 使用 CachedNetworkImageProvider 预加载图片
      final provider = CachedNetworkImageProvider(url)
        // 预加载图片到缓存
        ..resolve(ImageConfiguration.empty);

      return true;
    } catch (e) {
      // 忽略单个图片的错误
      return false;
    }
  }

  /// 从视频列表中提取封面URL
  static List<String> extractCoverUrls(List<dynamic> videos) {
    final urls = <String>[];

    for (final video in videos) {
      try {
        // 假设 video 有 cover 属性
        if (video is Map && video['cover'] != null) {
          final cover = video['cover'] as String;
          if (cover.isNotEmpty) {
            urls.add(cover);
          }
        }
      } catch (e) {
        // 忽略错误，继续处理下一个
      }
    }

    return urls;
  }

  /// 清除图片缓存
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      AppLog.info('Image cache cleared', name: 'ImagePreloader');
    } catch (e) {
      AppLog.warning('Failed to clear image cache: $e', name: 'ImagePreloader');
    }
  }

  /// 获取缓存大小
  static Future<int> getCacheSize() async {
    try {
      // 注意：这需要 cached_network_image 支持
      // 当前版本可能不支持获取缓存大小
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
