import 'package:PiliPlus/shared/widgets/custom_height_widget.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/home/domain/entities/home_tab_config.dart';
import 'package:PiliPlus/features/home/presentation/providers/search_controller.dart';
import 'package:PiliPlus/features/shell/controller.dart';
import 'package:PiliPlus/features/shell/presentation/providers/navigation_provider.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/features/mine/presentation/pages/mine_controller.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// 首页顶部栏
///
/// 包含：
/// - 用户头像
/// - 搜索框
/// - 消息按钮（带未读角标）
class HomeAppBar extends ConsumerWidget {
  final HomeTabConfig config;

  const HomeAppBar({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navConfigState = ref.watch(navigationConfigControllerProvider);
    final navState = ref.watch(navigationStateControllerProvider);
    final navConfig = navConfigState.config;

    const padding = EdgeInsets.fromLTRB(14, 6, 14, 0);
    final child = Row(
      spacing: 8,
      children: [
        const UserAvatar(),
        Expanded(child: SearchBar(config: config)),
        const MsgBadge(),
      ],
    );

    // 应用顶部栏隐藏效果
    if (config.hideTopBar && navConfig != null) {
      if (navState.barOffset > 0) {
        return _buildOffsetAppBar(padding, child, navState.barOffset);
      }
      if (navConfig.barHideType == BarHideType.instant) {
        return _buildAnimatedAppBar(padding, child);
      }
    }

    return Container(
      height: StyleString.topBarHeight,
      padding: padding,
      child: child,
    );
  }

  /// 构建带偏移的顶部栏
  Widget _buildOffsetAppBar(EdgeInsets padding, Widget child, double offset) {
    return CustomHeightWidget(
      offset: Offset(0, -offset),
      height: StyleString.topBarHeight - offset,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }

  /// 构建带动画的顶部栏
  Widget _buildAnimatedAppBar(EdgeInsets padding, Widget child) {
    return Consumer(
      builder: (context, ref, _) {
        final navState = ref.watch(navigationStateControllerProvider);

        return AnimatedContainer(
          curve: Curves.easeInOutCubicEmphasized,
          duration: const Duration(milliseconds: 500),
          height: navState.barOffset > 0
              ? StyleString.topBarHeight - navState.barOffset
              : StyleString.topBarHeight,
          padding: padding,
          child: child,
        );
      },
    );
  }
}

/// 用户头像
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mainController = Get.find<MainController>();

    return Semantics(
      label: "我的",
      child: GestureDetector(
        onTap: mainController.toMinePage,
        child: Obx(
          () {
            final accountService = Get.find<AccountService>();
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
                        onTap: mainController.toMinePage,
                        splashColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        customBorder: const CircleBorder(),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Obx(
                      () => MineController.anonymity?.value ?? false
                          ? IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.secondaryContainer,
                                ),
                                child: Icon(
                                  size: 14,
                                  MdiIcons.incognito,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            }
            return SizedBox(
              width: 38,
              height: 38,
              child: IconButton(
                tooltip: '点击登录',
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: theme.colorScheme.onInverseSurface,
                ),
                onPressed: mainController.toMinePage,
                icon: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 搜索框
class SearchBar extends ConsumerWidget {
  final HomeTabConfig config;

  const SearchBar({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchState = ref.watch(searchSuggestionControllerProvider);

    const borderRadius = BorderRadius.all(Radius.circular(25));
    return SizedBox(
      height: 44,
      child: Material(
        borderRadius: borderRadius,
        color: theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.05),
        child: InkWell(
          borderRadius: borderRadius,
          splashColor: theme.colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
          onTap: () => Get.toNamed(
            '/search',
            parameters:
                config.enableSearchWord && searchState.defaultSearch.isNotEmpty
                ? {'hintText': searchState.defaultSearch}
                : null,
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(
                Icons.search_outlined,
                color: theme.colorScheme.onSecondaryContainer,
                semanticLabel: '搜索',
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  searchState.defaultSearch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}

/// 消息角标
class MsgBadge extends ConsumerWidget {
  const MsgBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainController = Get.find<MainController>();
    final accountService = Get.find<AccountService>();
    final msgBadgeMode = ref.read(msgBadgeModeProvider);

    return Obx(
      () {
        if (!accountService.isLogin.value) {
          return const SizedBox.shrink();
        }

        final count = mainController.msgUnReadCount.value;
        final isNumBadge = msgBadgeMode == DynamicBadgeMode.number;

        return IconButton(
          tooltip: '消息',
          onPressed: () {
            mainController.msgUnReadCount.value = '';
            mainController.lastCheckUnreadAt =
                DateTime.now().millisecondsSinceEpoch;
            Get.toNamed('/whisper');
          },
          icon: Badge(
            isLabelVisible:
                msgBadgeMode != DynamicBadgeMode.hidden && count.isNotEmpty,
            alignment: isNumBadge
                ? const Alignment(0.0, -0.85)
                : const Alignment(1.0, -0.85),
            label: isNumBadge && count.isNotEmpty ? Text(count) : null,
            child: const Icon(Icons.notifications_none),
          ),
        );
      },
    );
  }
}
