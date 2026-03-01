import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/search_panel/presentation/pages/controller.dart';
import 'package:PiliPlus/features/search_panel/search_panel.dart';
import 'package:PiliPlus/features/search_panel/presentation/widgets/live/item.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/shared/skeleton/video_card_v.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

class SearchLivePanel extends CommonSearchPanel {
  const SearchLivePanel({
    super.key,
    required super.keyword,
    required super.tag,
    required super.searchType,
  });

  @override
  State<SearchLivePanel> createState() => _SearchLivePanelState();
}

class _SearchLivePanelState
    extends
        CommonSearchPanelState<
          SearchLivePanel,
          SearchLiveData,
          SearchLiveItemModel
        > {
  @override
  late final SearchPanelController<SearchLiveData, SearchLiveItemModel>
  controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      SearchPanelController<SearchLiveData, SearchLiveItemModel>(
        keyword: widget.keyword,
        searchType: widget.searchType,
        tag: widget.tag,
      ),
      tag: widget.searchType.name + widget.tag,
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    maxCrossAxisExtent: Pref.smallCardWidth,
    crossAxisSpacing: StyleString.cardSpace,
    mainAxisSpacing: StyleString.cardSpace,
    childAspectRatio: (16 / 9),
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(80),
  );

  @override
  Widget buildList(ThemeData theme, List<SearchLiveItemModel> list) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        left: StyleString.safeSpace,
        right: StyleString.safeSpace,
      ),
      sliver: SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemBuilder: (context, index) {
          if (index == list.length - 1) {
            controller.onLoadMore();
          }
          return LiveItem(liveItem: list[index]);
        },
        itemCount: list.length,
      ),
    );
  }

  @override
  Widget get buildLoading => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (context, index) => const VideoCardVSkeleton(),
    itemCount: 10,
  );
}
