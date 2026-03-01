import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_cheese_controller.dart';
import 'package:PiliPlus/features/member_cheese/presentation/widgets/item.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavCheesePage extends StatefulWidget {
  const FavCheesePage({super.key});

  @override
  State<FavCheesePage> createState() => _FavCheesePageState();
}

class _FavCheesePageState extends State<FavCheesePage>
    with AutomaticKeepAliveClientMixin {
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
  final FavCheeseController _controller = Get.put(FavCheeseController());

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
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
            sliver: Obx(
              () => _buildBody(theme, _controller.loadingState.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<SpaceCheeseItem>?> loadingState,
  ) {
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
                  final item = response[index];
                  return MemberCheeseItem(
                    item: item,
                    onRemove: () => showConfirmDialog(
                      context: context,
                      title: '确定取消收藏该课堂？',
                      onConfirm: () =>
                          _controller.onRemove(index, item.seasonId!),
                    ),
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
}
