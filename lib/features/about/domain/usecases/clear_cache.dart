import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// 清除缓存用例
class ClearCacheUseCase {
  final AboutRepository _repository;

  const ClearCacheUseCase(this._repository);

  Future<bool> call() {
    return _repository.clearCache();
  }
}
