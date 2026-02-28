import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/home_rcmd/presentation/providers/recommendation_controller.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_v.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RcmdPage extends ConsumerStatefulWidget {
  const RcmdPage({super.key});

  @override
  ConsumerState<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends ConsumerState<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 立即初始化
    Future.microtask(() {
      ref.read(recommendationControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool _isLoadingMore = false;

  void _onScroll() {
    if (_isLoadingMore) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // 使用防抖，避免频繁触发
      _isLoadingMore = true;
      Future.microtask(() {
        ref.read(recommendationControllerProvider.notifier).onLoadMore();
        // 延迟重置标志，给加载一些时间
        Future.delayed(const Duration(milliseconds: 500), () {
          _isLoadingMore = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(recommendationControllerProvider);

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
      decoration: const BoxDecoration(borderRadius: StyleString.mdRadius),
      child: refreshIndicator(
        onRefresh: () =>
            ref.read(recommendationControllerProvider.notifier).onRefresh(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(
                top: StyleString.cardSpace,
                bottom: 100,
              ),
              sliver: _buildBody(state),
            ),
          ],
        ),
      ),
    );
  }

  SliverGridDelegateWithExtentAndRatio get gridDelegate {
    // PC端使用更大的卡片宽度，减少每行的卡片数量
    return SliverGridDelegateWithExtentAndRatio(
      mainAxisSpacing: PlatformUtils.isDesktop
          ? StyleString.cardSpace * 6
          : StyleString.cardSpace,
      crossAxisSpacing: PlatformUtils.isDesktop
          ? StyleString.cardSpace * 4
          : StyleString.cardSpace,
      maxCrossAxisExtent: PlatformUtils.isDesktop
          ? 320.0
          : Pref.recommendCardWidth,
      childAspectRatio: StyleString.aspectRatio,
      mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
    );
  }

  Widget _buildBody(RecommendationState state) {
    if (state.isLoading && state.result == null) {
      return _buildSkeleton;
    }

    if (state.errorMessage != null && state.result == null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: HttpError(
            isSliver: false,
            errMsg: state.errorMessage,
            onReload: () =>
                ref.read(recommendationControllerProvider.notifier).onReload(),
          ),
        ),
      );
    }

    final videos = state.displayList;
    if (videos.isEmpty) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: HttpError(
            isSliver: false,
            onReload: () =>
                ref.read(recommendationControllerProvider.notifier).onReload(),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // 显示"上次看到这里"标记
          if (state.lastRefreshAt != null && index == state.lastRefreshAt) {
            return GestureDetector(
              key: ValueKey('refresh_tip_$index'),
              onTap: () {
                ref.read(recommendationControllerProvider.notifier).onRefresh();
                _animateToTop();
              },
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: const RoundedRectangleBorder(
                  borderRadius: StyleString.mdRadius,
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '上次看到这里\n点击刷新',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }

          // 计算实际视频索引
          final actualIndex =
              state.lastRefreshAt != null && index > state.lastRefreshAt!
              ? index - 1
              : index;

          if (actualIndex >= 0 && actualIndex < videos.length) {
            return VideoCardV(
              key: ValueKey('video_${videos[actualIndex].aid}'),
              videoItem: videos[actualIndex],
              onRemove: () {
                ref
                    .read(recommendationControllerProvider.notifier)
                    .removeVideo(actualIndex);
              },
            );
          }

          return const SizedBox.shrink();
        },
        childCount: state.lastRefreshAt != null
            ? videos.length + 1
            : videos.length,
        addAutomaticKeepAlives: false, // 优化：不保持所有widget存活，减少内存
        addRepaintBoundaries: true, // 保持重绘边界，减少重绘范围
      ),
    );
  }

  void _animateToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget get _buildSkeleton => SliverGrid(
    delegate: SliverChildBuilderDelegate(
      (context, index) => const VideoCardVSkeleton(),
      childCount: 10,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
    ),
    gridDelegate: gridDelegate,
  );
}
