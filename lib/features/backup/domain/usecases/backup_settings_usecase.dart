import 'package:PiliPlus/features/backup/domain/entities/backup_result.dart';
import 'package:PiliPlus/features/backup/domain/repositories/settings_repository.dart';
import 'package:PiliPlus/features/backup/domain/repositories/webdav_repository.dart';

/// 备份设置用例
class BackupSettingsUseCase {
  final SettingsRepository _settingsRepository;
  final WebDavRepository _webDavRepository;

  const BackupSettingsUseCase(
    this._settingsRepository,
    this._webDavRepository,
  );

  /// 执行备份
  Future<BackupResult> call() async {
    try {
      // 1. 导出设置
      final settingsData = await _settingsRepository.exportSettings();

      // 2. 上传到 WebDAV
      return await _webDavRepository.backupSettings(settingsData);
    } catch (e) {
      return BackupResult.failure('备份失败: ${e.toString()}');
    }
  }
}
