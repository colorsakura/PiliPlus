import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/features/shell/presentation/providers/unread_provider.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/page_utils.dart';

/// 消息角标 Widget
///
/// 用于显示未读消息数量，支持数字和点两种显示模式
class MessageBadge extends ConsumerWidget {
  const MessageBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msgBadgeMode = ref.read(msgBadgeModeProvider);

    final unreadMessage = ref.watch(unreadMessageControllerProvider);
    final isNumBadge = msgBadgeMode == DynamicBadgeMode.number;

    if (!unreadMessage.hasUnread) {
      return const SizedBox.shrink();
    }

    return IconButton(
      tooltip: '消息',
      onPressed: () {
        ref.read(unreadMessageControllerProvider.notifier).clear();
        ref.read(unreadMessageControllerProvider.notifier).resetCheckTime();
        PageUtils.pushNamed(AppRoutes.whisper);
      },
      icon: Badge(
        isLabelVisible:
            msgBadgeMode != DynamicBadgeMode.hidden && unreadMessage.hasUnread,
        alignment: isNumBadge
            ? const Alignment(0.0, -0.85)
            : const Alignment(1.0, -0.85),
        label: isNumBadge && unreadMessage.hasUnread
            ? Text(unreadMessage.displayText)
            : null,
        child: const Icon(Icons.notifications_none),
      ),
    );
  }
}
