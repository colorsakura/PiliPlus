import 'package:PiliPlus/features/shell/domain/entities/unread_dynamic.dart';
import 'package:PiliPlus/features/shell/domain/repositories/dynamic_repository.dart';

/// 检查未读动态用例
class CheckUnreadDynamicsUseCase {
  final DynamicRepository _repository;

  const CheckUnreadDynamicsUseCase(this._repository);

  /// 获取未读动态
  Future<UnreadDynamic> getUnreadDynamic() => _repository.getUnreadDynamic();

  /// 检查是否需要更新未读动态
  /// [checkDynamic] 是否启用动态检查
  /// [dynamicPeriod] 检查周期（毫秒）
  Future<UnreadDynamic?> checkUnread({
    required bool checkDynamic,
    required int dynamicPeriod,
    required int lastCheckTime,
  }) async {
    if (!checkDynamic) {
      return null;
    }

    final shouldCheck = await _repository.shouldCheckUnread(
      lastCheckTime,
      dynamicPeriod,
    );

    if (shouldCheck) {
      return getUnreadDynamic();
    }
    return null;
  }
}
