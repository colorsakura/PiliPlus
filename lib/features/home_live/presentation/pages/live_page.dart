import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/button/more_btn.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/home_live/presentation/providers/live_controller.dart';
import 'package:PiliPlus/features/home_live/presentation/providers/live_providers.dart';
import 'package:PiliPlus/features/home_live/presentation/widgets/live_item_card.dart';
import 'package:PiliPlus/features/live_area/live_area.dart';
import 'package:PiliPlus/features/live_follow/live_follow.dart';
import 'package:PiliPlus/features/search/presentation/widgets/search_text.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// 直播页面 - Clean Architecture + Riverpod
class LivePage extends ConsumerStatefulWidget {
  const LivePage({super.key});

  @override
  ConsumerState<LivePage> createState() => _LivePageState();
}

class _LivePageState extends ConsumerState<LivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 初始化数据加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveControllerProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final theme = Theme.of(context);

    final liveState = ref.watch(liveControllerProvider);
    final controller = ref.read(liveControllerProvider.notifier);

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
      decoration: const BoxDecoration(borderRadius: StyleString.mdRadius),
      child: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                top: StyleString.cardSpace,
                bottom: 100,
              ),
              sliver: SliverMainAxisGroup(
                slivers: [
                  _buildTop(theme, textScaler, liveState),
                  _buildBody(theme, textScaler, liveState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(
    ThemeData theme,
    TextScaler textScaler,
    LiveControllerState state,
  ) {
    return SliverMainAxisGroup(
      slivers: [
        if (state.followingItems != null)
          _buildFollowSection(theme, textScaler, state),
        if (state.areaItems != null && state.areaItems!.isNotEmpty)
          _buildAreaSelector(theme, textScaler, state),
      ],
    );
  }

  Widget _buildFollowSection(
    ThemeData theme,
    TextScaler textScaler,
    LiveControllerState state,
  ) {
    final followingItems = state.followingItems!;
    final followingCount = state.followingCount ?? 0;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '我的关注  '),
                      TextSpan(
                        text: followingCount.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: '人正在直播',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                moreTextButton(
                  onTap: () => Get.to(const LiveFollowPage()),
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (followingItems.isNotEmpty)
          _buildFollowList(theme, textScaler, followingItems, followingCount),
      ],
    );
  }

  Widget _buildFollowList(
    ThemeData theme,
    TextScaler textScaler,
    List<dynamic> followingItems,
    int totalCount,
  ) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 68.0 + textScaler.scale(12),
        child: CustomScrollView(
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFixedExtentList.builder(
              itemExtent: 70,
              itemCount: totalCount > followingItems.length
                  ? followingItems.length + 1
                  : followingItems.length,
              itemBuilder: (context, index) {
                if (index == followingItems.length) {
                  return Align(
                    alignment: const Alignment(0, -0.3),
                    child: GestureDetector(
                      onTap: () => Get.to(const LiveFollowPage()),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onInverseSurface,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                final item = followingItems[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: SizedBox(
                    width: 65,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => PageUtils.toLiveRoom(item.roomid),
                      onLongPress: () {
                        Feedback.forLongPress(context);
                        PageUtils.toMemberPage((item.uid as int));
                      },
                      onSecondaryTap: PlatformUtils.isMobile
                          ? null
                          : () => PageUtils.toMemberPage((item.uid as int)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.5,
                                color: theme.colorScheme.primary,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: NetworkImgLayer(
                              type: ImageType.avatar,
                              width: 45,
                              height: 45,
                              src: item.face,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.uname ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, height: 1),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaSelector(
    ThemeData theme,
    TextScaler textScaler,
    LiveControllerState state,
  ) {
    final areaItems = state.areaItems!;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 10.0 + textScaler.scale(14),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isFirst = index == 0;
                    final item = isFirst ? null : areaItems[index - 1];
                    final isCurr = index == state.areaIndex;
                    return SearchText(
                      fontSize: 14,
                      height: 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      text: isFirst ? '推荐' : item?.title ?? '',
                      bgColor: isCurr
                          ? theme.colorScheme.secondaryContainer
                          : Colors.transparent,
                      textColor: isCurr
                          ? theme.colorScheme.onSecondaryContainer
                          : null,
                      onTap: (_) => ref
                          .read(liveControllerProvider.notifier)
                          .selectArea(index, item),
                    );
                  },
                  itemCount: areaItems.length + 1,
                ),
              ),
            ),
            iconButton(
              size: 26,
              iconSize: 16,
              context: context,
              tooltip: '游戏赛事',
              icon: const Icon(Icons.gamepad),
              onPressed: () => PageUtils.pushNamed(AppRoutes.webview, parameters: {
                  'uaType': 'mob',
                  'url':
                      'https://www.bilibili.com/h5/match/data/home?navhide=1&${theme.brightness.isDark ? 'dark=1' : 'dark=0'}',
                },
              ),
            ),
            const SizedBox(width: 8),
            iconButton(
              size: 26,
              iconSize: 16,
              context: context,
              tooltip: '全部标签',
              icon: const Icon(Icons.widgets),
              onPressed: () => Get.to(const LiveAreaPageV2()),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(
    ThemeData theme,
    TextScaler textScaler,
    LiveControllerState state,
  ) {
    if (state.isLoading && state.streams.isEmpty) {
      return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      );
    }

    if (state.errorMessage != null && state.streams.isEmpty) {
      return HttpError(
        errMsg: state.errorMessage,
        onReload: ref.read(liveControllerProvider.notifier).onReload,
      );
    }

    // 如果没有直播流且没有错误，显示空状态提示
    if (state.streams.isEmpty && !state.isLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.live_tv_outlined,
                  size: 64,
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  state.areaIndex == 0 ? '暂无推荐直播' : '该分区暂无直播',
                  style: TextStyle(
                    color: theme.colorScheme.outline,
                    fontSize: 14,
                  ),
                ),
                if (state.areaIndex == 0 &&
                    state.areaItems != null &&
                    state.areaItems!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '请选择上方分区查看更多内容',
                    style: TextStyle(
                      color: theme.colorScheme.outline.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // 构建内容列表
    final List<Widget> slivers = [];

    if (state.sortTags != null && state.sortTags!.isNotEmpty) {
      slivers.add(_buildSortTags(theme, textScaler, state));
    }

    slivers.add(
      SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) {
          return LiveItemCard(stream: state.streams[index]);
        },
        itemCount: state.streams.length,
      ),
    );

    // 如果有多个 sliver，使用 SliverMainAxisGroup
    if (slivers.length > 1) {
      return SliverMainAxisGroup(slivers: slivers);
    }
    return slivers.first;
  }

  Widget _buildSortTags(
    ThemeData theme,
    TextScaler textScaler,
    LiveControllerState state,
  ) {
    final sortTags = state.sortTags!;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 18.0 + textScaler.scale(13),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 8),
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = sortTags[index];
            final isCurr = index == state.tagIndex;
            return SearchText(
              height: 1,
              fontSize: 13,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              text: item.name ?? '',
              bgColor: isCurr
                  ? theme.colorScheme.secondaryContainer
                  : Colors.transparent,
              textColor: isCurr ? theme.colorScheme.onSecondaryContainer : null,
              onTap: (_) => ref
                  .read(liveControllerProvider.notifier)
                  .selectTag(index, item.sortType),
            );
          },
          itemCount: sortTags.length,
        ),
      ),
    );
  }
}
