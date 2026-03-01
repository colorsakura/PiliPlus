import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/follow/presentation/widgets/follow_item.dart';
import 'package:PiliPlus/features/follow_type/presentation/pages/controller.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

abstract class FollowTypePageState<T extends StatefulWidget> extends State<T> {
  FollowTypeController get controller;

  PreferredSizeWidget? get appBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          // controller: controller.scrollController,
          slivers: [
            ViewSliverSafeArea(
              sliver: Obx(
                () => _buildBody(theme, controller.loadingState.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisExtent: 66,
  );

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
                    controller.onLoadMore();
                  }
                  return buildItem(index, response[index]);
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

  Widget buildItem(int index, FollowItemModel item) => FollowItem(item: item);
}
