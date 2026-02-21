import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/domain/repositories/backup_config_repository.dart';

/// 保存 WebDAV 配置用例
class SaveWebDavConfigUseCase {
  final BackupConfigRepository _repository;

  const SaveWebDavConfigUseCase(this._repository);

  Future<void> call(WebDavConfig config) {
    return _repository.saveWebDavConfig(config);
  }
}
