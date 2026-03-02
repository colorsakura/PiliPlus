import 'package:PiliPlus/features/home/data/datasources/home_tab_local_datasource.dart';
import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/domain/usecases/get_home_tab_config.dart';
import 'package:PiliPlus/features/home/presentation/providers/home_providers.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页标签配置状态
class HomeTabConfigState {
  final HomeTabConfig? config;
  final bool isLoading;
  final String? errorMessage;

  const HomeTabConfigState({
    this.config,
    this.isLoading = false,
    this.errorMessage,
  });

  HomeTabConfigState copyWith({
    HomeTabConfig? config,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeTabConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 首页标签配置 Controller
class HomeTabConfigController extends Notifier<HomeTabConfigState> {
  late final GetHomeTabConfigUseCase _useCase;
  late final HomeTabLocalDataSource _localDataSource;

  @override
  HomeTabConfigState build() {
    _useCase = ref.read(getHomeTabConfigUseCaseProvider);
    _localDataSource = ref.read(homeTabLocalDataSourceProvider);

    // 同步获取初始配置
    final config = _loadConfigSync();
    return HomeTabConfigState(config: config);
  }

  /// 同步加载配置（用于初始化）
  HomeTabConfig _loadConfigSync() {
    try {
      // 这里我们直接从本地数据源读取，因为初始化时需要同步返回
      final tabs = _localDataSource.getTabSort();
      final hideTopBar = _localDataSource.getHideTopBar();
      final enableSearchWord = _localDataSource.getEnableSearchWord();

      // 找到推荐页的索引作为默认选中项
      final rcmdIndex = tabs.indexOf(HomeTabType.rcmd);
      final selectedIndex = rcmdIndex >= 0 ? rcmdIndex : 0;

      return HomeTabConfig(
        tabs: tabs,
        selectedIndex: selectedIndex,
        hideTopBar: hideTopBar,
        enableSearchWord: enableSearchWord,
        defaultSearch: '',
        lastCheckSearchAt: 0,
      );
    } catch (e) {
      // 如果出错，返回默认配置
      return HomeTabConfig.defaultConfig();
    }
  }

  /// 刷新配置（异步）
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await _useCase();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 更新选中的索引
  void updateIndex(int index) {
    final current = state.config;
    if (current != null) {
      state = state.copyWith(
        config: current.copyWith(selectedIndex: index),
      );
    }
  }

  /// 更新默认搜索词
  void updateDefaultSearch(String search) {
    final current = state.config;
    if (current != null) {
      state = state.copyWith(
        config: current.copyWith(defaultSearch: search),
      );
    }
  }

  /// 更新上次检查搜索词时间戳
  void updateLastCheckSearchAt(int timestamp) {
    final current = state.config;
    if (current != null) {
      state = state.copyWith(
        config: current.copyWith(lastCheckSearchAt: timestamp),
      );
    }
  }
}

/// 首页标签配置 Provider
final homeTabConfigControllerProvider =
    NotifierProvider<HomeTabConfigController, HomeTabConfigState>(
      HomeTabConfigController.new,
    );
