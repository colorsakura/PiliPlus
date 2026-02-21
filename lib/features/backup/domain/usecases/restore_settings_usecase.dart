import 'package:PiliPlus/features/backup/domain/entities/backup_result.dart';
import 'package:PiliPlus/features/backup/domain/repositories/settings_repository.dart';
import 'package:PiliPlus/features/backup/domain/repositories/webdav_repository.dart';

/// 恢复设置用例
class RestoreSettingsUseCase {
  final SettingsRepository _settingsRepository;
  final WebDavRepository _webDavRepository;

  const RestoreSettingsUseCase(
    this._settingsRepository,
    this._webDavRepository,
  );

  /// 执行恢复
  Future<BackupResult> call() async {
    try {
      // 1. 从 WebDAV 下载
      final settingsData = await _webDavRepository.restoreSettings();
      if (settingsData == null) {
        return BackupResult.failure('未找到备份文件');
      }

      // 2. 导入设置
      await _settingsRepository.importSettings(settingsData);

      return BackupResult.success();
    } catch (e) {
      return BackupResult.failure('恢复失败: ${e.toString()}');
    }
  }
}
