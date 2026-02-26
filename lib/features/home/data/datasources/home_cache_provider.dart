import 'package:PiliPlus/features/home/data/datasources/home_cache_service.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页缓存服务 Provider
///
/// 使用 Riverpod 的异步 provider 模式来管理缓存服务生命周期
final homeCacheProvider = FutureProvider<HomeCacheService>((ref) async {
  try {
    AppLog.info('Initializing HomeCacheService', name: 'HomeCache');
    return await HomeCacheService.create();
  } catch (e) {
    AppLog.severe('Failed to initialize HomeCacheService: $e', name: 'HomeCache');
    rethrow;
  }
});
