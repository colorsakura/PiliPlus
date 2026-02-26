import 'package:PiliPlus/core/storage/database/database_manager.dart';
import 'package:PiliPlus/core/storage/database/database_provider.dart';
import 'package:PiliPlus/features/home/data/datasources/home_cache_dao.dart';
import 'package:PiliPlus/features/home/domain/entities/home_cache_entity.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/log.dart';

/// 首页缓存服务
///
/// 负责首页推荐的缓存管理
class HomeCacheService {
  /// DAO 实例（延迟初始化）
  HomeCacheDao? _dao;

  /// 默认缓存时长（毫秒）
  /// 默认 1 小时
  static const int defaultCacheDuration = 60 * 60 * 1000;

  /// 最大缓存数量
  static const int maxCacheSize = 200;

  /// 获取 DAO 实例
  HomeCacheDao get dao {
    _dao ??= HomeCacheDao(
      DatabaseManager.databases[DatabaseNames.homeCache]!.database,
    );
    return _dao!;
  }

  /// 初始化服务
  static Future<HomeCacheService> create() async {
    final provider = await DatabaseManager.getHomeCacheDatabase();
    final service = HomeCacheService._(provider);
    await service._init();
    return service;
  }

  HomeCacheService._(DatabaseProvider provider) {
    // 确保 DAO 已初始化
    _dao = HomeCacheDao(provider.database);
  }

  /// 初始化
  Future<void> _init() async {
    // 清理过期数据
    final deleted = dao.clearExpired();
    if (deleted > 0) {
      AppLog.info('Cleared $deleted expired cache items', name: 'HomeCache');
    }

    // 检查缓存数量
    final count = dao.getCacheCount(onlyValid: false);
    if (count > maxCacheSize) {
      // 删除最旧的数据
      final excess = count - maxCacheSize;
      final results = dao.db.select('''
        SELECT id FROM ${dao.tableName}
        ORDER BY cached_at ASC
        LIMIT $excess
      ''');

      final idsToDelete = results.map((row) => row['id'] as int).toList();
      if (idsToDelete.isNotEmpty) {
        final placeholders = List.filled(idsToDelete.length, '?').join(',');
        dao.db.execute(
          'DELETE FROM ${dao.tableName} WHERE id IN ($placeholders)',
          idsToDelete,
        );
        AppLog.info('Removed $excess old cache items', name: 'HomeCache');
      }
    }
  }

  /// 保存推荐视频列表到缓存
  ///
  /// [items] 推荐视频列表
  /// [cacheDuration] 缓存时长（毫秒），默认 1 小时
  Future<void> saveCache(
    List<dynamic> items, {
    int cacheDuration = defaultCacheDuration,
  }) async {
    if (items.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final entities = <HomeCacheEntity>[];

    for (final item in items) {
      if (item is! RecVideoItemAppModel) continue;

      final aid = item.aid ?? 0;
      if (aid == 0) continue;

      entities.add(
        HomeCacheEntity(
          id: 0, // 自增
          aid: aid,
          bvid: item.bvid ?? IdUtils.av2bv(aid),
          cid: item.cid ?? 0,
          cover: item.cover ?? '',
          title: item.title ?? '',
          ownerMid: item.owner.mid ?? 0,
          ownerName: item.owner.name ?? '',
          ownerFace: null, // 推荐接口没有 UP 主头像
          duration: item.duration,
          view: item.stat.view ?? 0,
          danmaku: item.stat.danmu ?? 0,
          like: item.stat.like ?? 0,
          rcmdReason: item.rcmdReason,
          goto: item.goto,
          param: item.param,
          uri: item.uri,
          desc: item.desc,
          cardType: item.cardType,
          pgcBadge: item.pgcBadge,
          isFollowed: item.isFollowed ? 1 : 0,
          cachedAt: now,
          expireAt: now + cacheDuration,
        ),
      );
    }

    if (entities.isNotEmpty) {
      dao.insertOrUpdateBatch(entities);
      AppLog.info('Cached ${entities.length} items', name: 'HomeCache');
    }
  }

  /// 获取有效的缓存数据
  List<HomeCacheEntity> getValidCache() {
    return dao.getValidCache();
  }

  /// 根据 aid 获取缓存
  HomeCacheEntity? getByAid(int aid) {
    return dao.getByAid(aid);
  }

  /// 根据 aid 列表获取缓存
  List<HomeCacheEntity> getByAids(List<int> aids) {
    return dao.getByAids(aids);
  }

  /// 清理过期缓存
  int clearExpired() {
    return dao.clearExpired();
  }

  /// 清空所有缓存
  void clearAll() {
    dao.clearAll();
    AppLog.info('Cleared all cache', name: 'HomeCache');
  }

  /// 获取缓存数量
  int getCacheCount({bool onlyValid = true}) {
    return dao.getCacheCount(onlyValid: onlyValid);
  }

  /// 检查缓存是否有效
  bool isCacheValid() {
    final count = getCacheCount(onlyValid: true);
    return count > 0;
  }
}
