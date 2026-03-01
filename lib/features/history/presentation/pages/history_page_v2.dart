import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/history/domain/entities/history_item.dart';
import 'package:PiliPlus/features/history/presentation/providers/history_controller.dart';
import 'package:PiliPlus/features/history/presentation/providers/history_multi_select_provider.dart';
import 'package:PiliPlus/features/history/presentation/widgets/history_item_adapter.dart';
import 'package:PiliPlus/features/history/presentation/widgets/item_v2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// 历史记录页面 V2 - Riverpod 版本
class HistoryPageV2 extends ConsumerStatefulWidget {
  const HistoryPageV2({super.key, this.type});

  final String? type;

  @override
  ConsumerState<HistoryPageV2> createState() => _HistoryPageV2State();
}

class _HistoryPageV2State extends ConsumerState<HistoryPageV2> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize on first build
    if (!_hasInitialized) {
      _hasInitialized = true;
      // Trigger initial data load
      Future.microtask(() {
        ref
            .read(historyControllerNotifierProvider(widget.type))
            .initialize(type: widget.type);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyControllerProvider(widget.type));
    final multiSelectController = ref.watch(
      historyMultiSelectControllerProvider,
    );
    final padding = MediaQuery.viewPaddingOf(context);
    final gridDelegate = Grid.videoCardHDelegate(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('历史记录'),
        actions: [
          if (state.items.any((item) => item.isViewed))
            TextButton(
              onPressed: () async {
                final success = await ref
                    .read(historyControllerNotifierProvider(widget.type))
                    .deleteViewedHistory();
                if (success && mounted) {
                  ToastUtils.showToast('已删除');
                }
              },
              child: const Text('清除已看'),
            ),
        ],
      ),
      body: refreshIndicator(
        onRefresh: () => ref
            .read(historyControllerNotifierProvider(widget.type))
            .onRefresh(type: widget.type),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: 7,
                bottom: padding.bottom + 100,
              ),
              sliver: _buildBody(
                state,
                gridDelegate,
                widget.type,
                multiSelectController,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    HistoryState state,
    gridDelegate,
    String? type,
    multiSelectController,
  ) {
    if (state.isLoading && state.result == null) {
      return SliverGrid.builder(
        gridDelegate: gridDelegate,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    if (state.errorMessage != null && state.result == null) {
      return HttpError(
        errMsg: state.errorMessage,
        onReload: () => ref
            .read(historyControllerNotifierProvider(type))
            .onReload(type: type),
      );
    }

    final items = state.items;

    if (items.isEmpty) {
      return HttpError(
        onReload: () => ref
            .read(historyControllerNotifierProvider(type))
            .onReload(type: type),
      );
    }

    // Use SliverGrid like the original page
    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemCount: items.length,
      itemBuilder: (context, index) {
        if (index == items.length - 1) {
          Future.microtask(
            () => ref
                .read(historyControllerNotifierProvider(type))
                .onLoadMore(type: type),
          );
        }

        final item = items[index];
        final model = adaptHistoryItemEntity(item);

        return HistoryItemV2(
          item: model,
          ctr: multiSelectController,
          onDelete: (kid, business) => _handleDelete(item, type),
        );
      },
    );
  }

  Future<void> _handleDelete(HistoryItemEntity item, String? type) async {
    final success = await ref
        .read(historyControllerNotifierProvider(type))
        .deleteHistory([item.deleteKey]);
    if (success && mounted) {
      ToastUtils.showToast('已删除');
    }
  }
}
