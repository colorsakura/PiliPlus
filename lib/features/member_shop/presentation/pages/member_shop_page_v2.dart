import 'package:PiliPlus/shared/skeleton/space_opus.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/member_shop/presentation/providers/member_shop_controller.dart';
import 'package:PiliPlus/features/member_shop/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_shop/item.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

class MemberShopPage extends ConsumerStatefulWidget {
  const MemberShopPage({
    super.key,
    required this.mid,
  });

  final int mid;

  @override
  ConsumerState<MemberShopPage> createState() => _MemberShopPageState();
}

class _MemberShopPageState extends ConsumerState<MemberShopPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(memberShopControllerProvider(widget.mid));
    final controller = ref.read(memberShopControllerProvider(widget.mid).notifier);
    final listState = state.listState;

    return refreshIndicator(
      onRefresh: () => controller.onRefresh(widget.mid),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 12,
              left: StyleString.safeSpace,
              right: StyleString.safeSpace,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(listState, state, controller),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  late double _maxWidth;

  late final gridDelegate = SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth,
    mainAxisSpacing: StyleString.safeSpace,
    crossAxisSpacing: StyleString.safeSpace,
    afterCalc: (value) => _maxWidth = value,
  );

  Widget _buildBody(
    LoadingState listState,
    MemberShopState state,
    MemberShopController controller,
  ) {
    return switch (listState) {
      Loading() => SliverWaterfallFlow(
        gridDelegate: gridDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, index) => const SpaceOpusSkeleton(),
          childCount: 10,
        ),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? _buildContent(response, controller)
            : HttpError(onReload: () => controller.onReload(widget.mid)),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () => controller.onReload(widget.mid),
      ),
    };
  }

  Widget _buildContent(List<SpaceShopItem> response, MemberShopController controller) {
    Widget sliver = SliverWaterfallFlow(
      gridDelegate: gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (_, index) {
          if (index == response.length - 1) {
            controller.onLoadMore(widget.mid);
          }
          return MemberShopItem(
            item: response[index],
            maxWidth: _maxWidth,
          );
        },
        childCount: response.length,
      ),
    );

    if (controller.state.showMoreTab == true) {
      sliver = SliverMainAxisGroup(
        slivers: [
          sliver,
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Center(
                child: FilledButton.tonal(
                  onPressed: () {
                    if (controller.state.clickUrl case final clickUrl?) {
                      final url = Uri.parse(
                        clickUrl,
                      ).queryParameters['url'];
                      if (url case final url?) {
                        // TODO: Navigate to webview - need router integration
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(controller.state.showMoreDesc ?? ''),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return sliver;
  }
}
