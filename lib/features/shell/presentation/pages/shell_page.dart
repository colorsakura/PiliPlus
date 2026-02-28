import 'dart:io';

import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/shell/controller.dart' show MainController;
import 'package:PiliPlus/features/shell/domain/entities/navigation_config.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/features/shell/presentation/providers/shell_providers.dart';
import 'package:PiliPlus/features/shell/presentation/providers/unread_provider.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/image_type.dart';
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

/// Shell 页面 - 应用主框架
class ShellPage extends ConsumerStatefulWidget {
  const ShellPage({super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage>
    with RouteAware, WidgetsBindingObserver {
  // PageController 用于 PageView
  late final PageController _pageController;

  // 存储相关
  late EdgeInsets _padding;

  // 配置
  late final bool directExitOnBack = Pref.directExitOnBack;

  @override
  void initState() {
    super.initState();

    // 临时兼容：注册 MainController 以支持旧的页面
    // 这样 HomePage 可以找到 MainController
    // TODO: 迁移完 HomePage 和 DynamicsPage 后移除
    Get.put(MainController());

    // 初始化 PageController
    final navConfigState = ref.read(navigationConfigControllerProvider);
    final initialIndex = navConfigState.config?.selectedIndex ?? 0;
    _pageController = PageController(initialPage: initialIndex);

    // 初始化其他功能
    _initializeApp();

    // 延迟初始化导航配置，避免在 widget 构建期间修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNavigationConfig();
    });
  }

  /// 初始化应用级功能
  void _initializeApp() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// 初始化导航配置和未读消息检查
  ///
  /// 1. 加载导航配置
  /// 2. 启动定时检查调度器
  Future<void> _initializeNavigationConfig() async {
    // 初始化配置
    await ref.read(navigationConfigControllerProvider.notifier).initialize();

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

    // 临时兼容：清理 MainController
    // TODO: 在迁移完 HomePage 和 DynamicsPage 后删除
    Get.delete<MainController>();

    // 清理路由和生命周期监听器
    PageUtils.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);

    // 清理其他资源
    PiliScheme.listener?.cancel();
    _pageController.dispose();

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
    final navState = ref.read(navigationConfigControllerProvider);
    final selectedIndex = navState.config?.selectedIndex ?? 0;

    if (selectedIndex != 0) {
      // 返回到首页
      ref.read(navigationConfigControllerProvider.notifier).updateIndex(0);
      ref.read(navigationStateControllerProvider.notifier).reset();
      // TODO: setSearchBar
    } else {
      _onBack();
    }
  }

  /// 处理导航栏点击
  void _handleNavTap(int index) {
    feedBack();
    final navState = ref.read(navigationConfigControllerProvider);
    final currentIndex = navState.config?.selectedIndex ?? 0;
    final config = navState.config;

    if (config == null) return;

    // Validate index bounds
    if (index < 0 || index >= config.navigationBars.length) return;

    final currentNav = config.navigationBars[index];

    if (index != currentIndex) {
      // 切换到新页面
      ref.read(navigationConfigControllerProvider.notifier).updateIndex(index);
      _pageController.jumpToPage(index);

      // 根据页面类型执行特定操作
      if (currentNav == NavigationBarType.home) {
        // TODO: checkDefaultSearch 和 checkUnread
      } else if (currentNav == NavigationBarType.dynamics) {
        ref.read(unreadDynamicControllerProvider.notifier).clear();
      }
    } else {
      // 双击同页面：刷新或滚动到顶部
      // TODO: 实现双击刷新逻辑
    }
  }

  // ========== UI 构建 ==========

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 监听导航配置
    final navConfigState = ref.watch(navigationConfigControllerProvider);
    final unreadDyn = ref.watch(unreadDynamicControllerProvider);

    final config = navConfigState.config;
    if (config == null) {
      // 配置尚未加载，显示加载界面
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 根据当前屏幕尺寸判断是否使用底部导航
    final useBottomNav = MediaQuery.sizeOf(context).isPortrait;

    Widget child = PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: config.navigationBars.map((i) => i.page).toList(),
    );

    Widget? bottomNav;
    // 只有在竖屏模式且有至少2个导航项时才使用底部导航栏
    final shouldUseBottomNav =
        useBottomNav && config.navigationBars.length >= 2;
    if (shouldUseBottomNav) {
      bottomNav = _buildBottomNav(config, unreadDyn.count);
      child = Row(children: [Expanded(child: child)]);
    } else if (config.navigationBars.isNotEmpty) {
      // 只有在有导航项时才显示侧边栏
      child = Row(
        children: [
          _buildSideBar(config, theme, unreadDyn.count),
          Expanded(child: child),
        ],
      );
    }

