import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/member_coin_arc/presentation/widgets/item.dart';
import 'package:PiliPlus/features/member_like_arc/presentation/providers/member_like_arc_controller.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberLikeArcPageV2 extends ConsumerStatefulWidget {
  const MemberLikeArcPageV2({
    super.key,
    required this.mid,
    this.name,
  });

  final int mid;
  final String? name;

  @override
  ConsumerState<MemberLikeArcPageV2> createState() =>
      _MemberLikeArcPageV2State();
}

class _MemberLikeArcPageV2State extends ConsumerState<MemberLikeArcPageV2>
    with AutomaticKeepAliveClientMixin {
  late final mid = Accounts.main.mid;
  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Pref.smallCardWidth,
    childAspectRatio: (16 / 9),
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(75),
  );

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(memberLikeArcControllerProvider(widget.mid));
    final controller =
        ref.read(memberLikeArcControllerProvider(widget.mid).notifier);
    final listState = state.listState;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '${widget.mid == mid ? '我' : '${widget.name}'}的推荐',
        ),
      ),
      body: refreshIndicator(
        onRefresh: () => controller.onRefresh(widget.mid),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: 7,
                left: StyleString.safeSpace,
                right: StyleString.safeSpace,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: _buildBody(listState, state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    LoadingState listState,
    MemberLikeArcState state,
    MemberLikeArcController controller,
  ) {
    return switch (listState) {
      Loading() => SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: 16,
        itemBuilder: (context, index) => const VideoCardVSkeleton(),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: response.length,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore(widget.mid);
                  }
                  return MemberCoinLikeItem(item: response[index]);
                },
              )
            : HttpError(onReload: () => controller.onReload(widget.mid)),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () => controller.onReload(widget.mid),
      ),
    };
  }

  @override
  bool get wantKeepAlive => true;
}
