import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/follow/presentation/widgets/follow_item.dart';
import 'package:PiliPlus/features/followed/presentation/providers/followed_controller.dart';
import 'package:PiliPlus/features/followed/presentation/providers/followed_providers.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

/// "Also followed" page - V2 with Riverpod
///
/// Shows users that are also followed by the target user
class FollowedPageV2 extends ConsumerStatefulWidget {
  const FollowedPageV2({
    super.key,
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;

  @override
  ConsumerState<FollowedPageV2> createState() => _FollowedPageV2State();

  static void toFollowedPage({dynamic mid, String? name}) {
    final midInt = mid is int
        ? mid
        : (mid != null ? int.tryParse(mid.toString()) : null);
    if (midInt == null) return;
    PageUtils.pushNamed(AppRoutes.followed, extra: {
        'mid': midInt,
        'name': name,
      },
    );
  }
}

class _FollowedPageV2State extends ConsumerState<FollowedPageV2> {
  late final FollowedController _controller;
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisExtent: 66,
  );

  @override
  void initState() {
    super.initState();
    final params = FollowedParams(
      mid: widget.mid,
      name: widget.name,
    );
    _controller = ref.read(followedControllerProvider(params));
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
            return Text(
              '我关注的${_controller.total ?? 0}人也关注了${_controller.name ?? 'TA'}',
            );
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
