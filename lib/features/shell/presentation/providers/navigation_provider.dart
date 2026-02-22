import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/domain/entities/navigation_state.dart';
import 'package:PiliPlus/features/shell/domain/usecases/get_navigation_config.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 导航配置状态
class NavigationConfigState {
  final NavigationConfig? config;
  final bool isLoading;
  final String? errorMessage;

  const NavigationConfigState({
    this.config,
    this.isLoading = false,
    this.errorMessage,
  });

  NavigationConfigState copyWith({
    NavigationConfig? config,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NavigationConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 导航配置 Controller (使用 Riverpod 3.x 的 Notifier)
class NavigationConfigController extends Notifier<NavigationConfigState> {
  GetNavigationConfigUseCase? _useCase;

  void setUseCase(GetNavigationConfigUseCase useCase) {
    _useCase = useCase;
  }

  @override
  NavigationConfigState build() {
    return const NavigationConfigState(
      config: NavigationConfig(
        navigationBars: [],
        selectedIndex: 0,
        hideBottomBar: false,
        barHideType: BarHideType.instant,
        useBottomNav: false,
        defaultHomePageIndex: 0,
      ),
    );
  }

  Future<void> initialize() async {
    if (_useCase == null) {
      return;
    }
    state = state.copyWith(isLoading: true);
    try {
      final config = await _useCase!();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 更新选中的索引
  Future<void> updateIndex(int index) async {
    final current = state.config;
    if (current != null) {
      state = state.copyWith(
        config: current.copyWith(selectedIndex: index),
      );
      // 保存到本地存储
      await _useCase?.updateDefaultIndex(index);
    }
  }

  /// 更新使用底部导航
  void updateUseBottomNav(bool useBottomNav) {
    final current = state.config;
    if (current != null) {
      state = state.copyWith(
        config: current.copyWith(useBottomNav: useBottomNav),
      );
    }
  }

  /// 刷新配置
  Future<void> refresh() async {
    await initialize();
  }
}

/// 导航配置 Provider
final navigationConfigControllerProvider =
    NotifierProvider<NavigationConfigController, NavigationConfigState>(
  NavigationConfigController.new,
);

/// 导航状态（滚动偏移等）
class NavigationStateController extends Notifier<NavigationState> {
  @override
  NavigationState build() {
    return const NavigationState();
  }

  /// 更新滚动偏移
  void updateBarOffset(double offset) {
    state = state.copyWith(barOffset: offset);
  }

  /// 更新显示底部导航栏
  void updateShowBottomBar(bool show) {
    state = state.copyWith(showBottomBar: show);
  }

  /// 重置状态
  void reset() {
    state = const NavigationState();
  }
}

/// 导航状态 Provider
final navigationStateControllerProvider =
    NotifierProvider<NavigationStateController, NavigationState>(
  NavigationStateController.new,
);

/// 动态角标模式
final dynamicBadgeModeProvider = Provider<DynamicBadgeMode>((ref) {
  return Pref.dynamicBadgeMode;
});

/// 消息角标模式
final msgBadgeModeProvider = Provider<DynamicBadgeMode>((ref) {
  return Pref.msgBadgeMode;
});

/// 是否检查动态
final checkDynamicProvider = Provider<bool>((ref) {
  return Pref.checkDynamic;
});

/// 动态检查周期（毫秒）
final dynamicPeriodProvider = Provider<int>((ref) {
  return Pref.dynamicPeriod * 60 * 1000;
});

/// 是否直接退出
final directExitOnBackProvider = Provider<bool>((ref) {
  return Pref.directExitOnBack;
});
