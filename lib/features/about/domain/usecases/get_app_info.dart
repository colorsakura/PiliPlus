import 'package:PiliPlus/features/about/domain/entities/app_info.dart';
import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// 获取应用信息用例
class GetAppInfoUseCase {
  final AboutRepository _repository;

  const GetAppInfoUseCase(this._repository);

  Future<AppInfoEntity> call() {
    return _repository.getAppInfo();
  }
}
