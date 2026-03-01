import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/features/reply_search/presentation/controllers/reply_search_controller_v2.dart';
import 'package:PiliPlus/features/video/presentation/widgets/reply_search_item/child/item.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

/// Reply Search Child Page V2 (Riverpod version)
class ReplySearchChildPageV2 extends StatefulWidget {
  const ReplySearchChildPageV2({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final ReplySearchChildControllerV2 controller;
  final ReplySearchType searchType;

  @override
  State<ReplySearchChildPageV2> createState() => _ReplySearchChildPageV2State();
}

class _ReplySearchChildPageV2State extends State<ReplySearchChildPageV2>
    with AutomaticKeepAliveClientMixin {
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
  ReplySearchChildControllerV2 get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return _buildBody(_controller.loadingState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SearchItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return ReplySearchItem(
                    item: response[index],
                    type: widget.searchType,
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
