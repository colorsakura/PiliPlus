import 'package:PiliPlus/features/backup/data/datasources/settings_local_datasource.dart';
import 'package:PiliPlus/features/backup/domain/entities/settings_data.dart';
import 'package:PiliPlus/features/backup/domain/repositories/settings_repository.dart';

/// 设置仓库实现
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<SettingsData> exportSettings() async {
    final jsonData = _localDataSource.exportAllSettings();
    return SettingsData(jsonData: jsonData);
  }

  @override
  Future<void> importSettings(SettingsData data) async {
    await _localDataSource.importAllSettings(data.jsonData);
  }
}
