import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';

/// 备份配置仓库接口
abstract interface class BackupConfigRepository {
  /// 获取 WebDAV 配置
  WebDavConfig getWebDavConfig();

  /// 保存 WebDAV 配置
  Future<void> saveWebDavConfig(WebDavConfig config);
}
