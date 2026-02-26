import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite3 Storage 适配器
///
/// 实现 Riverpod 的 Storage 接口，使用 sqlite3 作为底层存储
base class Sqlite3Storage extends Storage {
  final Database _database;

  Sqlite3Storage(this._database) {
    _initializeTable();
  }

  /// 初始化持久化表
  void _initializeTable() {
    _database.execute('''
      CREATE TABLE IF NOT EXISTS riverpod_persistence (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 创建索引
    _database.execute('''
      CREATE INDEX IF NOT EXISTS idx_riverpod_persistence_created_at
      ON riverpod_persistence(created_at)
    ''');
  }

  @override
  Future<void> close() async {
    // 数据库由外部管理，不在这里关闭
  }

  @override
  FutureOr<void> delete(Object? key) async {
    _ensureTableExists();
    _database.execute(
      'DELETE FROM riverpod_persistence WHERE key = ?',
      [key.toString()],
    );
  }

  @override
  FutureOr<void> deleteAll() async {
    _ensureTableExists();
    _database.execute('DELETE FROM riverpod_persistence');
  }

  @override
  FutureOr<PersistedData<Object?>?> read(Object? key) async {
    _ensureTableExists();
    AppLog.info('Reading from storage: key=$key', name: 'Sqlite3Storage');
    final results = _database.select(
      'SELECT value FROM riverpod_persistence WHERE key = ?',
      [key.toString()],
    );

    if (results.isEmpty) {
      AppLog.info('No data found for key: $key', name: 'Sqlite3Storage');
      return null;
    }

    final value = results.first['value'] as String;
    AppLog.info('Found data for key: $key, length=${value.length}', name: 'Sqlite3Storage');
    final decoded = jsonDecode(value) as Object?;
    return PersistedData(decoded);
  }

  @override
  FutureOr<void> write(
    Object? key,
    Object? value,
    StorageOptions options,
  ) async {
    _ensureTableExists();
    final now = DateTime.now().millisecondsSinceEpoch;
    final jsonValue = value is String ? value : jsonEncode(value);

    AppLog.info('Writing to storage: key=$key, value length=${jsonValue.length}', name: 'Sqlite3Storage');

    // 检查是否已存在
    final existing = _database.select(
      'SELECT key FROM riverpod_persistence WHERE key = ?',
      [key.toString()],
    );

    if (existing.isEmpty) {
      // 插入新记录
      _database.execute(
        'INSERT INTO riverpod_persistence (key, value, created_at, updated_at) VALUES (?, ?, ?, ?)',
        [key.toString(), jsonValue, now, now],
      );
      AppLog.info('Inserted new record for key: $key', name: 'Sqlite3Storage');
    } else {
      // 更新现有记录
      _database.execute(
        'UPDATE riverpod_persistence SET value = ?, updated_at = ? WHERE key = ?',
        [jsonValue, now, key.toString()],
      );
      AppLog.info('Updated existing record for key: $key', name: 'Sqlite3Storage');
    }
  }

  @override
  void deleteOutOfDate() {
    // Riverpod 的持久化系统会在需要时调用此方法
    // 检查表是否存在，如果不存在则跳过
    try {
      final result = _database.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='riverpod_persistence'",
      );
      if (result.isEmpty) {
        // 表不存在，跳过清理
        return;
      }

      // 清理超过2天的数据
      _database.execute(
        'DELETE FROM riverpod_persistence WHERE created_at < ?',
        [DateTime.now().millisecondsSinceEpoch - const Duration(days: 2).inMilliseconds],
      );
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 清理过期的缓存数据
  ///
  /// [cacheDuration] 缓存时长（毫秒）
  /// 返回删除的行数
  int clearExpired(int cacheDuration) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expireTime = now - cacheDuration;

    _database.execute(
      'DELETE FROM riverpod_persistence WHERE created_at < ?',
      [expireTime],
    );

    final result = _database.select('SELECT changes() as count');
    return result.first['count'] as int;
  }

  /// 获取所有键
  List<String> getAllKeys() {
    final results = _database.select('SELECT key FROM riverpod_persistence');
    return results.map((row) => row['key'] as String).toList();
  }

  /// 检查键是否存在
  bool hasKey(String key) {
    _ensureTableExists();
    final results = _database.select(
      'SELECT key FROM riverpod_persistence WHERE key = ?',
      [key],
    );
    return results.isNotEmpty;
  }

  /// 确保表存在
  void _ensureTableExists() {
    try {
      final result = _database.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='riverpod_persistence'",
      );
      if (result.isEmpty) {
        _initializeTable();
      }
    } catch (e) {
      // 如果检查失败，尝试初始化表
      _initializeTable();
    }
  }
}
