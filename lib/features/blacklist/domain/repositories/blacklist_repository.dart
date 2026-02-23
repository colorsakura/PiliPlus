import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_result.dart';

/// 黑名单仓库接口
///
/// 定义黑名单相关的数据操作抽象
abstract interface class BlacklistRepository {
  /// 获取黑名单列表
  ///
  /// [pn] 页码
  /// [ps] 每页数量
  Future<BlacklistResultEntity> getBlacklist({
    required int pn,
    required int ps,
  });

  /// 从黑名单移除用户
  ///
  /// [mid] 用户ID
  Future<bool> removeFromBlacklist({
    required int mid,
  });
}
