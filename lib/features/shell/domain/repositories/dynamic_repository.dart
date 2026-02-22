import 'package:PiliPlus/features/shell/domain/entities/unread_dynamic.dart';

/// 动态仓库接口
abstract interface class DynamicRepository {
  /// 获取未读动态数量
  Future<UnreadDynamic> getUnreadDynamic();

  /// 检查是否需要更新未读动态
  /// 返回 true 表示需要更新
  Future<bool> shouldCheckUnread(int lastCheckTime, int period);
}
