import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/domain/repositories/message_repository.dart';

/// 检查未读消息用例
class CheckUnreadMessagesUseCase {
  final MessageRepository _repository;

  // 检查周期：5分钟
  static const int checkPeriod = 5 * 60 * 1000;

  const CheckUnreadMessagesUseCase(this._repository);

  /// 获取未读消息
  Future<UnreadMessage> getUnreadMessage() => _repository.getUnreadMessage();

  /// 检查是否需要更新未读消息
  Future<UnreadMessage?> checkUnread(int lastCheckTime) async {
    final shouldCheck = await _repository.shouldCheckUnread(
      lastCheckTime,
      checkPeriod,
    );

    if (shouldCheck) {
      return getUnreadMessage();
    }
    return null;
  }
}
