import 'dart:convert';

import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:mmkv/mmkv.dart';

/// 存储迁移工具
///
/// 用于从 Hive 迁移数据到 MMKV
class StorageMigrator {
  /// 迁移标志键
  static const String _migrationFlagKey = '_mmkv_migration_completed';

  /// 检查是否已完成迁移
  static bool hasMigrated(String boxName) {
    try {
      return MMKV(boxName).decodeBool(_migrationFlagKey);
    } catch (e) {
      return false;
    }
  }

  /// 标记迁移完成
  static void markMigrated(String boxName) {
    try {
      MMKV(boxName).encodeBool(_migrationFlagKey, true);
    } catch (e) {
      debugPrint('Failed to mark migration for $boxName: $e');
    }
  }

  /// 迁移基础类型数据（Hive -> MMKV）
  ///
  /// 将 Hive Box 中的所有数据迁移到 MMKV
  static Future<bool> migrateBasicTypes({
    required String boxName,
    MMKV? targetMMKV,
  }) async {
    try {
      // 检查是否已迁移
      if (hasMigrated(boxName)) {
        debugPrint('Migration already completed for $boxName');
        return true;
      }

      // 尝试获取已打开的 Box，或者打开新的 Box
      final Box<dynamic> box = Hive.isBoxOpen(boxName)
          ? Hive.box(boxName)
          : await Hive.openBox<dynamic>(boxName);

      final mmkv = targetMMKV ?? MMKV(boxName);

      int successCount = 0;
      int failCount = 0;

      // 遍历所有键值对
      for (final key in box.keys) {
        try {
          final value = box.get(key);
          if (value == null) continue;

          final keyStr = key.toString();

          // 根据类型写入 MMKV
          if (value is String) {
            mmkv.encodeString(keyStr, value);
          } else if (value is int) {
            mmkv.encodeInt32(keyStr, value);
          } else if (value is double) {
            mmkv.encodeDouble(keyStr, value);
          } else if (value is bool) {
            mmkv.encodeBool(keyStr, value);
          } else if (value is List) {
            // List 转为 JSON 字符串
            final jsonStr = jsonEncode(value);
            mmkv.encodeString(keyStr, jsonStr);
          } else {
            // 其他类型转为 JSON 字符串
            final jsonStr = jsonEncode(value);
            mmkv.encodeString(keyStr, jsonStr);
          }
          successCount++;
        } catch (e) {
          debugPrint('Failed to migrate key $key: $e');
          failCount++;
        }
      }

      // 标记迁移完成
      markMigrated(boxName);

      debugPrint(
        'Migration completed for $boxName: '
        '$successCount succeeded, $failCount failed',
      );

      return failCount == 0;
    } catch (e) {
      debugPrint('Migration failed for $boxName: $e');
      return false;
    }
  }

