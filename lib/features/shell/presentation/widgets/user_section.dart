import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_avatar_button.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/message_badge_button.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter/material.dart';

/// 用户区域组合组件
///
/// 垂直排列搜索、消息、头像三个组件
class UserSection extends StatelessWidget {
  const UserSection({
    super.key,
    required this.unreadMessage,
    required this.msgBadgeMode,
    required this.onSearchPressed,
    required this.onMessagePressed,
    required this.onUserTap,
    required this.isLogin,
    this.faceUrl,
  });

  final UnreadMessage unreadMessage;
  final DynamicBadgeMode msgBadgeMode;
  final VoidCallback onSearchPressed;
  final VoidCallback onMessagePressed;
  final VoidCallback onUserTap;
  final bool isLogin;
  final String? faceUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: '搜索',
          icon: const Icon(
            Icons.search_outlined,
            semanticLabel: '搜索',
          ),
          onPressed: onSearchPressed,
        ),
        MessageBadgeButton(
          unreadMessage: unreadMessage,
          badgeMode: msgBadgeMode,
          onPressed: onMessagePressed,
        ),
        UserAvatarButton(
          isLogin: isLogin,
          faceUrl: faceUrl,
          onTap: onUserTap,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
