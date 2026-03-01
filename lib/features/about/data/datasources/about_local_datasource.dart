import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/cache_manager.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/update.dart';

/// About页面本地数据源
///
/// 负责与应用配置、存储、缓存等本地资源交互
class AboutLocalDataSource {
  /// 获取应用版本名称
  String getVersionName() => BuildConfig.versionName;

  /// 获取应用版本号
  int getVersionCode() => BuildConfig.versionCode;

  /// 获取构建时间（Unix时间戳）
  int getBuildTime() => BuildConfig.buildTime;

  /// 获取提交哈希
  String getCommitHash() => BuildConfig.commitHash;

  /// 获取源代码URL
  String getSourceCodeUrl() => Constants.sourceCodeUrl;

  /// 获取应用名称
  String getAppName() => Constants.appName;

  /// 获取缓存大小
  Future<int> getCacheSize() => CacheManager.loadApplicationCache();

  /// 格式化缓存大小
  String formatCacheSize(int sizeInBytes) =>
      CacheManager.formatSize(sizeInBytes);

  /// 清除缓存
  Future<void> clearCache() => CacheManager.clearLibraryCache();

  /// 导出所有设置
  String exportAllSettings() => GStorage.exportAllSettings();

  /// 导入设置
  Future<bool> importAllJsonSettings(Map<String, dynamic> json) =>
      GStorage.importAllJsonSettings(json);

  /// 获取登录信息
  Map<dynamic, LoginAccount> getLoginInfo() => Accounts.account.toMap();

  /// 导入登录信息
  Future<bool> importLoginInfo(Map<String, dynamic> json) async {
    final res = json.map(
      (key, value) => MapEntry(
        key,
        LoginAccount.fromJson(value as Map<String, dynamic>),
      ),
    );
    await Accounts.account.putAll(res);
    await Accounts.refresh();
    if (Accounts.main.isLogin) {
      await LoginUtils.onLoginMain();
    }
    return true;
  }

  /// 重置可导出的设置
  Future<void> resetExportableSettings() async {
    await Future.wait([
      GStorage.settingRepository.clear(),
      GStorage.videoRepository.clear(),
    ]);
  }

  /// 重置所有数据
  Future<void> resetAllData() async {
    await Future.wait([
      GStorage.userInfoRepository.clear(),
      GStorage.settingRepository.clear(),
      GStorage.localCacheRepository.clear(),
      GStorage.videoRepository.clear(),
      GStorage.historyWordRepository.clear(),
      Accounts.clear(),
      GStorage.watchProgressRepository.clear(),
    ]);
  }

  /// 检查更新
  Future<void> checkUpdate({bool showMessage = false}) {
    return Update.checkUpdate(showMessage);
  }
}
