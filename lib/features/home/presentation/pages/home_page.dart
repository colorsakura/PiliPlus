import 'dart:math';

import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/presentation/providers/home_tab_controller.dart';
import 'package:PiliPlus/features/home/presentation/widgets/home_app_bar.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/features/shell/presentation/providers/refresh_provider.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _controllerInitialized = false;
  int _lastTabLength = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeControllerIfNeeded();
  }

  void _initializeControllerIfNeeded() {
    if (_controllerInitialized) return;

    final tabConfigState = ref.read(homeTabConfigControllerProvider);
    final config = tabConfigState.config ?? HomeTabConfig.defaultConfig();

    _createController(config);
    _controllerInitialized = true;
    _lastTabLength = config.tabs.length;
  }

  void _createController(HomeTabConfig config) {
    // 如果配置已加载，初始化 TabController
    if (config.hasMultipleTabs) {
      final initialIndex = max(0, config.rcmdIndex);
      _tabController = TabController(
        initialIndex: initialIndex,
        length: config.tabs.length,
        vsync: this,
      );
    } else {
      // 单个标签时的默认 controller
      _tabController = TabController(
        initialIndex: 0,
        length: 1,
        vsync: this,
      );
    }
  }

  void _updateController(HomeTabConfig config) {
    _tabController.dispose();
    _createController(config);
  }

  @override
  void dispose() {
    if (_controllerInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 监听刷新触发器（branchIndex 0 = home）
    ref.listen(refreshTriggerProvider, (previous, next) {
      if (next == 0) {
        _scrollToTop();
      }
    });

    // 监听首页标签配置
    final tabConfigState = ref.watch(homeTabConfigControllerProvider);
    final config = tabConfigState.config;

    // 如果配置尚未加载或为空，返回默认配置
    final safeConfig = config ?? HomeTabConfig.defaultConfig();

    // 如果 tabs 长度发生变化，重新创建 TabController
    if (_controllerInitialized && _lastTabLength != safeConfig.tabs.length) {
      _updateController(safeConfig);
    }
    _lastTabLength = safeConfig.tabs.length;

    // 构建 TabBar
    Widget tabBar;
    if (safeConfig.hasMultipleTabs) {
      tabBar = _buildTabBar(safeConfig, theme);
    } else {
      tabBar = const SizedBox(height: 6);
    }

    return Scaffold(
      body: Column(
        children: [
          if (MediaQuery.sizeOf(context).isPortrait)
            HomeAppBar(config: safeConfig),
          tabBar,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: safeConfig.tabs.map((e) => e.page).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 TabBar
  Widget _buildTabBar(HomeTabConfig config, ThemeData theme) {
    final navConfigState = ref.watch(navigationConfigControllerProvider);
    final navConfig = navConfigState.config;

    // 检查是否需要应用顶部栏隐藏效果
    final hideTopBar = config.hideTopBar;
    Widget tabBarWidget = Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SizedBox(
        height: 42,
        width: double.infinity,
        child: TabBar(
          controller: _tabController,
          tabs: config.tabs.map((e) => Tab(text: e.label)).toList(),
          isScrollable: true,
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          splashBorderRadius: StyleString.mdRadius,
          tabAlignment: TabAlignment.center,
          onTap: (index) {
            feedBack();
            if (!_tabController.indexIsChanging) {
              _handleTabTap(index);
            }
          },
        ),
      ),
    );

    // 应用顶部栏隐藏效果
    if (hideTopBar && navConfig != null) {
      if (navConfig.barHideType == BarHideType.instant) {
        tabBarWidget = Material(
          color: theme.colorScheme.surface,
          child: tabBarWidget,
        );
      }
    }

    return tabBarWidget;
  }

  /// 处理标签点击
  void _handleTabTap(int index) {
    ref.read(homeTabConfigControllerProvider.notifier).updateIndex(index);
    // TODO: 滚动到顶部
  }

  /// 滚动到顶部（双击刷新时触发）
  void _scrollToTop() {
    // TODO: Implement scroll to top for current tab
    // This should notify the current tab page to scroll to top
  }
}
