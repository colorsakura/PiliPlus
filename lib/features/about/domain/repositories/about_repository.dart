import 'package:PiliPlus/features/about/domain/entities/app_info.dart';
import 'package:PiliPlus/features/about/domain/entities/cache_info.dart';
import 'package:PiliPlus/features/about/domain/entities/export_data.dart';

/// About页面仓库接口
///
/// 定义关于页面相关的数据操作抽象
abstract interface class AboutRepository {
  /// 获取应用信息
  Future<AppInfoEntity> getAppInfo();

  /// 获取缓存信息
  Future<CacheInfoEntity> getCacheInfo();

  /// 清除缓存
  Future<bool> clearCache();

  /// 导出设置
  Future<ExportDataEntity> exportSettings();

  /// 导入设置
  Future<bool> importSettings(Map<String, dynamic> jsonData);

  /// 导出登录信息
  Future<ExportDataEntity> exportLoginInfo();

  /// 导入登录信息
  Future<bool> importLoginInfo(Map<String, dynamic> jsonData);

  /// 重置设置（可导出的）
  Future<bool> resetExportableSettings();

  /// 重置所有数据（含登录信息）
  Future<bool> resetAllData();

  /// 检查更新
  Future<void> checkUpdate({bool showMessage = false});
}
