import 'dart:io';

import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/services/app_initializer/app_initializer.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/features/shell/presentation/providers/refresh_provider.dart';
import 'package:PiliPlus/features/shell/presentation/providers/shell_providers.dart';
import 'package:PiliPlus/features/shell/presentation/providers/unread_provider.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/bottom_nav_bar.dart';
import 'package:PiliPlus/features/shell/presentation/widgets/side_nav_bar.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// Shell 页面 - 应用主框架
class ShellPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ShellPage({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage>
    with RouteAware, WidgetsBindingObserver {
  // 存储相关
  late EdgeInsets _padding;

  // 固定的导航选项
  static const List<NavigationBarType> _navigationItems = [
    NavigationBarType.home,
    NavigationBarType.dynamics,
    NavigationBarType.mine,
  ];

  // 配置
  late final bool directExitOnBack = Pref.directExitOnBack;

  @override
  void initState() {
    super.initState();

    // 初始化其他功能
    _initializeApp();

    // 延迟启动定时检查，避免在 widget 构建期间修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePeriodicCheck();
    });
  }

  /// 初始化应用级功能
  void _initializeApp() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 启动定时检查调度器
  Future<void> _initializePeriodicCheck() async {
    // 等待核心阶段完成（DatabaseManager 等核心服务）
    await AppInitializer.ensureCoreReady();

    // 启动定时检查
    ref.read(periodicCheckSchedulerProvider).start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _padding = MediaQuery.viewPaddingOf(context);
    final brightness = Theme.brightnessOf(context);
    NetworkImgLayer.reduce =
        NetworkImgLayer.reduceLuxColor != null && brightness.isDark;
    PageUtils.routeObserver.subscribe(
      this,
      ModalRoute.of(context) as PageRoute,
    );
  }

  @override
  void didPopNext() {
    WidgetsBinding.instance.addObserver(this);
    super.didPopNext();
  }

  @override
  void didPushNext() {
    WidgetsBinding.instance.removeObserver(this);
    super.didPushNext();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 定时检查由 PeriodicCheckScheduler 处理，无需额外操作
  }

  @override
  void dispose() {
    // 停止定时检查调度器
    ref.read(periodicCheckSchedulerProvider).stop();

    // 清理路由和生命周期监听器
    PageUtils.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    // 清理其他资源
    PiliScheme.listener?.cancel();

    super.dispose();
  }

  // ========== 导航处理 ==========

  /// 处理系统返回键（Android）
  void _onBack() {
    if (Platform.isAndroid) {
      Utils.channel.invokeMethod('back');
    }
  }

  /// 处理系统返回键
  void _handlePop() {
    final currentIndex = widget.navigationShell.currentIndex;

    if (currentIndex != 0) {
      // 返回到首页
      widget.navigationShell.goBranch(0);
      ref.read(navigationProvider.notifier).updateIndex(0);
      // TODO: setSearchBar
    } else {
      _onBack();
    }
  }

  /// 处理导航栏点击
  void _handleNavTap(int index) {
    feedBack();

    // 验证索引范围
    if (index < 0 || index >= _navigationItems.length) return;

    final currentIndex = widget.navigationShell.currentIndex;
    final currentNav = _navigationItems[index];

    if (index != currentIndex) {
      // 切换到新分支
      widget.navigationShell.goBranch(index);
      ref.read(navigationProvider.notifier).updateIndex(index);

      // 根据页面类型执行特定操作
      if (currentNav == NavigationBarType.dynamics) {
        ref.read(unreadDynamicControllerProvider.notifier).clear();
      }
    } else {
      // 双击同页面：触发刷新
      ref.read(refreshTriggerProvider.notifier).trigger(index);
    }
  }

  // ========== UI 构建 ==========

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 监听导航状态
    final selectedIndex = ref.watch(navigationProvider).selectedIndex;
    final unreadDyn = ref.watch(unreadDynamicControllerProvider);

    // 创建固定的导航配置（临时方案，待 widget 重构后移除）
    final config = NavigationConfig(
      navigationBars: _navigationItems,
      selectedIndex: selectedIndex,
      hideBottomBar: false,
      barHideType: BarHideType.instant,
      useBottomNav: MediaQuery.sizeOf(context).isPortrait,
      defaultHomePageIndex: 0,
    );

    // 根据当前屏幕尺寸判断是否使用底部导航
    final useBottomNav = MediaQuery.sizeOf(context).isPortrait;

    // 读取侧边栏需要的数据
    final dynamicBadgeMode = Pref.dynamicBadgeMode;
    final unreadMsg = ref.watch(unreadMessageControllerProvider);
    final msgBadgeMode = Pref.msgBadgeMode;

    Widget child = widget.navigationShell; // 使用 StatefulNavigationShell

    Widget? bottomNav;
    // 只有在竖屏模式且有至少2个导航项时才使用底部导航栏
    final shouldUseBottomNav =
        useBottomNav && config.navigationBars.length >= 2;
    if (shouldUseBottomNav) {
      bottomNav = ShellBottomNavigationBar(
        config: config,
        dynCount: unreadDyn.count,
        onDestinationSelected: _handleNavTap,
      );
      child = Row(children: [Expanded(child: child)]);
    } else if (config.navigationBars.isNotEmpty) {
      // 只有在有导航项时才显示侧边栏
      child = Row(
        children: [
          SideNavBar(
            config: config,
            dynCount: unreadDyn.count,
            dynamicBadgeMode: dynamicBadgeMode,
            unreadMessage: unreadMsg,
            msgBadgeMode: msgBadgeMode,
            theme: theme,
            onDestinationSelected: _handleNavTap,
            onSearchPressed: () => PageUtils.goNamed(AppRoutes.search),
            onMessagePressed: () => PageUtils.goNamed(AppRoutes.whisper),
            onUserTap: () => widget.navigationShell.goBranch(2),
            isLogin: Get.find<AccountService>().isLogin.value,
            faceUrl: Get.find<AccountService>().face.value,
          ),
          Expanded(child: child),
        ],
      );
    }

    child = Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.only(
          left: PlatformUtils.isDesktop ? 0 : _padding.left.clamp(0.0, double.infinity),
          right: _padding.right.clamp(0.0, double.infinity),
          bottom: shouldUseBottomNav ? 0.0 : _padding.bottom.clamp(0.0, double.infinity),
        ),
        child: child,
      ),
      bottomNavigationBar: bottomNav,
    );

    if (PlatformUtils.isMobile) {
      child = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: theme.brightness.reverse,
        ),
        child: child,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handlePop();
        }
      },
      child: child,
    );
  }
}
