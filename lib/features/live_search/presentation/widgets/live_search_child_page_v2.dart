import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/live_search/presentation/controllers/live_search_controller_v2.dart';
import 'package:PiliPlus/features/live_search/presentation/widgets/live_search_room.dart';
import 'package:PiliPlus/features/live_search/presentation/widgets/live_search_user.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/live/live_search_type.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;

/// Live Search Child Page V2 (Riverpod version)
class LiveSearchChildPageV2 extends StatefulWidget {
  const LiveSearchChildPageV2({
    super.key,
    required this.controller,
    required this.searchType,
  });

  final LiveSearchChildControllerV2 controller;
  final LiveSearchType searchType;

  @override
  State<LiveSearchChildPageV2> createState() => _LiveSearchChildPageV2State();
}

class _LiveSearchChildPageV2State extends State<LiveSearchChildPageV2>
    with AutomaticKeepAliveClientMixin {
  LiveSearchChildControllerV2 get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double padding = widget.searchType == LiveSearchType.room ? 12 : 0;
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: padding,
              left: padding,
              right: padding,
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

  Widget get _buildLoading {
    return switch (widget.searchType) {
      LiveSearchType.room => SliverGrid.builder(
        gridDelegate: roomDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      ),
      LiveSearchType.user => SliverGrid.builder(
        gridDelegate: userDelegate,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
        itemCount: 12,
      ),
    };
  }

  late final roomDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(60),
  );

  late final userDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Grid.smallCardWidth * 2,
    mainAxisExtent: 60,
  );

  Widget _buildBody(LoadingState<List<dynamic>?> loadingState) {
    return switch (loadingState) {
      Loading() => _buildLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Builder(
                builder: (context) {
                  return switch (widget.searchType) {
                    LiveSearchType.room => SliverGrid.builder(
                      gridDelegate: roomDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveCardVSearch(
                          item: response[index],
                        );
                      },
                      itemCount: response.length,
                    ),
                    LiveSearchType.user => SliverGrid.builder(
                      gridDelegate: userDelegate,
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return LiveSearchUserItem(
                          item: response[index],
                        );
                      },
                      itemCount: response.length,
                    ),
                  };
                },
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
