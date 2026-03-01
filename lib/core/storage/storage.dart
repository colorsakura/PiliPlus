import 'dart:convert';
import 'dart:io';

import 'package:PiliPlus/core/storage/data/storage_config.dart';
import 'package:PiliPlus/core/storage/data/storage_factory.dart';
import 'package:PiliPlus/core/storage/data/storage_migrator.dart';
import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';
import 'package:PiliPlus/models/user/info.dart';
// 账户系统已迁移到 MMKV，需要导入 Accounts 进行初始化
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/log.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:mmkv/mmkv.dart';
import 'package:path/path.dart' as path;

/// 全局存储管理类
///
/// 提供统一的存储接口，内部使用 MMKV 存储后端
/// 首次启动时自动从 Hive 迁移数据，完全透明
abstract final class GStorage {
  // ============ 新架构：存储仓库 ============

  /// 设置存储仓库
  static late final StorageRepository settingRepository;

  /// 本地缓存存储仓库
  static late final StorageRepository localCacheRepository;

  /// 视频存储仓库
  static late final StorageRepository videoRepository;

  /// 搜索历史存储仓库
  static late final StorageRepository historyWordRepository;

  /// 用户信息存储仓库（类型化）
  static late final TypedStorageRepository<UserInfoData> userInfoRepository;

  /// 观看进度存储仓库
  static late final StorageRepository watchProgressRepository;

  /// 是否已初始化
  static bool _isInitialized = false;

  /// 是否已完成关键初始化（仅 setting Box）
  static bool _isCriticalInitialized = false;

  /// 是否使用 MMKV（默认 true）
  static bool get useMMKV => true;

  /// 仅初始化关键 Box (用于阻塞阶段)
  ///
  /// 只打开 setting MMKV，用于读取 UI 缩放等关键设置
  static Future<void> initCritical() async {
    if (_isCriticalInitialized) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    AppLog.info('Starting critical initialization (MMKV)', name: 'Storage');

    // 初始化 MMKV
    await MMKV.initialize(
      rootDir: path.join(appSupportDirPath, 'mmkv'),
      logLevel: MMKVLogLevel.None,
    );

    // 检查并迁移 setting 数据
    await _migrateIfNeeded('setting');

    // 创建 setting 仓库
    settingRepository = StorageFactory.getRepository(
      const StorageConfig.mmkv(name: 'setting'),
    );

    _isCriticalInitialized = true;
    stopwatch.stop();
    AppLog.info(
      'Critical initialization completed in ${stopwatch.elapsedMilliseconds}ms',
      name: 'Storage',
    );
  }

  /// 完整初始化所有 Box
  ///
  /// 初始化所有存储，用于核心阶段
  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    AppLog.info('Starting full initialization (MMKV)', name: 'Storage');

    // 迁移所有数据（如果需要）
    await Future.wait([
      _migrateIfNeeded('localCache'),
      _migrateIfNeeded('video'),
      _migrateIfNeeded('historyWord'),
      _migrateIfNeeded('userInfo', isTyped: true),
      _migrateIfNeeded('watchProgress'),
    ]);

    // 创建所有存储仓库
    localCacheRepository = StorageFactory.getRepository(
      const StorageConfig.mmkv(name: 'localCache'),
    );
    videoRepository = StorageFactory.getRepository(
      const StorageConfig.mmkv(name: 'video'),
    );
    historyWordRepository = StorageFactory.getRepository(
      const StorageConfig.mmkv(name: 'historyWord'),
    );
    watchProgressRepository = StorageFactory.getRepository(
      const StorageConfig.mmkv(name: 'watchProgress'),
    );

    // 用户信息需要 JSON 序列化
    userInfoRepository = StorageFactory.getTypedRepository<UserInfoData>(
      const StorageConfig.mmkv(name: 'userInfo'),
      codec: JsonCodec(
        fromJson: UserInfoData.fromJson,
        toJson: (data) => data.toJson(),
      ),
    );

    // 初始化账户系统（必须在 HTTP 客户端初始化之前）
    await Accounts.init();

