import 'package:PiliPlus/features/shell/domain/entities/navigation_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_controller.g.dart';

/// 导航控制器
///
/// 管理导航选中状态的简化控制器
@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() => const NavigationState();

  /// 更新选中的导航索引
  void updateIndex(int index) {
    // 验证索引范围（0-2，对应三个固定导航项）
    if (index >= 0 && index < 3) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// 重置到首页
  void reset() {
    state = const NavigationState(selectedIndex: 0);
  }
}
