import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/popular_precious/presentation/providers/popular_precious_controller.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/source_type.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class PopularPreciousPage extends ConsumerStatefulWidget {
  const PopularPreciousPage({super.key});

  @override
  ConsumerState<PopularPreciousPage> createState() =>
      _PopularPreciousPageState();
}

class _PopularPreciousPageState extends ConsumerState<PopularPreciousPage> {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: (16 / 9) * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(popularPreciousControllerProvider);
    final controller = ref.read(popularPreciousControllerProvider.notifier);
    final listState = state.listState;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('入站必刷')),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: _buildBody(listState, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    LoadingState listState,
    PopularPreciousState state,
    PopularPreciousController controller,
  ) {
    return switch (listState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: response.length,
                itemBuilder: (context, index) {
                  final item = response[index];
                  return VideoCardH(
                    videoItem: item,
                    onTap: () {
                      PageUtils.toVideoPage(
                        bvid: item.bvid,
                        cid: item.cid!,
                        extraArguments: {
                          'sourceType': SourceType.playlist,
                          'favTitle': '入站必刷',
                          'mediaId': state.mediaId,
                          'desc': true,
                          'oid': item.aid,
                          'isContinuePlaying': index != 0,
                        },
                      );
                    },
                  );
                },
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
