import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/nav_icon_builder.dart';
import 'package:flutter/material.dart';

/// 底部导航栏
///
/// 用于移动端竖屏模式，显示底部导航项
class ShellBottomNavigationBar extends StatelessWidget {
  const ShellBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.dynCount,
    required this.onDestinationSelected,
  });

  final List<NavigationBarType> items;
  final int selectedIndex;
  final int dynCount;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onDestinationSelected,
      iconSize: 16,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: items
          .map(
            (e) => BottomNavigationBarItem(
              label: e.label,
              icon: NavIconBuilder(
                type: e,
                dynCount: dynCount,
              ),
              activeIcon: NavIconBuilder(
                type: e,
                selected: true,
                dynCount: dynCount,
              ),
            ),
          )
          .toList(),
    );
  }
}
