import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:flutter/material.dart';

/// 导航图标构建器
///
/// 根据导航类型和选中状态构建图标，为动态页面显示未读角标
class NavIconBuilder extends StatelessWidget {
  const NavIconBuilder({
    super.key,
    required this.type,
    this.selected = false,
    required this.dynCount,
  });

  final NavigationBarType type;
  final bool selected;
  final int dynCount;

  @override
  Widget build(BuildContext context) {
    final icon = selected ? type.selectIcon : type.icon;

    // 动态页面显示角标
    if (type == NavigationBarType.dynamics) {
      return Badge(
        isLabelVisible: dynCount > 0,
        label: Text(dynCount.toString()),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: icon,
      );
    }

    return icon;
  }
}
