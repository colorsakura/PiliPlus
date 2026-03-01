import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/features/home_hot/presentation/providers/hot_video_controller.dart';
import 'package:PiliPlus/features/home_zone/view_v2.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class HotPage extends ConsumerStatefulWidget {
  const HotPage({super.key});

  @override
  ConsumerState<HotPage> createState() => _HotPageState();
}

class _HotPageState extends ConsumerState<HotPage>
    with AutomaticKeepAliveClientMixin {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: StyleString.aspectRatio * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hotVideoControllerProvider.notifier).initialize();
    });
  }

  Widget _buildEntranceItem({
    required String iconUrl,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          NetworkImgLayer(
            width: 35,
            height: 35,
            type: .emote,
            src: iconUrl,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(hotVideoControllerProvider);
    final notifier = ref.read(hotVideoControllerProvider.notifier);

    return refreshIndicator(
      onRefresh: notifier.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (Pref.showHotRcmd)
            SliverToBoxAdapter(
              child: Padding(
                padding: const .only(left: 12, top: 12, right: 12),
                child: Row(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    _buildEntranceItem(
                      iconUrl:
                          'https://i0.hdslb.com/bfs/archive/a3f11218aaf4521b4967db2ae164ecd3052586b9.png',
                      title: '排行榜',
                      onTap: () {
                        Get.to(
                          Scaffold(
                            resizeToAvoidBottomInset: false,
                            appBar: AppBar(title: const Text('排行榜')),
                            body: const ViewSafeArea(child: RankPageV2()),
                          ),
                        );
                      },
                    ),
                    _buildEntranceItem(
                      iconUrl:
                          'https://i0.hdslb.com/bfs/archive/552ebe8c4794aeef30ebd1568b59ad35f15e21ad.png',
                      title: '每周必看',
                      onTap: () => PageUtils.pushNamed(AppRoutes.popularSeries),
                    ),
                    _buildEntranceItem(
                      iconUrl:
                          'https://i0.hdslb.com/bfs/archive/3693ec9335b78ca57353ac0734f36a46f3d179a9.png',
                      title: '入站必刷',
                      onTap: () => PageUtils.pushNamed(AppRoutes.popularPrecious),
                    ),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 7, bottom: 100),
            sliver: _buildBody(controller, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(HotVideoState state, HotVideoController notifier) {
    if (state.isLoading && state.result == null) {
      return gridSkeleton;
    }

    if (state.errorMessage != null && state.result == null) {
      return HttpError(
        errMsg: state.errorMessage,
        onReload: notifier.onReload,
      );
    }

    final videos = state.displayList;

    if (videos.isEmpty) {
      return HttpError(onReload: notifier.onReload);
    }

    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        if (index == videos.length - 1) {
          // 延迟到 build 完成后执行，避免在构建期间修改 provider
          Future.microtask(() => notifier.onLoadMore());
        }
        return VideoCardH(
          videoItem: videos[index].video,
          onRemove: () => notifier.removeVideo(index),
        );
      },
      itemCount: videos.length,
    );
  }
}
