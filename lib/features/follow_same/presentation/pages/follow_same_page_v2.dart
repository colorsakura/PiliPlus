import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/follow/presentation/widgets/follow_item.dart';
import 'package:PiliPlus/features/follow_same/presentation/providers/follow_same_controller.dart';
import 'package:PiliPlus/features/follow_same/presentation/providers/follow_same_providers.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// "Same followed" page - V2 with Riverpod
///
/// Shows users that both users follow (共同关注)
class FollowSamePageV2 extends ConsumerStatefulWidget {
  const FollowSamePageV2({
    super.key,
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;

  @override
  ConsumerState<FollowSamePageV2> createState() => _FollowSamePageV2State();

  static void toFollowSamePage({dynamic mid, String? name}) {
    final midInt = mid is int
        ? mid
        : (mid != null ? int.tryParse(mid.toString()) : null);
    if (midInt == null) return;
    PageUtils.pushNamed(AppRoutes.sameFollowing, extra: {
        'mid': midInt,
        'name': name,
      },
    );
  }
}

class _FollowSamePageV2State extends ConsumerState<FollowSamePageV2> {
  late final FollowSameController _controller;
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Grid.smallCardWidth * 2,
    mainAxisExtent: 66,
  );

  @override
  void initState() {
    super.initState();
    final params = FollowSameParams(
      mid: widget.mid,
      name: widget.name,
    );
    _controller = ref.read(followSameControllerProvider(params));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            final name = _controller.name;
            return Text('${name == null ? '' : '我与$name的'}共同关注');
          },
        ),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return refreshIndicator(
            onRefresh: _controller.onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                ViewSliverSafeArea(
                  sliver: _buildBody(theme, _controller.loadingState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    ColorScheme theme,
    LoadingState<List<FollowItemModel>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
        itemCount: 16,
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return FollowItem(item: response[index]);
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
}
