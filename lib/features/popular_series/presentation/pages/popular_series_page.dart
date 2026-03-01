import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/popular_series/presentation/providers/popular_series_providers.dart';
import 'package:PiliPlus/features/popular_series/presentation/providers/popular_series_controller.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/source_type.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Popular series page (每周必看)
class PopularSeriesPage extends ConsumerStatefulWidget {
  const PopularSeriesPage({super.key});

  @override
  ConsumerState<PopularSeriesPage> createState() => _PopularSeriesPageState();
}

class _PopularSeriesPageState extends ConsumerState<PopularSeriesPage> {
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
  Widget build(BuildContext context) {
    final controller = ref.watch(popularSeriesControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: controller.state.config?.name != null
            ? Text(controller.state.config!.name!)
            : const Text('每周必看'),
      ),
      body: refreshIndicator(
        onRefresh: () => controller.onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: _buildBody(controller.state.videoListState, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    LoadingState<List<HotVideoItemModel>?> value,
    PopularSeriesController controller,
  ) {
    return switch (value) {
      Loading() => gridSkeleton,
      Success(:final response) when response != null && response.isNotEmpty =>
        SliverGrid.builder(
          gridDelegate: gridDelegate,
          itemCount: response.length,
          itemBuilder: (context, index) {
            final item = response[index];
            return VideoCardH(
              videoItem: item,
              onTap: () {
                final config = controller.state.config;
                PageUtils.toVideoPage(
                  bvid: item.bvid,
                  cid: item.cid!,
                  extraArguments: {
                    'sourceType': SourceType.playlist,
                    'favTitle': '每周必看 ${config?.label ?? ''}',
                    'mediaId': config?.mediaId,
                    'desc': true,
                    'oid': item.aid,
                    'isContinuePlaying': index != 0,
                  },
                );
              },
            );
          },
        ),
      Success() => HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
