import 'package:PiliPlus/shared/widgets/dialog/report_member.dart';
import 'package:PiliPlus/shared/widgets/dynamic_sliver_appbar_medium.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space/data.dart';
import 'package:PiliPlus/features/coin_log/presentation/pages/coin_log_controller.dart'
    show CoinLogController;
import 'package:PiliPlus/features/exp_log/presentation/pages/exp_log_controller.dart'
    show ExpLogController;
import 'package:PiliPlus/features/log_table/log_table.dart';
import 'package:PiliPlus/features/login_devices/login_devices.dart';
import 'package:PiliPlus/features/login_log/login_log.dart';
import 'package:PiliPlus/features/member/presentation/providers/member_controller.dart';
import 'package:PiliPlus/features/member/presentation/providers/member_provider.dart';
import 'package:PiliPlus/features/member/presentation/pages/widget/user_info_card.dart';
import 'package:PiliPlus/features/member_cheese/member_cheese.dart';
import 'package:PiliPlus/features/member_contribute/member_contribute.dart';
import 'package:PiliPlus/features/member_dynamics/member_dynamics.dart';
import 'package:PiliPlus/features/member_favorite/member_favorite.dart';
import 'package:PiliPlus/features/member_home/member_home.dart';
import 'package:PiliPlus/features/member_pgc/presentation/pages/member_pgc_page_v2.dart';
import 'package:PiliPlus/features/member_shop/member_shop.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MemberPage extends ConsumerStatefulWidget {
  const MemberPage({super.key});

  @override
  ConsumerState<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends ConsumerState<MemberPage>
    with SingleTickerProviderStateMixin {
  late final int _mid;
  late final String _heroTag;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _mid = int.tryParse(Get.parameters['mid']!) ?? -1;
    _heroTag = Utils.makeHeroTag(_mid);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromViewAid = Get.parameters['from_view_aid'];
    final controller = ref.watch(
      memberControllerProvider(
        MemberParams(mid: _mid, fromViewAid: fromViewAid),
      ),
    );

    final state = controller.state;
    final tabs = state.tabs;
    final tabCount = tabs?.length ?? 0;

    // Update TabController when tabs change
    if (tabCount > 0 &&
        (_tabController == null || _tabController!.length != tabCount)) {
      _tabController?.dispose();
      _tabController = TabController(
        vsync: this,
        length: tabCount,
        initialIndex: 0,
      );
    }

    final theme = Theme.of(context).colorScheme;
    final padding = MediaQuery.viewPaddingOf(context);

    if (state.isLoading || state.loadingState is Loading) {
      return Material(
        color: theme.surface,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadingState case Error(:final errMsg)) {
      return Material(
        color: theme.surface,
        child: Center(
          child: scrollErrorWidget(
            errMsg: errMsg,
            onReload: controller.onReload,
          ),
        ),
      );
    }

    return Material(
      color: theme.surface,
      child: ExtendedNestedScrollView(
        key: controller.key,
        onlyOneScrollInBody: true,
        pinnedHeaderSliverHeightBuilder: () =>
            kToolbarHeight + MediaQuery.viewPaddingOf(context).top,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildUserInfo(theme, controller),
          ];
        },
        body: (state.tab2?.isNotEmpty == true && tabs != null)
            ? Padding(
                padding: EdgeInsets.only(
                  left: padding.left,
                  right: padding.right,
                ),
                child: Column(
                  children: [
                    if (tabCount > 1)
                      SizedBox(
                        height: 45,
                        child: TabBar(
                          controller: _tabController,
                          tabs: tabs,
                          onTap: controller.onTapTab,
                          dividerColor: theme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                    Expanded(
                      child: _buildBody(controller, state),
                    ),
                  ],
                ),
              )
            : const Center(child: Text('EMPTY')),
      ),
    );
  }

  List<Widget> _actions(ColorScheme theme, MemberController controller) => [
    IconButton(
      tooltip: '搜索',
      onPressed: () => Get.toNamed(
        '/memberSearch?mid=$_mid&uname=${controller.state.username}',
      ),
      icon: const Icon(Icons.search_outlined),
    ),
    PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuEntry>[
        if (controller.account.isLogin && controller.account.mid != _mid) ...[
          PopupMenuItem(
            onTap: () => controller.blockUser(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 19),
                const SizedBox(width: 10),
                Text(
                  controller.state.relation != 128 ? '加入黑名单' : '移除黑名单',
                ),
              ],
            ),
          ),
          if (controller.state.isFollowed == 1)
            PopupMenuItem(
              onTap: controller.onRemoveFan,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove_circle_outline_outlined, size: 19),
                  SizedBox(width: 10),
                  Text('移除粉丝'),
                ],
              ),
            ),
        ],
        PopupMenuItem(
          onTap: controller.shareUser,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_outlined, size: 19),
              const SizedBox(width: 10),
              Text(
                controller.account.mid != _mid ? '分享UP主' : '分享我的主页',
              ),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => Get.toNamed(
            '/upowerRank',
            parameters: {
              'mid': controller.mid.toString(),
            },
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.electric_bolt, size: 19),
              SizedBox(width: 10),
              Text('充电排行榜'),
            ],
          ),
        ),
        if (controller.account.isLogin)
          if (controller.mid == controller.account.mid) ...[
            if ((controller.state.loadingState.dataOrNull?.card?.vip?.status ??
                    0) >
                0)
              PopupMenuItem(
                onTap: controller.vipExpAdd,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.upcoming_outlined, size: 19),
                    SizedBox(width: 10),
                    Text('大会员经验'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: () => Get.to(const LoginDevicesPageV2()),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.devices, size: 18),
                  SizedBox(width: 10),
                  Text('登录设备'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginLogPageV2(),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.login, size: 18),
                  SizedBox(width: 10),
                  Text('登录记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Get.to(
                const LogPage(),
                arguments: CoinLogController(),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.b, size: 16),
                  SizedBox(width: 10),
                  Text('硬币记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Get.to(
                const LogPage(),
                arguments: ExpLogController(),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.linear_scale, size: 18),
                  SizedBox(width: 10),
                  Text('经验记录'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Get.toNamed('/spaceSetting'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.settings_outlined, size: 19),
                  SizedBox(width: 10),
                  Text('空间设置'),
                ],
              ),
            ),
          ] else ...[
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () => showMemberReportDialog(
                context,
                name: controller.state.username ?? '',
                mid: _mid,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 19,
                    color: theme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '举报',
                    style: TextStyle(color: theme.error),
                  ),
                ],
              ),
            ),
          ],
      ],
    ),
    const SizedBox(width: 4),
  ];

  Widget _buildBody(MemberController controller, MemberState state) {
    if (_tabController == null || state.tab2 == null) {
      return const SizedBox.shrink();
    }

    return tabBarView(
      controller: _tabController,
      children: state.tab2!.map<Widget>((item) {
        return switch (item.param!) {
          'home' => MemberHome(heroTag: _heroTag),
          'dynamic' => MemberDynamicsPageV2(mid: _mid),
          'contribute' => MemberContributePageV2(
            heroTag: _heroTag,
            initialIndex: state.contributeInitialIndex,
            mid: _mid,
            contributeTab: null,
            hasSeasonOrSeries: false,
          ),
          'bangumi' => MemberPgcPageV2(
            mid: _mid,
          ),
          'favorite' => MemberFavorite(
            heroTag: _heroTag,
            mid: _mid,
          ),
          'cheese' => MemberCheesePage(
            mid: _mid,
          ),
          'shop' => MemberShopPage(
            mid: _mid,
          ),
          _ => Center(child: Text(item.title ?? '')),
        };
      }).toList(),
    );
  }

  Widget _buildUserInfo(ColorScheme theme, MemberController controller) {
    final state = controller.state;
    final loadingState = state.loadingState;

    if (loadingState case Success<SpaceData?>(:final response)) {
      if (response != null) {
        return DynamicSliverAppBarMedium(
          pinned: true,
          actions: _actions(theme, controller),
          title: Text(state.username ?? ''),
          flexibleSpace: UserInfoCard(
            isOwner: controller.mid == controller.account.mid,
            relation: state.relation,
            card: response.card!,
            images: response.images!,
            onFollow: () => controller.onFollow(context),
            live: state.live,
            silence: state.silence,
          ),
        );
      }
      return SliverAppBar(
        pinned: true,
        actions: _actions(theme, controller),
        title: GestureDetector(
          onTap: controller.onReload,
          behavior: HitTestBehavior.opaque,
          child: Text(state.username ?? ''),
        ),
      );
    }

    return SliverAppBar(
      pinned: true,
      actions: _actions(theme, controller),
      title: GestureDetector(
        onTap: controller.onReload,
        behavior: HitTestBehavior.opaque,
        child: Text(state.username ?? ''),
      ),
    );
  }
}
