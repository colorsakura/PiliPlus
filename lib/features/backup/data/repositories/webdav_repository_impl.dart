import 'dart:convert';
import 'dart:typed_data';

import 'package:PiliPlus/common/widgets/pair.dart';
import 'package:PiliPlus/features/backup/data/datasources/webdav_remote_datasource.dart';
import 'package:PiliPlus/features/backup/domain/entities/backup_result.dart';
import 'package:PiliPlus/features/backup/domain/entities/settings_data.dart';
import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/domain/repositories/webdav_repository.dart';

/// WebDAV 仓库实现
class WebDavRepositoryImpl implements WebDavRepository {
  final WebDavRemoteDataSource _remoteDataSource;

  WebDavRepositoryImpl(this._remoteDataSource);

  @override
  Future<BackupResult> initialize(WebDavConfig config) async {
    try {
      final Pair<bool, String?> result = await _remoteDataSource.initialize(
        uri: config.uri,
        username: config.username,
        password: config.password,
        directory: config.directory,
      );

      if (result.first) {
        return BackupResult.success();
      } else {
        return BackupResult.failure('配置失败: ${result.second}');
      }
    } catch (e) {
      return BackupResult.failure('配置失败: ${e.toString()}');
    }
  }

  @override
  Future<BackupResult> backupSettings(SettingsData data) async {
    try {
      const fileName = 'piliplus_settings.json';

      await _remoteDataSource.uploadFile(
        fileName,
        Uint8List.fromList(utf8.encode(data.jsonData)),
      );

      return BackupResult.success('备份成功');
    } catch (e) {
      return BackupResult.failure('备份失败: ${e.toString()}');
    }
  }

  @override
  Future<SettingsData?> restoreSettings() async {
    try {
      const fileName = 'piliplus_settings.json';

      final data = await _remoteDataSource.downloadFile(fileName);
      return SettingsData(jsonData: utf8.decode(data));
    } catch (e) {
      return null;
    }
  }
}
