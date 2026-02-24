import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/pgc/presentation/providers/pgc_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/features/pgc/presentation/widgets/pgc_card_v.dart';
import 'package:PiliPlus/features/pgc/presentation/widgets/pgc_card_v_timeline.dart';
import 'package:PiliPlus/features/pgc_index/presentation/widgets/pgc_card_v_pgc_index.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PGC page
///
/// Displays PGC (番剧/影视) content with follow list, timeline, and recommendations
class PgcPage extends ConsumerStatefulWidget {
  const PgcPage({
    super.key,
    required this.tabType,
  });

  final HomeTabType tabType;

  @override
  ConsumerState<PgcPage> createState() => _PgcPageState();
}

class _PgcPageState extends ConsumerState<PgcPage>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  late final bool _showPgcTimeline;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _showPgcTimeline =
        widget.tabType == HomeTabType.bangumi && Pref.showPgcTimeline;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return refreshIndicator(
      onRefresh: () async {
        await ref.read(pgcControllerProvider(widget.tabType)).onRefresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildFollow(theme),
          if (_showPgcTimeline) _buildTimelineSection(theme),
          _buildMainList(theme),
        ],
      ),
    );
  }

  Widget _buildFollow(ThemeData theme) {
    final controller = ref.watch(pgcControllerProvider(widget.tabType));
    final followState = controller.state.followListState;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: Grid.smallCardWidth / 2 / 0.75 +
            MediaQuery.textScalerOf(context).scale(112),
        child: switch (followState) {
          Loading() => const SizedBox(),
          Success(:final response) =>
            response != null && response.isNotEmpty
                ? _buildFollowList(theme, response)
                : const SizedBox.shrink(),
          Error() => const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildTimelineSection(ThemeData theme) {
    final controller = ref.watch(pgcControllerProvider(widget.tabType));
    final timelineState = controller.state.timelineState;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: Grid.smallCardWidth / 2 / 0.75 +
            MediaQuery.textScalerOf(context).scale(96),
        child: switch (timelineState) {
          Loading() => loadingWidget,
          Success(:final response) =>
            response != null && response.isNotEmpty
                ? _buildTimeline(theme, response)
                : const SizedBox.shrink(),
          Error() => const SizedBox.shrink(),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildMainList(ThemeData theme) {
    final controller = ref.watch(pgcControllerProvider(widget.tabType));
    final mainListState = controller.state.mainListState;

    return switch (mainListState) {
      Loading() => const SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                  mainAxisSpacing: StyleString.cardSpace,
                  crossAxisSpacing: StyleString.cardSpace,
                  maxCrossAxisExtent: Grid.smallCardWidth * 0.6,
                  childAspectRatio: 0.75,
                  mainAxisExtent: MediaQuery.textScalerOf(context).scale(50),
                ),
                itemBuilder: (context, index) {
                  return PgcCardVPgcIndex(item: response[index]);
                },
                itemCount: response.length,
              )
            : const SliverToBoxAdapter(
              child: SizedBox(height: 200, child: Center(child: Text('No data'))),
            ),
      Error() => const SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: Center(child: Text('Error loading data')),
          ),
        ),
      _ => const SliverToBoxAdapter(
        child: SizedBox(height: 200, child: Center(child: Text('Unknown state'))),
      ),
    };
  }

  Widget _buildFollowList(ThemeData theme, List<FavPgcItemModel> items) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: Grid.smallCardWidth * 0.6,
          child: PgcCardV(item: items[index]),
        );
      },
    );
  }

  Widget _buildTimeline(ThemeData theme, List items) {
    // TODO: Implement timeline widget properly
    return SizedBox(
      height: 100,
      child: Center(
        child: Text('Timeline with ${items.length} items'),
      ),
    );
  }
}
