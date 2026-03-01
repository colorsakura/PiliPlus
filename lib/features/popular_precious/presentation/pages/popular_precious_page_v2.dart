import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/popular_precious/presentation/providers/popular_precious_list_provider.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/video/source_type.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularPreciousPage extends ConsumerStatefulWidget {
  const PopularPreciousPage({super.key});

  @override
  ConsumerState<PopularPreciousPage> createState() =>
      _PopularPreciousPageState();
}

class _PopularPreciousPageState extends ConsumerState<PopularPreciousPage>
    with GridMixin {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(popularPreciousListControllerProvider);
    final listState = controller.state.listState;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('入站必刷')),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: _buildBody(listState, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    LoadingState listState,
    dynamic controller,
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
                          'mediaId': controller.state.mediaId,
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
