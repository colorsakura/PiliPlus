import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/features/live_area_detail/presentation/providers/live_area_detail_list_provider.dart';
import 'package:PiliPlus/features/live_search/live_search.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/features/live_area_detail/presentation/pages/child/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class LiveAreaDetailPage extends ConsumerStatefulWidget {
  const LiveAreaDetailPage({
    super.key,
    required this.areaId,
    required this.parentAreaId,
    required this.parentName,
  });

  final dynamic areaId;
  final dynamic parentAreaId;
  final String parentName;

  @override
  ConsumerState<LiveAreaDetailPage> createState() => _LiveAreaDetailPageState();
}

class _LiveAreaDetailPageState extends ConsumerState<LiveAreaDetailPage> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(
      liveAreaDetailListControllerProvider(
        (
          areaId: widget.areaId,
          parentAreaId: widget.parentAreaId,
        ),
      ),
    );
    final listState = controller.state.listState;
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.parentName),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LiveSearchPageV2()),
            ),
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: padding.left, right: padding.right),
        child: _buildBody(theme, padding.bottom, listState),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    double bottom,
    LoadingState listState,
  ) {
    return switch (listState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? DefaultTabController(
                initialIndex:
                    ref
                        .watch(
                          liveAreaDetailListControllerProvider(
                            (
                              areaId: widget.areaId,
                              parentAreaId: widget.parentAreaId,
                            ),
                          ),
                        )
                        .state
                        .initialIndex,
                length: response.length,
                child: Builder(
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                dividerHeight: 0,
                                dividerColor: Colors.transparent,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                tabs: response
                                    .map((e) => Tab(text: e.name ?? ''))
                                    .toList(),
                              ),
                            ),
                            iconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () =>
                                  _showTags(context, theme, bottom, response),
                            ),
                          ],
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: tabBarView(
                            children: response
                                .map(
                                  (e) => LiveAreaChildPage(
                                    areaId: e.id,
                                    parentAreaId: e.parentId,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            : LiveAreaChildPage(
                areaId: widget.areaId,
                parentAreaId: widget.parentAreaId,
              ),
      Error() => LiveAreaChildPage(
        areaId: widget.areaId,
        parentAreaId: widget.parentAreaId,
      ),
    };
  }

  Widget _tagItem({
    required ThemeData theme,
    required AreaItem item,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NetworkImgLayer(
            width: 45,
            height: 45,
            src: item.pic,
            type: ImageType.emote,
          ),
          const SizedBox(height: 4),
          Text(
            item.name!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showTags(
    BuildContext context,
    ThemeData theme,
    double bottom,
    List<AreaItem> list,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          minChildSize: 0,
          maxChildSize: 1,
          initialChildSize: 1,
          snap: true,
          expand: false,
          snapSizes: const [1],
          builder: (_, scrollController) {
            return Column(
              children: [
                AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  title: Text(widget.parentName),
                  actions: [
                    IconButton(
                      onPressed: Navigator.of(context).pop,
                      icon: const Icon(Icons.clear),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      top: 12,
                      bottom: bottom + 100,
                    ),
                    itemCount: list.length,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: 80,
                        ),
                    itemBuilder: (_, index) {
                      return _tagItem(
                        theme: theme,
                        item: list[index],
                        onTap: () {
                          Navigator.of(context).pop();
                          DefaultTabController.of(context).index = index;
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
