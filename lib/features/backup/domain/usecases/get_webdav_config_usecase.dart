import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/domain/repositories/backup_config_repository.dart';

/// 获取 WebDAV 配置用例
class GetWebDavConfigUseCase {
  final BackupConfigRepository _repository;

  const GetWebDavConfigUseCase(this._repository);

  WebDavConfig call() {
    return _repository.getWebDavConfig();
  }
}
