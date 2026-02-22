import 'dart:math';

import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/presentation/providers/home_tab_controller.dart';
import 'package:PiliPlus/features/home/presentation/widgets/home_app_bar.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 首页 - 主页面
///
/// ## 架构
///
/// 本页面采用**干净架构（Clean Architecture）** + **Riverpod** 状态管理：
///
/// - **Presentation Layer**: 本页面作为 UI 入口，使用 `ConsumerStatefulWidget` 监听状态变化
/// - **Domain Layer**: 通过 Use Cases 执行业务逻辑
/// - **Data Layer**: 通过 Repositories 获取数据
///
/// ## 使用的 Providers
///
/// - `homeTabConfigControllerProvider`: 首页标签配置状态
/// - `searchSuggestionControllerProvider`: 搜索建议状态
/// - `navigationConfigControllerProvider`: 导航配置（用于顶部栏隐藏）
/// - `navigationStateControllerProvider`: 导航状态（滚动偏移等）
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final TabController _tabController;
  bool _controllerInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeControllerIfNeeded();
  }

  void _initializeControllerIfNeeded() {
    if (_controllerInitialized) return;

    final tabConfigState = ref.read(homeTabConfigControllerProvider);
    final config = tabConfigState.config ?? HomeTabConfig.defaultConfig();

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
    _controllerInitialized = true;
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
    super.build(context);
    final theme = Theme.of(context);

    // 监听首页标签配置
    final tabConfigState = ref.watch(homeTabConfigControllerProvider);
    final config = tabConfigState.config;

    // 如果配置尚未加载或为空，返回默认配置
    final safeConfig = config ?? HomeTabConfig.defaultConfig();

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
}
