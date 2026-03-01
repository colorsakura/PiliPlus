/// Hive Box API 兼容包装器
///
/// 将旧的 Hive Box API 调用转换为新的 Repository API 调用
/// 用于向后兼容，逐步迁移到新的 Repository API

import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';

/// 通用 Box 兼容包装器
class BoxCompatibilityWrapper implements StorageRepository {
  final StorageRepository _repository;
  final String name;

  BoxCompatibilityWrapper({
    required StorageRepository repository,
    required this.name,
  }) : _repository = repository;

  @override
  bool containsKey(String key) => _repository.containsKey(key);

  @override
  Future<void> clear() => _repository.clear();

  @override
  List<dynamic> get keys => _repository.keys;

  @override
  Map<dynamic, dynamic> toMap() => _repository.toMap();

  @override
  Future<void> remove(String key) => _repository.remove(key);

  @override
  String? getString(String key) => _repository.getString(key);

  @override
  Future<void> setString(String key, String? value) =>
      _repository.setString(key, value);

  @override
  int? getInt(String key) => _repository.getInt(key);

  @override
  Future<void> setInt(String key, int? value) =>
      _repository.setInt(key, value);

  @override
  double? getDouble(String key) => _repository.getDouble(key);

  @override
  Future<void> setDouble(String key, double? value) =>
      _repository.setDouble(key, value);

  @override
  bool? getBool(String key) => _repository.getBool(key);

  @override
  Future<void> setBool(String key, bool? value) =>
      _repository.setBool(key, value);

  @override
  List<String>? getStringList(String key) => _repository.getStringList(key);

  @override
  Future<void> setStringList(String key, List<String>? value) =>
      _repository.setStringList(key, value);

  // ============ Hive Box API 兼容方法 ============

  /// Hive Box 兼容：put 方法
  /// 根据值的类型自动选择正确的存储方法
  Future<void> put(dynamic key, dynamic value) async {
    if (value == null) {
      await remove(key.toString());
    } else if (value is String) {
      await setString(key.toString(), value);
    } else if (value is int) {
      await setInt(key.toString(), value);
    } else if (value is double) {
      await setDouble(key.toString(), value);
    } else if (value is bool) {
      await setBool(key.toString(), value);
    } else if (value is List) {
      await setStringList(key.toString(), value.cast<String>());
    } else {
      // 其他类型转换为 JSON 字符串存储
      await setString(key.toString(), value.toString());
    }
  }

  /// Hive Box 兼容：get 方法
  dynamic get(dynamic key, {dynamic defaultValue}) {
    final result = getString(key.toString());
    return result ?? defaultValue;
  }

  /// Hive Box 兼容：delete 方法
  Future<void> delete(dynamic key) => remove(key.toString());

  /// Hive Box 兼容：deleteAll 方法
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  /// Hive Box 兼容：putAll 方法
  Future<void> putAll(Map<dynamic, dynamic> entries) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value);
    }
  }

  /// Hive Box 兼容：isEmpty 属性
  bool get isEmpty => keys.isEmpty;

  /// Hive Box 兼容：isNotEmpty 属性
  bool get isNotEmpty => keys.isNotEmpty;

  /// Hive Box 兼容：length 属性
  int get length => keys.length;
}

/// 类型化 Box 兼容包装器
class TypedBoxCompatibilityWrapper<T> {
  final TypedStorageRepository<T> _repository;
  final String name;

  TypedBoxCompatibilityWrapper({
    required TypedStorageRepository<T> repository,
    required this.name,
  }) : _repository = repository;

  /// 获取所有键
  List<dynamic> get keys => _repository.keys;

  /// 检查键是否存在
  bool containsKey(String key) => _repository.containsKey(key);

  /// 获取值
  T? get(dynamic key, {T? defaultValue}) {
    final result = _repository.get(key.toString());
    return result ?? defaultValue;
  }

  /// 设置值
  Future<void> put(dynamic key, T? value) =>
      _repository.set(key.toString(), value);

  /// 删除键
  Future<void> delete(dynamic key) => _repository.remove(key.toString());

  /// 删除多个键
  Future<void> deleteAll(Iterable<dynamic> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }

  /// 清空所有数据
  Future<void> clear() => _repository.clear();

  /// Hive Box 兼容：isEmpty 属性
  bool get isEmpty => keys.isEmpty;

  /// Hive Box 兼容：isNotEmpty 属性
  bool get isNotEmpty => keys.isNotEmpty;

  /// Hive Box 兼容：length 属性
  int get length => keys.length;

  /// Hive Box 兼容：putAll 方法
  Future<void> putAll(Map<dynamic, T> entries) async {
    for (final entry in entries.entries) {
      await put(entry.key, entry.value);
    }
  }
}
