import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:hive/hive.dart';

/// Hive 存储仓库实现（基础类型）
///
/// 包装 Hive Box，实现 StorageRepository 接口
class HiveStorageRepository implements StorageRepository {
  final Box<dynamic> _box;

  HiveStorageRepository(this._box);

  /// 从已有的 Box 创建仓库
  factory HiveStorageRepository.fromBox(Box<dynamic> box) {
    return HiveStorageRepository(box);
  }

  @override
  String? getString(String key) {
    return _box.get(key, defaultValue: null) as String?;
  }

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  int? getInt(String key) {
    return _box.get(key, defaultValue: null) as int?;
  }

  @override
  Future<void> setInt(String key, int? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  double? getDouble(String key) {
    return _box.get(key, defaultValue: null) as double?;
  }

  @override
  Future<void> setDouble(String key, double? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  bool? getBool(String key) {
    return _box.get(key, defaultValue: null) as bool?;
  }

  @override
  Future<void> setBool(String key, bool? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  List<String>? getStringList(String key) {
    final list = _box.get(key, defaultValue: null) as List?;
    if (list == null) return null;
    return list.cast<String>();
  }

  @override
  Future<void> setStringList(String key, List<String>? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  bool containsKey(String key) {
    return _box.containsKey(key);
  }

  @override
  List<dynamic> get keys => _box.keys.toList();

  @override
  Map<dynamic, dynamic> toMap() {
    return _box.toMap();
  }
}

/// Hive 类型化存储仓库实现（复杂对象）
///
/// 支持 Hive 注册的自定义类型
class HiveTypedStorageRepository<T> implements TypedStorageRepository<T> {
  final Box<T> _box;

  HiveTypedStorageRepository(this._box);

  /// 从已有的 Box 创建仓库
  factory HiveTypedStorageRepository.fromBox(Box<T> box) {
    return HiveTypedStorageRepository(box);
  }

  @override
  T? get(String key) {
    return _box.get(key, defaultValue: null);
  }

  @override
  Future<void> set(String key, T? value) async {
    if (value == null) {
      await _box.delete(key);
    } else {
      await _box.put(key, value);
    }
  }

  @override
  Future<void> remove(String key) async {
    await _box.delete(key);
  }

  @override
  Map<String, T> toMap() {
    final map = <String, T>{};
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        map[key.toString()] = value;
      }
    }
    return map;
  }

  @override
  Future<void> putAll(Map<String, T> map) async {
    await _box.putAll(map);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  @override
  List<dynamic> get keys => _box.keys.toList();

  @override
  bool containsKey(String key) {
    return _box.containsKey(key);
  }
}
