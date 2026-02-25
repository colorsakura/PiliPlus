import 'package:PiliPlus/core/storage/data/datasources/hive_storage_repository_impl.dart';
import 'package:PiliPlus/core/storage/data/datasources/mmkv_storage_repository_impl.dart';
import 'package:PiliPlus/core/storage/data/storage_config.dart';
import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:hive/hive.dart';

/// 存储工厂
///
/// 负责创建和管理存储仓库实例
/// 支持延迟初始化和单例模式
class StorageFactory {
  /// 已创建的存储仓库缓存
  static final Map<String, StorageRepository> _repositories = {};
  static final Map<String, TypedStorageRepository> _typedRepositories = {};

  /// 获取基础类型存储仓库
  ///
  /// 使用工厂模式创建或返回已缓存的仓库实例
  static StorageRepository getRepository(StorageConfig config) {
    return _repositories.putIfAbsent(
      config.name,
      () => _createRepository(config),
    );
  }

  /// 获取类型化存储仓库
  ///
  /// 用于存储复杂对象
  static TypedStorageRepository<T> getTypedRepository<T>(
    StorageConfig config, {
    JsonCodec<T>? codec,
  }) {
    return _typedRepositories.putIfAbsent(
          config.name,
          () => _createTypedRepository<T>(config, codec),
        )
        as TypedStorageRepository<T>;
  }

  /// 创建基础类型存储仓库
  static StorageRepository _createRepository(StorageConfig config) {
    switch (config.type) {
      case StorageType.mmkv:
        return MMKVStorageRepository.fromConfig(
          storeName: config.name,
          cryptKey: config.cryptKey,
          rootDir: config.rootDir,
        );
      case StorageType.hive:
        // Hive 需要先打开 Box，这里假设已经在 GStorage 中打开
        // 实际使用时应该传入已打开的 Box
        return HiveStorageRepository.fromBox(
          Hive.box<dynamic>(config.name),
        );
    }
  }

  /// 创建类型化存储仓库
  static TypedStorageRepository<T> _createTypedRepository<T>(
    StorageConfig config,
    JsonCodec<T>? codec,
  ) {
    switch (config.type) {
      case StorageType.mmkv:
        if (codec == null) {
          throw ArgumentError('JsonCodec is required for MMKV typed storage');
        }
        return MMKVTypedStorageRepository<T>.fromConfig(
          storeName: config.name,
          codec: codec,
          cryptKey: config.cryptKey,
          rootDir: config.rootDir,
        );
      case StorageType.hive:
        return HiveTypedStorageRepository<T>.fromBox(
          Hive.box<T>(config.name),
        );
    }
  }

  /// 清空所有缓存的仓库
  static void clearCache() {
    _repositories.clear();
    _typedRepositories.clear();
  }

  /// 检查仓库是否已创建
  static bool hasRepository(String name) {
    return _repositories.containsKey(name) ||
        _typedRepositories.containsKey(name);
  }
}
