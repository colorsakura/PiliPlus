import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/features/member_season_series/presentation/providers/member_season_series_list_provider.dart';
import 'package:PiliPlus/features/member_season_series/presentation/widgets/season_series_card.dart';
import 'package:PiliPlus/features/member_video/member_video.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';
import 'package:PiliPlus/models/space/space_season_series/season.dart'
    show SpaceSsModel;
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class MemberSeasonSeriesPage extends ConsumerStatefulWidget {
  const MemberSeasonSeriesPage({
    super.key,
    required this.mid,
    this.heroTag,
  });

  final int mid;
  final String? heroTag;

  @override
  ConsumerState<MemberSeasonSeriesPage> createState() =>
      _MemberSeasonSeriesPageState();
}

class _MemberSeasonSeriesPageState extends ConsumerState<MemberSeasonSeriesPage>
    with AutomaticKeepAliveClientMixin {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: (16 / 9) * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(
      memberSeasonSeriesListControllerProvider(widget.mid),
    );
    final listState = controller.state.listState;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
          ),
          sliver: _buildBody(listState, controller),
        ),
      ],
    );
  }

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
                  SpaceSsModel item = response[index];
                  return SeasonSeriesCard(
                    item: item,
                    onTap: () {
                      bool isSeason = item.meta!.seasonId != null;
                      dynamic id = isSeason
                          ? item.meta!.seasonId
                          : item.meta!.seriesId;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            resizeToAvoidBottomInset: false,
                            appBar: AppBar(title: Text(item.meta!.name!)),
                            body: ViewSafeArea(
                              child: MemberVideo(
                                type: isSeason
                                    ? ContributeType.season
                                    : ContributeType.series,
                                heroTag: widget.heroTag,
                                mid: widget.mid,
                                seasonId: isSeason ? id : null,
                                seriesId: isSeason ? null : id,
                                title: item.meta!.name,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
