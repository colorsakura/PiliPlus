import 'package:PiliPlus/features/blacklist/domain/repositories/blacklist_repository.dart';

/// 从黑名单移除用户用例
///
/// 封装从黑名单移除用户的业务逻辑
class RemoveFromBlacklistUseCase {
  final BlacklistRepository _repository;

  const RemoveFromBlacklistUseCase(this._repository);

  /// 执行用例：从黑名单移除用户
  ///
  /// [mid] 用户ID
  /// 返回是否成功
  Future<bool> call({
    required int mid,
  }) {
    return _repository.removeFromBlacklist(
      mid: mid,
    );
  }
}
