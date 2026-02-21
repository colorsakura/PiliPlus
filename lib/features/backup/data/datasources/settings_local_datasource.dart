import 'package:PiliPlus/core/storage/storage.dart';

/// 设置本地数据源接口
abstract interface class SettingsLocalDataSource {
  String exportAllSettings();
  Future<void> importAllSettings(String jsonData);
}

/// 设置本地数据源实现
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  @override
  String exportAllSettings() {
    return GStorage.exportAllSettings();
  }

  @override
  Future<void> importAllSettings(String jsonData) {
    return GStorage.importAllSettings(jsonData);
  }
}