    _isInitialized = true;
    stopwatch.stop();
    AppLog.info(
      'Full initialization completed in ${stopwatch.elapsedMilliseconds}ms',
      name: 'Storage',
    );
  }

  /// 检查并迁移数据（Hive -> MMKV）
  static Future<void> _migrateIfNeeded(
    String boxName, {
    bool isTyped = false,
  }) async {
    // 检查是否已迁移
    if (StorageMigrator.hasMigrated(boxName)) {
      return;
    }

    // 检查 Hive Box 是否存在且有数据
    bool hasHiveData = false;
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.initFlutter(path.join(appSupportDirPath, 'hive'));
        _registerAdaptersIfNeeded();
      }

      if (await Hive.boxExists(boxName)) {
        final box = await Hive.openBox<dynamic>(boxName);
        hasHiveData = box.isNotEmpty;
        // 注意：不要关闭 box，因为迁移工具需要它
        // 在迁移完成后统一关闭
      }
    } catch (e) {
      AppLog.fine('Failed to check Hive box $boxName: $e', name: 'Storage');
    }

    // 如果没有 Hive 数据，标记为已迁移并返回
    if (!hasHiveData) {
      MMKV(boxName).encodeBool('_mmkv_migration_completed', true);
      return;
    }

    // 执行迁移
    AppLog.info('Migrating $boxName from Hive to MMKV...', name: 'Storage');
    try {
      if (isTyped && boxName == 'userInfo') {
        await StorageMigrator.migrateTypedObjects<UserInfoData>(
          boxName: boxName,
          codec: JsonCodec(
            fromJson: UserInfoData.fromJson,
            toJson: (data) => data.toJson(),
          ),
        );
      } else {
        await StorageMigrator.migrateBasicTypes(boxName: boxName);
      }
      AppLog.info('Migration completed for $boxName', name: 'Storage');
    } catch (e) {
      AppLog.severe('Migration failed for $boxName: $e', name: 'Storage');
      // 迁移失败时继续使用，下次会重试
    }
  }

  /// 导出所有设置到文件
  static Future<File> syncToDisk([_]) {
    final jsonPath = path.join(appSupportDirPath, 'settings.json');
    return File(jsonPath).writeAsString(exportAllSettings());
  }

  /// 导出所有设置为 JSON 字符串
  static String exportAllSettings() {
    // 从 MMKV 导出
    return Utils.jsonEncoder.convert({
      'setting': settingRepository.toMap(),
      'video': videoRepository.toMap(),
    });
  }

  /// 从 JSON 字符串导入所有设置
  static Future<void> importAllSettings(String data) =>
      importAllJsonSettings(jsonDecode(data));

  /// 从 JSON Map 导入所有设置
  static Future<bool> importAllJsonSettings(Map<String, dynamic> map) async {
    // 导入到 MMKV
    if (map['setting'] != null) {
      final settings = map['setting'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        final value = entry.value;
        if (value is String) {
          await settingRepository.setString(entry.key, value);
        } else if (value is int) {
          await settingRepository.setInt(entry.key, value);
        } else if (value is double) {
          await settingRepository.setDouble(entry.key, value);
        } else if (value is bool) {
          await settingRepository.setBool(entry.key, value);
        } else if (value is List) {
          // Handle List types (e.g., List<String>)
          await settingRepository.setStringList(
            entry.key,
            value.map((e) => e.toString()).toList(),
          );
        }
      }
    }
    if (map['video'] != null) {
      final videos = map['video'] as Map<String, dynamic>;
      for (final entry in videos.entries) {
        final value = entry.value;
        if (value is String) {
          await videoRepository.setString(entry.key, value);
        } else if (value is int) {
          await videoRepository.setInt(entry.key, value);
        } else if (value is double) {
          await videoRepository.setDouble(entry.key, value);
        } else if (value is bool) {
          await videoRepository.setBool(entry.key, value);
        } else if (value is List) {
          // Handle List types (e.g., List<String>)
          await videoRepository.setStringList(
            entry.key,
            value.map((e) => e.toString()).toList(),
          );
        }
      }
    }
    return true;
  }

  /// 压缩所有 Box
  static Future<void> compact() async {
    // MMKV 不需要手动压缩
    debugPrint('MMKV does not need manual compaction');
  }

  /// 关闭所有 Box
  static Future<void> close() async {
    _isInitialized = false;
  }
}