    child = Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.only(
          left: PlatformUtils.isDesktop ? 0 : _padding.left,
          right: _padding.right,
          bottom: shouldUseBottomNav ? 0.0 : _padding.bottom,
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

  // ========== 导航栏组件 ==========

  /// 构建底部导航栏（移动端竖屏）
  Widget _buildBottomNav(NavigationConfig config, int dynCount) {
    return BottomNavigationBar(
      currentIndex: config.navigationBars.isEmpty
          ? 0
          : config.selectedIndex.clamp(
              0,
              config.navigationBars.length - 1,
            ),
      onTap: _handleNavTap,
      iconSize: 16,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
      items: config.navigationBars
          .map(
            (e) => BottomNavigationBarItem(
              label: e.label,
              icon: _buildIcon(
                type: e,
                dynCount: dynCount,
              ),
              activeIcon: _buildIcon(
                type: e,
                selected: true,
                dynCount: dynCount,
              ),
            ),
          )
          .toList(),
    );
  }

  /// 构建侧边导航栏（桌面端/平板）
  Widget _buildSideBar(NavigationConfig config, ThemeData theme, int dynCount) {
    final dynamicBadgeMode = ref.read(dynamicBadgeModeProvider);

    return Container(
      color: Colors.grey[200],
      child: Column(
        children: [
          const SizedBox(height: 25),
          Expanded(
            flex: 5,
            child: SizedBox(
              width: 60,
              child: NavigationRail(
                backgroundColor: Colors.transparent,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: _handleNavTap,
                selectedIndex: config.navigationBars.isEmpty
                    ? 0
                    : config.selectedIndex.clamp(
                        0,
                        config.navigationBars.length - 1,
                      ),
                destinations: config.navigationBars
                    .map(
                      (e) => NavigationRailDestination(
                        label: Text(e.label),
                        icon: _buildIcon(
                          type: e,
                          dynCount: dynCount,
                        ),
                        selectedIcon: _buildIcon(
                          type: e,
                          selected: true,
                          dynCount: dynCount,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const Spacer(flex: 2),
          _buildUserAndSearchVertical(
            theme,
            dynCount,
            dynamicBadgeMode,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ========== 导航图标 ==========

  /// 构建导航图标
  Widget _buildIcon({
    required NavigationBarType type,
    bool selected = false,
    required int dynCount,
  }) {
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

  // ========== 用户区域组件 ==========

  /// 构建用户头像和搜索按钮（垂直布局）
  ///
  /// 用于侧边导航栏顶部，包含：
  /// - 用户头像（点击跳转到"我的"页面）
  /// - 消息按钮（带未读角标）
  /// - 搜索按钮
  Widget _buildUserAndSearchVertical(
    ThemeData theme,
    int dynCount,
    DynamicBadgeMode dynamicBadgeMode,
  ) {
    final accountService = Get.find<AccountService>();
    final unreadMsg = ref.watch(unreadMessageControllerProvider);
    final msgBadgeMode = ref.read(msgBadgeModeProvider);

    return Column(
      children: [
        IconButton(
          tooltip: '搜索',
          icon: const Icon(
            Icons.search_outlined,
            semanticLabel: '搜索',
          ),
          onPressed: () => Get.toNamed('/search'),
        ),
        _buildMsgBadge(unreadMsg, msgBadgeMode),
        _buildUserAvatar(theme, accountService),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 构建用户头像
  ///
  /// - 已登录：显示用户头像
  /// - 未登录：显示默认图标
  Widget _buildUserAvatar(ThemeData theme, AccountService accountService) {
    return Semantics(
      label: "我的",
      child: GestureDetector(
        onTap: () => Get.toNamed('/mine'),
        child: Obx(
          () {
            if (accountService.isLogin.value) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  NetworkImgLayer(
                    type: ImageType.avatar,
                    width: 34,
                    height: 34,
                    src: accountService.face.value,
                  ),
                  Positioned.fill(
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => Get.toNamed('/mine'),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Icon(
                Icons.person_outline,
                size: 34,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              );
            }
          },
        ),
      ),
    );
  }

  /// 构建消息按钮（带未读角标）
  ///
  /// 角标样式由 `msgBadgeMode` 决定：
  /// - `DynamicBadgeMode.number`: 显示数字
  /// - `DynamicBadgeMode.dot`: 显示圆点
  /// - `DynamicBadgeMode.hidden`: 不显示按钮
  Widget _buildMsgBadge(
    UnreadMessage unreadMsg,
    DynamicBadgeMode msgBadgeMode,
  ) {
    if (!showMsgBadge(msgBadgeMode)) {
      return const SizedBox.shrink();
    }

    return Badge(
      isLabelVisible: unreadMsg.hasUnread,
      label:
          msgBadgeMode == DynamicBadgeMode.number &&
              unreadMsg.displayText.isNotEmpty
          ? Text(unreadMsg.displayText)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: IconButton(
        tooltip: '消息',
        icon: const Icon(
          Icons.notifications_none,
          semanticLabel: '消息',
        ),
        onPressed: () => Get.toNamed('/whisper'),
      ),
    );
  }
}
