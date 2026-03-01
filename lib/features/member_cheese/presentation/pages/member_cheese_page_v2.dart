import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/member_cheese/presentation/providers/member_cheese_list_provider.dart';
import 'package:PiliPlus/features/member_cheese/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberCheesePage extends ConsumerStatefulWidget {
  const MemberCheesePage({
    super.key,
    required this.mid,
  });

  final int mid;

  @override
  ConsumerState<MemberCheesePage> createState() => _MemberCheesePageState();
}

class _MemberCheesePageState extends ConsumerState<MemberCheesePage>
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
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(
      memberCheeseListControllerProvider(widget.mid),
    );
    final listState = controller.state.listState;

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(listState, controller),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

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
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  return MemberCheeseItem(item: response[index]);
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
