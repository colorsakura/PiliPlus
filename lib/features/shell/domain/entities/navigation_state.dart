/// 导航状态实体
class NavigationState {
  /// 页面滚动偏移量（用于隐藏底部导航栏）
  final double barOffset;

  /// 是否显示底部导航栏（用于即时隐藏模式）
  final bool showBottomBar;

  const NavigationState({
    this.barOffset = 0.0,
    this.showBottomBar = true,
  });

  NavigationState copyWith({
    double? barOffset,
    bool? showBottomBar,
  }) {
    return NavigationState(
      barOffset: barOffset ?? this.barOffset,
      showBottomBar: showBottomBar ?? this.showBottomBar,
    );
  }
}
