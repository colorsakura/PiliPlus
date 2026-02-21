import 'dart:convert';

import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/user/danmaku_rule_adapter.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account_adapter.dart';
import 'package:PiliPlus/utils/accounts/account_type_adapter.dart';
import 'package:PiliPlus/utils/accounts/cookie_jar_adapter.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:PiliPlus/utils/set_int_adapter.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;

abstract final class GStorage {
  static late final Box<UserInfoData> userInfo;
  static late final Box<dynamic> historyWord;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;
  static late final Box<int> watchProgress;

  /// 仅初始化关键 Box (用于阻塞阶段)
  ///
  /// 只打开 setting Box,用于读取 UI 缩放等关键设置
  /// 其他 Box 延迟到核心阶段打开,以加快启动速度
  static Future<void> initCritical() async {
    await Hive.initFlutter(path.join(appSupportDirPath, 'hive'));
    regAdapter();

    // 只打开 setting Box
    setting = await Hive.openBox('setting');
  }

  static Future<void> init() async {
    // 检查是否需要初始化基础设置
    // 使用 try-catch 来安全地检查 setting 是否已初始化
    bool needBaseInit;
    try {
      needBaseInit = !setting.isOpen;
    } catch (e) {
      // setting 未初始化，需要进行基础初始化
      needBaseInit = true;
    }

    if (needBaseInit) {
      await Hive.initFlutter(path.join(appSupportDirPath, 'hive'));
      regAdapter();
      await Hive.openBox('setting').then((res) => setting = res);
    }

    // 打开其他 Box
    await Future.wait([
      // 登录用户信息
      Hive.openBox<UserInfoData>(
        'userInfo',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 2;
        },
      ).then((res) => userInfo = res),
      // 本地缓存
      Hive.openBox(
        'localCache',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 4;
        },
      ).then((res) => localCache = res),
      // 搜索历史
      Hive.openBox(
        'historyWord',
        compactionStrategy: (int entries, int deletedEntries) {
          return deletedEntries > 10;
        },
      ).then((res) => historyWord = res),
      // 视频设置
      Hive.openBox('video').then((res) => video = res),
      Accounts.init(),
      Hive.openBox<int>(
        'watchProgress',
        compactionStrategy: (entries, deletedEntries) {
          return deletedEntries > 4;
        },
      ).then((res) => watchProgress = res),
    ]);
  }

  static String exportAllSettings() {
    return Utils.jsonEncoder.convert({
      setting.name: setting.toMap(),
      video.name: video.toMap(),
    });
  }

  static Future<void> importAllSettings(String data) =>
      importAllJsonSettings(jsonDecode(data));

  static Future<bool> importAllJsonSettings(Map<String, dynamic> map) async {
    await Future.wait([
      setting.clear().then((_) => setting.putAll(map[setting.name])),
      video.clear().then((_) => video.putAll(map[video.name])),
    ]);
    return true;
  }

  static void regAdapter() {
    Hive
      ..registerAdapter(OwnerAdapter())
      ..registerAdapter(UserInfoDataAdapter())
      ..registerAdapter(LevelInfoAdapter())
      ..registerAdapter(BiliCookieJarAdapter())
      ..registerAdapter(LoginAccountAdapter())
      ..registerAdapter(AccountTypeAdapter())
      ..registerAdapter(SetIntAdapter())
      ..registerAdapter(RuleFilterAdapter());
  }

  static Future<void> compact() async {
    await Future.wait([
      userInfo.compact(),
      historyWord.compact(),
      localCache.compact(),
      setting.compact(),
      video.compact(),
      Accounts.account.compact(),
      watchProgress.compact(),
    ]);
  }

  static Future<void> close() async {
    await Future.wait([
      userInfo.close(),
      historyWord.close(),
      localCache.close(),
      setting.close(),
      video.close(),
      Accounts.account.close(),
      watchProgress.close(),
    ]);
  }
}
