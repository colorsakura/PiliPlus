import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';

/// 导航配置实体
class NavigationConfig {
  /// 导航栏项目列表
  final List<NavigationBarType> navigationBars;

  /// 当前选中的索引
  final int selectedIndex;

  /// 是否隐藏底部导航栏
  final bool hideBottomBar;

  /// 底部导航栏隐藏类型
  final BarHideType barHideType;

  /// 是否使用底部导航（移动端）
  final bool useBottomNav;

  /// 默认首页索引
  final int defaultHomePageIndex;

  const NavigationConfig({
    required this.navigationBars,
    required this.selectedIndex,
    required this.hideBottomBar,
    required this.barHideType,
    required this.useBottomNav,
    required this.defaultHomePageIndex,
  });

  /// 是否包含首页
  bool get hasHome => navigationBars.contains(NavigationBarType.home);

  /// 是否包含动态页
  bool get hasDyn => navigationBars.contains(NavigationBarType.dynamics);

  /// 是否包含我的页面
  bool get hasMine => navigationBars.contains(NavigationBarType.mine);

  /// 获取当前导航类型
  NavigationBarType get currentNav =>
      navigationBars.isNotEmpty && selectedIndex < navigationBars.length
          ? navigationBars[selectedIndex]
          : NavigationBarType.home;

  NavigationConfig copyWith({
    List<NavigationBarType>? navigationBars,
    int? selectedIndex,
    bool? hideBottomBar,
    BarHideType? barHideType,
    bool? useBottomNav,
    int? defaultHomePageIndex,
  }) {
    return NavigationConfig(
      navigationBars: navigationBars ?? this.navigationBars,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      hideBottomBar: hideBottomBar ?? this.hideBottomBar,
      barHideType: barHideType ?? this.barHideType,
      useBottomNav: useBottomNav ?? this.useBottomNav,
      defaultHomePageIndex: defaultHomePageIndex ?? this.defaultHomePageIndex,
    );
  }
}
