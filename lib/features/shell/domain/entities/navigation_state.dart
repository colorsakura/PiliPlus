/// 导航状态
///
/// 管理导航栏选中状态
class NavigationState {
  /// 当前选中的索引
  final int selectedIndex;

  const NavigationState({this.selectedIndex = 0});

  NavigationState copyWith({int? selectedIndex}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
