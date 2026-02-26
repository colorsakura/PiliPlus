import 'package:PiliPlus/core/storage/database/database_manager.dart';
import 'package:PiliPlus/core/storage/database/sqlite3_storage.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';

/// SQLite3 Storage Provider
///
/// 为 Riverpod 的离线持久化提供 Storage 实例
final sqlite3StorageProvider = FutureProvider<Sqlite3Storage>((ref) async {
  try {
    AppLog.info('Initializing Sqlite3Storage', name: 'StorageProvider');
    // 使用现有的首页缓存数据库
    final provider = await DatabaseManager.getHomeCacheDatabase();
    final storage = Sqlite3Storage(provider.database);
    AppLog.info('Sqlite3Storage initialized successfully', name: 'StorageProvider');
    return storage;
  } catch (e) {
    AppLog.severe('Failed to initialize Sqlite3Storage: $e', name: 'StorageProvider');
    rethrow;
  }
});

/// 内存存储 Provider（用于测试）
///
/// 创建一个基于内存的临时存储，适合单元测试和 widget 测试
FutureProvider<Sqlite3Storage> createInMemoryStorageProvider() {
  return FutureProvider<Sqlite3Storage>((ref) async {
    final db = sqlite3.openInMemory();
    return Sqlite3Storage(db);
  });
}
