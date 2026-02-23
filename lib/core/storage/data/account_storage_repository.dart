import 'dart:convert';

import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:mmkv/mmkv.dart';

/// 账户存储仓库
///
/// 专门用于存储 LoginAccount 对象的仓库
/// 使用 MMKV + JSON 序列化
class AccountStorageRepository implements TypedStorageRepository<LoginAccount> {
  final MMKV _mmkv;

  AccountStorageRepository(this._mmkv);

  /// 从配置创建账户仓库
  factory AccountStorageRepository.fromConfig({
    required String storeName,
    String? rootDir,
  }) {
    final mmkv = MMKV(storeName, rootDir: rootDir);
    return AccountStorageRepository(mmkv);
  }

  @override
  LoginAccount? get(String key) {
    final jsonStr = _mmkv.decodeString(key);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return LoginAccount.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> set(String key, LoginAccount? value) async {
    if (value == null) {
      _mmkv.removeValue(key);
    } else {
      final json = value.toJson();
      if (json == null) {
        throw ArgumentError('LoginAccount.toJson() returned null');
      }
      final jsonStr = jsonEncode(json);
      _mmkv.encodeString(key, jsonStr);
    }
  }

  @override
  Future<void> remove(String key) async {
    _mmkv.removeValue(key);
  }

  @override
  Map<String, LoginAccount> toMap() {
    final map = <String, LoginAccount>{};
    for (final key in _mmkv.allKeys) {
      final value = get(key);
      if (value != null) {
        map[key] = value;
      }
    }
    return map;
  }

  @override
  Future<void> putAll(Map<String, LoginAccount> map) async {
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

  /// 检查仓库是否为空
  bool get isEmpty => _mmkv.allKeys.isEmpty;

  /// 获取账户数量
  int get length => _mmkv.allKeys.length;
}
