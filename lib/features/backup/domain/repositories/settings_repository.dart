import 'package:PiliPlus/features/backup/domain/entities/settings_data.dart';

/// 设置仓库接口
abstract interface class SettingsRepository {
  /// 导出所有设置
  Future<SettingsData> exportSettings();

  /// 导入设置
  Future<void> importSettings(SettingsData data);
}
