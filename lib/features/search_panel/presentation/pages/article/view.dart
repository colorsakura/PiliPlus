import 'package:PiliPlus/shared/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/features/search_panel/presentation/pages/article/controller.dart';
import 'package:PiliPlus/features/search_panel/presentation/widgets/article/item.dart';
import 'package:PiliPlus/features/search_panel/search_panel.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class SearchArticlePanel extends CommonSearchPanel {
  const SearchArticlePanel({
    super.key,
    required super.keyword,
    required super.tag,
    required super.searchType,
  });

  @override
  State<SearchArticlePanel> createState() => _SearchArticlePanelState();
}

class _SearchArticlePanelState
    extends
        CommonSearchPanelState<
          SearchArticlePanel,
          SearchArticleData,
          SearchArticleItemModel
        > {
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
  late final SearchArticleController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      SearchArticleController(
        keyword: widget.keyword,
        searchType: widget.searchType,
        tag: widget.tag,
      ),
      tag: widget.searchType.name + widget.tag,
    );
  }

  @override
  Widget buildHeader(ThemeData theme) {
    return SliverPersistentHeader(
      pinned: false,
      floating: true,
      delegate: CustomSliverPersistentHeaderDelegate(
        extent: 40,
        bgColor: theme.colorScheme.surface,
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 25, right: 12),
          child: Row(
            children: [
              Obx(
                () => Text(
                  '排序: ${controller.articleOrderType.value.label}',
                  maxLines: 1,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
              const Spacer(),
              Obx(
                () => Text(
                  '分区: ${controller.articleZoneType!.value.label}',
                  maxLines: 1,
                  style: TextStyle(color: theme.colorScheme.outline),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  tooltip: '筛选',
                  style: const ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.zero),
                  ),
                  onPressed: () => controller.onShowFilterDialog(context),
                  icon: Icon(
                    Icons.filter_list_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildList(ThemeData theme, List<SearchArticleItemModel> list) {
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        return SearchArticleItem(item: list[index]);
      },
      itemCount: list.length,
    );
  }

  @override
  Widget get buildLoading => gridSkeleton;
}
