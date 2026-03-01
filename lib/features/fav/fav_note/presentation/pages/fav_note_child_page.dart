import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_list_controller.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/providers/fav_note_providers.dart';
import 'package:PiliPlus/features/fav/fav_note/presentation/widgets/fav_note_item.dart';
import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite notes child page (for each tab)
class FavNoteChildPage extends ConsumerStatefulWidget {
  const FavNoteChildPage({super.key, required this.isPublish});

  final bool isPublish;

  @override
  ConsumerState<FavNoteChildPage> createState() => _FavNoteChildPageState();
}

class _FavNoteChildPageState extends ConsumerState<FavNoteChildPage>
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final bottomH = 50 + padding.bottom;
    final controller = ref.watch(favNoteControllerProvider(widget.isPublish));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        refreshIndicator(
          onRefresh: controller.onRefresh,
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(bottom: padding.bottom + 100),
                sliver: _buildBody(controller.state.listState, controller),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: -bottomH,
          child: AnimatedSlide(
            offset: controller.enableMultiSelect
                ? const Offset(0, -1)
                : Offset.zero,
            duration: const Duration(milliseconds: 150),
            child: Container(
              height: bottomH,
              padding: padding,
              decoration: BoxDecoration(
                color: theme.colorScheme.onInverseSurface,
                border: Border(
                  top: BorderSide(
                    width: 0.5,
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  iconButton(
                    size: 32,
                    tooltip: '取消',
                    context: context,
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.setMultiSelectMode(false),
                  ),
                  const SizedBox(width: 12),
                  Checkbox(
                    value: controller.allSelected,
                    onChanged: (value) {
                      controller.handleSelect(
                        checked: !controller.allSelected,
                      );
                    },
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => controller.handleSelect(
                      checked: !controller.allSelected,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(
                        top: 14,
                        bottom: 14,
                        right: 12,
                      ),
                      child: Text('全选'),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      if (controller.checkedCount != 0) {
                        showConfirmDialog(
                          context: context,
                          title: '确定删除已选中的笔记吗？',
                          onConfirm: () => controller.onRemove(),
                        );
                      }
                    },
                    child: const Text('删除'),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    LoadingState<List<FavNoteItemModel>?> loadingState,
    FavNoteController controller,
  ) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  final item = response[index];
                  return FavNoteItem(
                    item: item,
                    controller: controller,
                    onSelect: () => controller.onSelect(item),
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
