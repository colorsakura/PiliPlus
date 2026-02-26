import 'package:PiliPlus/core/storage/database/base_dao.dart';
import 'package:PiliPlus/features/home/domain/entities/home_cache_entity.dart';
import 'package:sqlite3/sqlite3.dart';

/// 首页推荐缓存 DAO
///
/// 负责首页推荐数据的数据库操作
final class HomeCacheDao extends BaseDao {
  @override
  final Database db;

  @override
  final String tableName = 'home_cache';

  HomeCacheDao(this.db) {
    // 确保表存在
    _createTableIfNotExists();
  }

  void _createTableIfNotExists() {
    if (!_tableExists(tableName)) {
      createTable();
    }
  }

  /// 检查表是否存在
  bool _tableExists(String name) {
    final resultSet = db.select(
      '''
      SELECT name FROM sqlite_master
      WHERE type='table' AND name=?
    ''',
      [name],
    );
    return resultSet.isNotEmpty;
  }

  @override
  void createTable() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        aid INTEGER NOT NULL,
        bvid TEXT NOT NULL,
        cid INTEGER NOT NULL,
        cover TEXT NOT NULL,
        title TEXT NOT NULL,
        owner_mid INTEGER NOT NULL,
        owner_name TEXT NOT NULL,
        owner_face TEXT,
        duration INTEGER NOT NULL,
        view INTEGER NOT NULL DEFAULT 0,
        danmaku INTEGER NOT NULL DEFAULT 0,
        like INTEGER,
        rcmd_reason TEXT,
        goto TEXT,
        param INTEGER,
        uri TEXT,
        desc TEXT,
        card_type TEXT,
        pgc_badge TEXT,
        is_followed INTEGER NOT NULL DEFAULT 0,
        cached_at INTEGER NOT NULL,
        expire_at INTEGER NOT NULL,
        UNIQUE(aid)
      )
    ''');

    // 创建索引
    _createIndexes();
  }

  /// 创建索引
  void _createIndexes() {
    // 缓存时间索引
    db
      ..execute('''
      CREATE INDEX IF NOT EXISTS idx_home_cache_cached_at
      ON $tableName(cached_at)
    ''')
      // 过期时间索引
      ..execute('''
      CREATE INDEX IF NOT EXISTS idx_home_cache_expire_at
      ON $tableName(expire_at)
    ''')
      // UP 主 ID 索引
      ..execute('''
      CREATE INDEX IF NOT EXISTS idx_home_cache_owner_mid
      ON $tableName(owner_mid)
    ''');
  }

  /// 插入或更新缓存数据
  ///
  /// 如果 aid 已存在则更新，否则插入
  int insertOrUpdate(HomeCacheEntity entity) {
    final existing = queryOne(
      where: 'aid = ?',
      whereArgs: [entity.aid],
    );

    if (existing != null) {
      return update(
        entity.toInsertMap(),
        where: 'aid = ?',
        whereArgs: [entity.aid],
      );
    } else {
      return insert(entity.toInsertMap());
    }
  }

  /// 批量插入或更新缓存数据
  ///
  /// 使用事务处理，提高性能
  void insertOrUpdateBatch(List<HomeCacheEntity> entities) {
    db.execute('BEGIN TRANSACTION');
    try {
      for (final entity in entities) {
        final existing = db.select(
          'SELECT id FROM $tableName WHERE aid = ?',
          [entity.aid],
        );

        if (existing.isNotEmpty) {
          // 更新
          final values = entity.toInsertMap();

          final setClause = values.entries
              .map((e) => '${e.key} = ?')
              .join(', ');

          db.execute(
            'UPDATE $tableName SET $setClause WHERE aid = ?',
            [...values.values, entity.aid],
          );
        } else {
          // 插入
          final values = entity.toInsertMap();
          final columns = values.keys.join(', ');
          final placeholders = List.filled(values.length, '?').join(', ');
          final args = values.values.toList();

          db.execute(
            'INSERT INTO $tableName ($columns) VALUES ($placeholders)',
            args,
          );
        }
      }
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  /// 获取所有未过期的缓存数据
  List<HomeCacheEntity> getValidCache() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final results = query(
      where: 'expire_at > ?',
      whereArgs: [now],
      orderBy: 'cached_at DESC',
    );

    return results.map((map) => HomeCacheEntity.fromMap(map)).toList();
  }

  /// 根据 aid 获取缓存数据
  HomeCacheEntity? getByAid(int aid) {
    final result = queryOne(
      where: 'aid = ?',
      whereArgs: [aid],
    );

    return result != null ? HomeCacheEntity.fromMap(result) : null;
  }

  /// 根据 aid 列表获取缓存数据
  List<HomeCacheEntity> getByAids(List<int> aids) {
    if (aids.isEmpty) return [];

    final placeholders = List.filled(aids.length, '?').join(',');
    final results = query(
      where: 'aid IN ($placeholders)',
      whereArgs: aids,
      orderBy: 'cached_at DESC',
    );

    return results.map((map) => HomeCacheEntity.fromMap(map)).toList();
  }

  /// 根据 UP 主 ID 获取缓存数据
  List<HomeCacheEntity> getByOwnerMid(int ownerMid, {int limit = 10}) {
    final results = query(
      where: 'owner_mid = ?',
      whereArgs: [ownerMid],
      orderBy: 'cached_at DESC',
      limit: limit,
    );

    return results.map((map) => HomeCacheEntity.fromMap(map)).toList();
  }

  /// 清理过期数据
  ///
  /// 返回删除的行数
  int clearExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return delete(
      where: 'expire_at <= ?',
      whereArgs: [now],
    );
  }

  /// 获取缓存数量
  int getCacheCount({bool onlyValid = true}) {
    if (onlyValid) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return count(
        where: 'expire_at > ?',
        whereArgs: [now],
      );
    }
    return count();
  }

  /// 清空所有缓存
  void clearAll() {
    clear();
  }

  /// 删除指定 aid 的缓存
  int deleteByAid(int aid) {
    return delete(
      where: 'aid = ?',
      whereArgs: [aid],
    );
  }

  /// 删除指定 aid 列表的缓存
  int deleteByAids(List<int> aids) {
    if (aids.isEmpty) return 0;

    final placeholders = List.filled(aids.length, '?').join(',');
    return delete(
      where: 'aid IN ($placeholders)',
      whereArgs: aids,
    );
  }
}
