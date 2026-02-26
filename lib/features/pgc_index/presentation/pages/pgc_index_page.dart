import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/self_sized_horizontal_list.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/pgc_index/domain/entities/pgc_index_item.dart';
import 'package:PiliPlus/features/pgc_index/presentation/providers/pgc_index_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/sort.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/value.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/features/pgc_index/presentation/widgets/pgc_card_v_pgc_index.dart';
import 'package:PiliPlus/features/search/presentation/widgets/search_text.dart';
import 'package:PiliPlus/utils/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PGC索引页面
///
/// 显示PGC内容(番剧/影视)的索引筛选和列表
class PgcIndexPage extends ConsumerStatefulWidget {
  const PgcIndexPage({super.key, this.indexType});

  final int? indexType;

  @override
  ConsumerState<PgcIndexPage> createState() => _PgcIndexPageState();
}

class _PgcIndexPageState extends ConsumerState<PgcIndexPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.indexType != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    ref.watch(pgcIndexControllerProvider(widget.indexType));
    final state = ref.watch(pgcIndexStateProvider(widget.indexType));

    return widget.indexType == null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('索引')),
            body: _buildBody(theme, state.conditionState),
          )
        : _buildBody(theme, state.conditionState);
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<PgcIndexConditionData> loadingState,
  ) {
    final padding = MediaQuery.viewPaddingOf(context);
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success(:final response) => Builder(
        builder: (context) {
          int count =
              (response.order?.isNotEmpty == true ? 1 : 0) +
              (response.filter?.length ?? 0);
          if (count == 0) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(left: padding.left, right: padding.right),
            child: CustomScrollView(
              slivers: [
                if (widget.indexType != null)
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: AnimatedSize(
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 200),
                    child: count > 5
                        ? _buildSortsWidgetWatched(theme, count, response)
                        : _buildSortsWidgetSimple(theme, count, response),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: StyleString.safeSpace,
                    right: StyleString.safeSpace,
                    top: 12,
                    bottom: padding.bottom + 100,
                  ),
                  sliver: _buildListWatched(),
                ),
              ],
            ),
          );
        },
      ),
      Error(:final errMsg) => scrollErrorWidget(
        errMsg: errMsg,
        onReload: () =>
            ref.read(pgcIndexControllerProvider(widget.indexType)).onReload(),
      ),
    };
  }

  Widget _buildSortWidget(
    ThemeData theme,
    int index,
    PgcIndexConditionData data,
    Object item,
    Map<String, dynamic> indexParams,
  ) {
    final controller = ref.read(pgcIndexControllerProvider(widget.indexType));
    if (item is PgcConditionOrder) {
      final isCurr = indexParams['order'] == item.field;
      return SearchText(
        bgColor: isCurr
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        textColor: isCurr
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant,
        text: item.name!,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        onTap: (_) => controller.updateParam('order', item.field),
      );
    }
    if (item is PgcConditionValue) {
      final hasOrder = data.order?.isNotEmpty == true;
      if (hasOrder) index -= 1;
      final key = data.filter![index].field!;
      final isCurr = indexParams[key] == item.keyword;
      return SearchText(
        bgColor: isCurr
            ? theme.colorScheme.secondaryContainer
            : Colors.transparent,
        textColor: isCurr
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant,
        text: item.name!,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        onTap: (_) => controller.updateParam(key, item.keyword),
      );
    }
    throw UnsupportedError(item.toString());
  }

  Widget _buildSortsWidgetWatched(
    ThemeData theme,
    int count,
    PgcIndexConditionData data,
  ) {
    final state = ref.watch(pgcIndexStateProvider(widget.indexType));
    final controller = ref.read(pgcIndexControllerProvider(widget.indexType));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          count > 5
              ? state.isExpand
                    ? count
                    : count ~/ 2
              : count,
          (index) {
            final isFirst = index == 0;
            List? item = data.order?.isNotEmpty == true
                ? isFirst
                      ? data.order
                      : data.filter![index - 1].values
                : data.filter![index].values;
            if (item != null && item.isNotEmpty) {
              return SelfSizedHorizontalList(
                padding: isFirst
                    ? const EdgeInsets.symmetric(horizontal: 12)
                    : const EdgeInsets.fromLTRB(12, 10, 12, 0),
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, childIndex) => _buildSortWidget(
                  theme,
                  index,
                  data,
                  item[childIndex],
                  state.indexParams,
                ),
                itemCount: item.length,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        if (count > 5) ...[
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.toggleExpand(),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.isExpand ? '收起' : '展开',
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Icon(
                    state.isExpand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSortsWidgetSimple(
    ThemeData theme,
    int count,
    PgcIndexConditionData data,
  ) {
    final state = ref.watch(pgcIndexStateProvider(widget.indexType));
    final controller = ref.read(pgcIndexControllerProvider(widget.indexType));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          count > 5
              ? state.isExpand
                    ? count
                    : count ~/ 2
              : count,
          (index) {
            final isFirst = index == 0;
            List? item = data.order?.isNotEmpty == true
                ? isFirst
                      ? data.order
                      : data.filter![index - 1].values
                : data.filter![index].values;
            if (item != null && item.isNotEmpty) {
              return SelfSizedHorizontalList(
                padding: isFirst
                    ? const EdgeInsets.symmetric(horizontal: 12)
                    : const EdgeInsets.fromLTRB(12, 10, 12, 0),
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, childIndex) => _buildSortWidget(
                  theme,
                  index,
                  data,
                  item[childIndex],
                  state.indexParams,
                ),
                itemCount: item.length,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        if (count > 5) ...[
          const SizedBox(height: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.toggleExpand(),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.isExpand ? '收起' : '展开',
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  Icon(
                    state.isExpand
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  late final gridDelegate = SliverGridDelegateWithExtentAndRatio(
    mainAxisSpacing: StyleString.cardSpace,
    crossAxisSpacing: StyleString.cardSpace,
    maxCrossAxisExtent: Grid.smallCardWidth * 0.6,
    childAspectRatio: 0.75,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(50),
  );

  Widget _buildListWatched() {
    final state = ref.watch(pgcIndexStateProvider(widget.indexType));
    return _buildList(state.loadingState);
  }

  Widget _buildList(LoadingState<List<PgcIndexItemEntity>?> loadingState) {
    final controller = ref.read(pgcIndexControllerProvider(widget.indexType));
    return switch (loadingState) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    controller.onLoadMore();
                  }
                  // Convert entity back to model for the widget
                  final item = response[index];
                  final model = PgcIndexItem(
                    seasonId: item.seasonId,
                    title: item.title,
                    cover: item.cover,
                    score: item.score,
                    indexShow: item.indexShow,
                    isFinish: item.isFinish,
                    seasonStatus: item.seasonStatus,
                  );
                  return PgcCardVPgcIndex(item: model);
                },
                itemCount: response.length,
              )
            : HttpError(
                onReload: controller.onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
