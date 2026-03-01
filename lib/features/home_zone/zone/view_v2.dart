import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/video_card/video_card_h.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/features/home_zone/zone/controller_v2.dart';
import 'package:PiliPlus/features/home_zone/zone/providers.dart';
import 'package:PiliPlus/features/home_zone/zone/widget/pgc_rank_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZonePageV2 extends ConsumerStatefulWidget {
  const ZonePageV2({super.key, this.rid, this.seasonType});

  final int? rid;
  final int? seasonType;

  @override
  ConsumerState<ZonePageV2> createState() => _ZonePageV2State();
}

class _ZonePageV2State extends ConsumerState<ZonePageV2>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(
      zoneControllerProvider(
        (rid: widget.rid, seasonType: widget.seasonType),
      ),
    );

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 7, bottom: 100),
            sliver: ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return _buildBody(controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ZoneControllerV2 controller) {
    return switch (controller.loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  final item = response[index];
                  if (item is HotVideoItemModel) {
                    return VideoCardH(
                      videoItem: item,
                      onRemove: () {
                        final newList = List<dynamic>.from(response);
                        newList.removeAt(index);
                        controller.loadingState = Success(newList);
                      },
                    );
                  }
                  return PgcRankItem(item: item);
                },
                itemCount: response.length,
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
