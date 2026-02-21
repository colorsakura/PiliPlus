import 'package:PiliPlus/features/backup/domain/entities/backup_result.dart';
import 'package:PiliPlus/features/backup/domain/entities/settings_data.dart';
import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';

/// WebDAV 仓库接口
abstract interface class WebDavRepository {
  /// 初始化 WebDAV 客户端
  Future<BackupResult> initialize(WebDavConfig config);

  /// 备份设置到 WebDAV
  Future<BackupResult> backupSettings(SettingsData data);

  /// 从 WebDAV 恢复设置
  Future<SettingsData?> restoreSettings();
}
