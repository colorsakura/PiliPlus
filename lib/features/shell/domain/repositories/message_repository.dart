import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';

/// 消息仓库接口
abstract interface class MessageRepository {
  /// 获取未读消息数量
  Future<UnreadMessage> getUnreadMessage();

  /// 获取私信未读数
  Future<int> getMsgUnread();

  /// 获取 Feed 消息未读数
  Future<int> getMsgFeedUnread();

  /// 检查是否需要更新未读消息
  /// 返回 true 表示需要更新
  Future<bool> shouldCheckUnread(int lastCheckTime, int period);
}
