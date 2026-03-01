import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/common/presentation/pages/multi_select/base.dart';
import 'package:PiliPlus/features/fav/fav_pgc/presentation/providers/fav_pgc_list_controller.dart';
import 'package:PiliPlus/features/fav/fav_pgc/presentation/providers/fav_pgc_providers.dart';
import 'package:PiliPlus/features/fav/presentation/pages/pgc/widget/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/shared/skeleton/fav_pgc_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Adapter to make FavPgcController compatible with MultiSelectBase interface
class _MultiSelectAdapter implements MultiSelectBase {
  _MultiSelectAdapter(this.controller);

  final FavPgcController controller;

  @override
  RxBool get enableMultiSelect => RxBool(controller.enableMultiSelect);

  @override
  int get checkedCount => controller.checkedCount;

  @override
  void onSelect(covariant FavPgcItemModel item) {
    controller.onSelect(item);
  }

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    controller.handleSelect(checked: checked);
  }

  @override
  void onRemove() {
    // Not implemented - uses onUpdateList instead
  }
}

/// Favorite PGC child page (for each status tab)
class FavPgcChildPage extends ConsumerStatefulWidget {
  const FavPgcChildPage({
    super.key,
    required this.type,
    required this.followStatus,
  });

  final int type;
  final int followStatus;

  @override
  ConsumerState<FavPgcChildPage> createState() => _FavPgcChildPageState();
}

class _FavPgcChildPageState extends ConsumerState<FavPgcChildPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final bottomH = 50 + padding.bottom;
    final controller = ref.watch(
      favPgcControllerProvider(
        (type: widget.type, followStatus: widget.followStatus),
      ),
    );

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
                          title: '确定移动已选中的追番吗？',
                          onConfirm: () {
                            // Move to different status - for now just remove
                            controller.afterDelete(controller.allChecked);
                          },
                        );
                      }
                    },
                    child: const Text('移动'),
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
    LoadingState<List<FavPgcItemModel>?> loadingState,
    FavPgcController controller,
  ) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(
        child: FavPgcItemSkeleton(),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  final item = response[index];
                  return FavPgcItem(
                    item: item,
                    ctr: _MultiSelectAdapter(controller),
                    onSelect: () => controller.onSelect(item),
                    onUpdateStatus: () {
                      // Show status update dialog (simplified)
                      // In full implementation, this would show a dialog to select new status
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
