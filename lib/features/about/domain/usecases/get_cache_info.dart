import 'package:PiliPlus/features/about/domain/entities/cache_info.dart';
import 'package:PiliPlus/features/about/domain/repositories/about_repository.dart';

/// 获取缓存信息用例
class GetCacheInfoUseCase {
  final AboutRepository _repository;

  const GetCacheInfoUseCase(this._repository);

  Future<CacheInfoEntity> call() {
    return _repository.getCacheInfo();
  }
}
