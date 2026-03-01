import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter/material.dart';

/// 消息角标按钮
///
/// 显示消息图标和未读角标，支持数字/圆点/隐藏模式
class MessageBadgeButton extends StatelessWidget {
  const MessageBadgeButton({
    super.key,
    required this.unreadMessage,
    required this.badgeMode,
    required this.onPressed,
  });

  final UnreadMessage unreadMessage;
  final DynamicBadgeMode badgeMode;
  final VoidCallback onPressed;

  /// 判断是否显示消息角标按钮
  static bool showMsgBadge(DynamicBadgeMode mode) {
    return mode != DynamicBadgeMode.hidden;
  }

  @override
  Widget build(BuildContext context) {
    if (!showMsgBadge(badgeMode)) {
      return const SizedBox.shrink();
    }

    return Badge(
      isLabelVisible: unreadMessage.hasUnread,
      label: badgeMode == DynamicBadgeMode.number &&
              unreadMessage.displayText.isNotEmpty
          ? Text(unreadMessage.displayText)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton(
        tooltip: '消息',
        icon: const Icon(
          Icons.notifications_none,
          semanticLabel: '消息',
        ),
        onPressed: onPressed,
      ),
    );
  }
}
