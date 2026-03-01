import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/nav_icon_builder.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/user_section.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:flutter/material.dart';

/// 侧边导航栏
///
/// 用于桌面端/平板横屏模式，显示侧边导航项和用户区域
class SideNavBar extends StatelessWidget {
  const SideNavBar({
    super.key,
    required this.config,
    required this.dynCount,
    required this.dynamicBadgeMode,
    required this.unreadMessage,
    required this.msgBadgeMode,
    required this.theme,
    required this.onDestinationSelected,
    required this.onSearchPressed,
    required this.onMessagePressed,
    required this.onUserTap,
    required this.isLogin,
    this.faceUrl,
  });

  final NavigationConfig config;
  final int dynCount;
  final DynamicBadgeMode dynamicBadgeMode;
  final UnreadMessage unreadMessage;
  final DynamicBadgeMode msgBadgeMode;
  final ThemeData theme;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSearchPressed;
  final VoidCallback onMessagePressed;
  final VoidCallback onUserTap;
  final bool isLogin;
  final String? faceUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const SizedBox(height: 25),
          Expanded(
            flex: 5,
            child: SizedBox(
              width: 60,
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: onDestinationSelected,
                selectedIndex: config.navigationBars.isEmpty
                    ? 0
                    : config.selectedIndex.clamp(
                        0,
                        config.navigationBars.length - 1,
                      ),
                destinations: config.navigationBars
                    .map(
                      (e) => NavigationRailDestination(
                        label: Text(e.label),
                        icon: NavIconBuilder(
                          type: e,
                          dynCount: dynCount,
                        ),
                        selectedIcon: NavIconBuilder(
                          type: e,
                          selected: true,
                          dynCount: dynCount,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Spacer(flex: 2),
          UserSection(
            unreadMessage: unreadMessage,
            msgBadgeMode: msgBadgeMode,
            onSearchPressed: onSearchPressed,
            onMessagePressed: onMessagePressed,
            onUserTap: onUserTap,
            isLogin: isLogin,
            faceUrl: faceUrl,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
