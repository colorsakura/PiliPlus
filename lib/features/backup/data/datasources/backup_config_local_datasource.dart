import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';

/// 备份配置本地数据源接口
abstract interface class BackupConfigLocalDataSource {
  WebDavConfig getWebDavConfig();
  Future<void> saveWebDavConfig(WebDavConfig config);
}

/// 备份配置本地数据源实现
class BackupConfigLocalDataSourceImpl implements BackupConfigLocalDataSource {
  @override
  WebDavConfig getWebDavConfig() {
    return WebDavConfig(
      uri: Pref.webdavUri,
      username: Pref.webdavUsername,
      password: Pref.webdavPassword,
      directory: Pref.webdavDirectory,
    );
  }

  @override
  Future<void> saveWebDavConfig(WebDavConfig config) async {
    await GStorage.setting.putAll({
      SettingBoxKey.webdavUri: config.uri,
      SettingBoxKey.webdavUsername: config.username,
      SettingBoxKey.webdavPassword: config.password,
      SettingBoxKey.webdavDirectory: config.directory,
    });
  }
}
