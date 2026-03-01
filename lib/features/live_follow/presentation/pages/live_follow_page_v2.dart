import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/live_follow/presentation/providers/live_follow_controller.dart';
import 'package:PiliPlus/features/live_follow/presentation/widgets/live_item_follow.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LiveFollowPage extends ConsumerStatefulWidget {
  const LiveFollowPage({super.key});

  @override
  ConsumerState<LiveFollowPage> createState() => _LiveFollowPageState();
}

class _LiveFollowPageState extends ConsumerState<LiveFollowPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveFollowControllerProvider);
    final controller = ref.read(liveFollowControllerProvider.notifier);
    final listState = state.listState;
    final padding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          state.count != null ? '${state.count}人正在直播' : '关注直播',
        ),
      ),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                left: StyleString.safeSpace + padding.left,
                right: StyleString.safeSpace + padding.right,
                bottom: padding.bottom + 100,
              ),
              sliver: _buildBody(listState, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Pref.smallCardWidth,
    childAspectRatio: (16 / 9),
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
  );

  Widget _buildBody(
    LoadingState listState,
    LiveFollowState state,
    LiveFollowController controller,
  ) {
    return switch (listState) {
      Loading() => SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
        itemCount: 10,
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  return LiveCardVFollow(
                    liveItem: response[index],
                  );
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
