import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_result.dart';
import 'package:PiliPlus/features/blacklist/domain/repositories/blacklist_repository.dart';

/// 获取黑名单用例
///
/// 封装获取黑名单列表的业务逻辑
class FetchBlacklistUseCase {
  final BlacklistRepository _repository;

  const FetchBlacklistUseCase(this._repository);

  /// 执行用例：获取黑名单列表
  ///
  /// [pn] 页码，从1开始
  /// [ps] 每页数量，默认20
  Future<BlacklistResultEntity> call({
    required int pn,
    int ps = 20,
  }) {
    return _repository.getBlacklist(
      pn: pn,
      ps: ps,
    );
  }
}