  /// 迁移复杂对象数据（Hive -> MMKV）
  ///
  /// 将 Hive Box 中的复杂对象迁移到 MMKV（需要 JSON 序列化）
  static Future<bool> migrateTypedObjects<T>({
    required String boxName,
    required JsonCodec<T> codec,
    MMKV? targetMMKV,
  }) async {
    try {
      // 检查是否已迁移
      if (hasMigrated(boxName)) {
        debugPrint('Migration already completed for $boxName');
        return true;
      }

      // 尝试获取已打开的 Box，或者打开新的 Box
      Box<T>? box;
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box(boxName) as Box<T>;
      } else {
        box = await Hive.openBox<T>(boxName);
      }

      final mmkv = targetMMKV ?? MMKV(boxName);

      int successCount = 0;
      int failCount = 0;

      // 遍历所有键值对
      for (final key in box.keys) {
        try {
          final value = box.get(key);
          if (value == null) continue;

          // 使用 codec 将对象转为 JSON
          final json = codec.toJson(value);
          final jsonStr = jsonEncode(json);

          mmkv.encodeString(key.toString(), jsonStr);
          successCount++;
        } catch (e) {
          debugPrint('Failed to migrate key $key: $e');
          failCount++;
        }
      }

      // 标记迁移完成
      markMigrated(boxName);

      debugPrint(
        'Typed migration completed for $boxName: '
        '$successCount succeeded, $failCount failed',
      );

      return failCount == 0;
    } catch (e) {
      debugPrint('Typed migration failed for $boxName: $e');
      return false;
    }
  }

  /// 回滚迁移（MMKV -> Hive）
  ///
  /// 从 MMKV 迁移数据回 Hive Box
  static Future<bool> rollbackMigration({
    required String boxName,
    MMKV? sourceMMKV,
  }) async {
    try {
      final mmkv = sourceMMKV ?? MMKV(boxName);
      final box = await Hive.openBox<dynamic>(boxName);

      int successCount = 0;
      int failCount = 0;

      for (final key in mmkv.allKeys) {
        try {
          final value = _decodeMMKVValue(mmkv, key);
          if (value != null) {
            await box.put(key, value);
            successCount++;
          }
        } catch (e) {
          debugPrint('Failed to rollback key $key: $e');
          failCount++;
        }
      }

      debugPrint(
        'Rollback completed for $boxName: '
        '$successCount succeeded, $failCount failed',
      );

      return failCount == 0;
    } catch (e) {
      debugPrint('Rollback failed for $boxName: $e');
      return false;
    }
  }

  /// 清除迁移标志
  ///
  /// 用于强制重新迁移
  static void clearMigrationFlag(String boxName) {
    try {
      MMKV(boxName).removeValue(_migrationFlagKey);
    } catch (e) {
      debugPrint('Failed to clear migration flag for $boxName: $e');
    }
  }

  /// Helper to decode value from MMKV, trying different types
  static dynamic _decodeMMKVValue(MMKV mmkv, String key) {
    // Try different decoders and return first non-null/non-empty result
    final strVal = mmkv.decodeString(key);
    if (strVal != null && strVal.isNotEmpty) return strVal;

    // ignore: unnecessary_null_comparison
    final intVal = mmkv.decodeInt(key);
    // ignore: unnecessary_null_comparison
    if (intVal != null) return intVal;

    // ignore: dead_code
    final doubleVal = mmkv.decodeDouble(key);
    // ignore: unnecessary_null_comparison
    if (doubleVal != null) return doubleVal;

    return mmkv.decodeBool(key);
  }

  /// 批量迁移多个 Box
  ///
  /// 迁移多个 Hive Box 到 MMKV
  static Future<Map<String, bool>> migrateMultiple({
    required List<String> boxNames,
  }) async {
    final results = <String, bool>{};

    for (final boxName in boxNames) {
      results[boxName] = await migrateBasicTypes(boxName: boxName);
    }

    return results;
  }

  /// 迁移账户数据（Hive -> MMKV）
  ///
  /// 将账户数据从 Hive Box<LoginAccount> 迁移到 MMKV
  /// 使用 JSON 序列化存储
  static Future<bool> migrateAccounts({
    required String boxName,
    MMKV? targetMMKV,
  }) async {
    try {
      // 检查是否已迁移
      if (hasMigrated(boxName)) {
        debugPrint('Account migration already completed for $boxName');
        return true;
      }

      // 尝试获取已打开的 Box，或者打开新的 Box
      Box<LoginAccount>? box;
      if (Hive.isBoxOpen(boxName)) {
        box = Hive.box(boxName) as Box<LoginAccount>;
      } else {
        box = await Hive.openBox<LoginAccount>(boxName);
      }

      final mmkv = targetMMKV ?? MMKV(boxName);

      int successCount = 0;
      int failCount = 0;

      // 遍历所有账户
      for (final key in box.keys) {
        try {
          final account = box.get(key);
          if (account == null) continue;

          // 使用 LoginAccount 的 toJson 方法
          final json = account.toJson();
          if (json == null) {
            debugPrint('Account toJson returned null for key $key');
            failCount++;
            continue;
          }

          final jsonStr = jsonEncode(json);
          mmkv.encodeString(key.toString(), jsonStr);
          successCount++;
        } catch (e) {
          debugPrint('Failed to migrate account key $key: $e');
          failCount++;
        }
      }

      // 标记迁移完成
      markMigrated(boxName);

      debugPrint(
        'Account migration completed for $boxName: '
        '$successCount succeeded, $failCount failed',
      );

      return failCount == 0;
    } catch (e) {
      debugPrint('Account migration failed for $boxName: $e');
      return false;
    }
  }
}
