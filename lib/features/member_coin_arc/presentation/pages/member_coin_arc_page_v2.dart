import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/member_coin_arc/presentation/providers/member_coin_arc_controller.dart';
import 'package:PiliPlus/features/member_coin_arc/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

class MemberCoinArcPage extends ConsumerStatefulWidget {
  const MemberCoinArcPage({
    super.key,
    required this.mid,
    this.name,
  });

  final dynamic mid;
  final String? name;

  @override
  ConsumerState<MemberCoinArcPage> createState() => _MemberCoinArcPageState();
}

class _MemberCoinArcPageState extends ConsumerState<MemberCoinArcPage> {
  late final mid = Accounts.main.mid;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    final state = ref.watch(memberCoinArcControllerProvider(widget.mid));
    final controller = ref.read(memberCoinArcControllerProvider(widget.mid).notifier);
    final listState = state.listState;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '${widget.mid == mid ? '我' : '${widget.name}'}的最近投币',
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
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(75),
  );

  Widget _buildBody(
    LoadingState listState,
    MemberCoinArcState state,
    MemberCoinArcController controller,
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
}
