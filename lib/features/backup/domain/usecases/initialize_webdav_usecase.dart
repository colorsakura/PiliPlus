import 'package:PiliPlus/features/backup/domain/entities/backup_result.dart';
import 'package:PiliPlus/features/backup/domain/entities/webdav_config.dart';
import 'package:PiliPlus/features/backup/domain/repositories/webdav_repository.dart';

/// 初始化 WebDAV 用例
class InitializeWebDavUseCase {
  final WebDavRepository _repository;

  const InitializeWebDavUseCase(this._repository);

  Future<BackupResult> call(WebDavConfig config) {
    return _repository.initialize(config);
  }
}
