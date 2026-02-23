import 'dart:convert';

import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:mmkv/mmkv.dart';

/// MMKV 存储仓库实现（基础类型）
///
/// 使用 MMKV 实现高性能的键值存储
class MMKVStorageRepository implements StorageRepository {
  final MMKV _mmkv;

  MMKVStorageRepository(this._mmkv);

  /// 从配置创建 MMKV 仓库
  factory MMKVStorageRepository.fromConfig({
    required String storeName,
    String? cryptKey,
    String? rootDir,
  }) {
    final mmkv = MMKV(
      storeName,
      cryptKey: cryptKey,
      rootDir: rootDir,
    );
    return MMKVStorageRepository(mmkv);
  }

  @override
  String? getString(String key) {
    return _mmkv.decodeString(key);
  }

  @override
  Future<void> setString(String key, String? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      _mmkv.encodeString(key, value);
    }
  }

  @override
  int? getInt(String key) {
    return _mmkv.decodeInt(key);
  }

  @override
  Future<void> setInt(String key, int? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      _mmkv.encodeInt32(key, value);
    }
  }

  @override
  double? getDouble(String key) {
    return _mmkv.decodeDouble(key);
  }

  @override
  Future<void> setDouble(String key, double? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      _mmkv.encodeDouble(key, value);
    }
  }

  @override
  bool? getBool(String key) {
    return _mmkv.decodeBool(key);
  }

  @override
  Future<void> setBool(String key, bool? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      _mmkv.encodeBool(key, value);
    }
  }

  @override
  List<String>? getStringList(String key) {
    final jsonStr = _mmkv.decodeString(key);
    if (jsonStr == null) return null;
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.cast<String>();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setStringList(String key, List<String>? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      final jsonStr = jsonEncode(value);
      _mmkv.encodeString(key, jsonStr);
    }
  }

  @override
  Future<void> remove(String key) async {
    _mmkv.removeValue(key);
  }

  @override
  Future<void> clear() async {
    _mmkv.removeValues(_mmkv.allKeys);
  }

  @override
  bool containsKey(String key) {
    return _mmkv.containsKey(key);
  }

  @override
  List<dynamic> get keys => _mmkv.allKeys;

  @override
  Map<dynamic, dynamic> toMap() {
    final map = <dynamic, dynamic>{};
    for (final key in _mmkv.allKeys) {
      final value = _decodeValue(key);
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  /// Helper to decode value from MMKV, trying different types
  dynamic? _decodeValue(String key) {
    // Try different decoders and return first non-null/non-empty result
    final strVal = _mmkv.decodeString(key);
    if (strVal != null && strVal.isNotEmpty) return strVal;

    final intVal = _mmkv.decodeInt(key);
    if (intVal != null) return intVal;

    return _mmkv.decodeDouble(key) ?? _mmkv.decodeBool(key);
  }
}

/// MMKV 类型化存储仓库（JSON 序列化支持）
///
/// 用于存储需要 JSON 序列化的复杂对象
class MMKVTypedStorageRepository<T> implements TypedStorageRepository<T> {
  final MMKV _mmkv;
  final JsonCodec<T>? _codec;

  MMKVTypedStorageRepository(
    this._mmkv, {
    JsonCodec<T>? codec,
  }) : _codec = codec;

  /// 从配置创建 MMKV 类型化仓库
  factory MMKVTypedStorageRepository.fromConfig({
    required String storeName,
    required JsonCodec<T> codec,
    String? cryptKey,
    String? rootDir,
  }) {
    final mmkv = MMKV(
      storeName,
      cryptKey: cryptKey,
      rootDir: rootDir,
    );
    return MMKVTypedStorageRepository(mmkv, codec: codec);
  }

  @override
  T? get(String key) {
    final jsonStr = _mmkv.decodeString(key);
    if (jsonStr == null) return null;
    if (_codec == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _codec.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> set(String key, T? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      final codec = _codec;
      if (codec == null) {
        throw ArgumentError('JsonCodec must be provided for typed storage');
      }
      final json = codec.toJson(value);
      final jsonStr = jsonEncode(json);
      _mmkv.encodeString(key, jsonStr);
    }
  }

  @override
  Future<void> remove(String key) async {
    _mmkv.removeValue(key);
  }

  @override
  Map<String, T> toMap() {
    final map = <String, T>{};
    if (_codec == null) return map;

    for (final key in _mmkv.allKeys) {
      final value = get(key);
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  @override
  Future<void> putAll(Map<String, T> map) async {
    for (final entry in map.entries) {
      await set(entry.key, entry.value);
    }
  }

  @override
  Future<void> clear() async {
    _mmkv.removeValues(_mmkv.allKeys);
  }

  @override
  List<dynamic> get keys => _mmkv.allKeys;

  @override
  bool containsKey(String key) {
    return _mmkv.containsKey(key);
  }
}
