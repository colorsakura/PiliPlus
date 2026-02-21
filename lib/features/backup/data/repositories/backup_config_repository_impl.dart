import 'package:PiliPlus/features/backup/data/datasources/backup_config_local_datasource.dart';
import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/domain/repositories/backup_config_repository.dart';

/// 备份配置仓库实现
class BackupConfigRepositoryImpl implements BackupConfigRepository {
  final BackupConfigLocalDataSource _localDataSource;

  BackupConfigRepositoryImpl(this._localDataSource);

  @override
  WebDavConfig getWebDavConfig() {
    return _localDataSource.getWebDavConfig();
  }

  @override
  Future<void> saveWebDavConfig(WebDavConfig config) {
    return _localDataSource.saveWebDavConfig(config);
  }
}
