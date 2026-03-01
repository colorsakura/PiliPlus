import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/later/domain/entities/later_item.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';
import 'package:PiliPlus/features/later/presentation/providers/later_controller.dart';
import 'package:PiliPlus/features/later/presentation/widgets/later_video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 稍后再看子页面
class LaterChildPage extends ConsumerStatefulWidget {
  const LaterChildPage({
    super.key,
    required this.viewType,
  });

  final LaterViewType viewType;

  @override
  ConsumerState<LaterChildPage> createState() => _LaterChildPageState();
}

class _LaterChildPageState extends ConsumerState<LaterChildPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(laterControllerProvider(widget.viewType));
    final notifier = ref.read(laterControllerNotifierProvider(widget.viewType));
    final scrollController = notifier.scrollController;

    return refreshIndicator(
      onRefresh: () => ref
          .read(laterControllerNotifierProvider(widget.viewType))
          .onRefresh(widget.viewType),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 85,
            ),
            sliver: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LaterState state) {
    if (state.isLoading && state.items.isEmpty) {
      return gridSkeleton;
    }

    if (state.errorMessage != null) {
      return HttpError(
        errMsg: state.errorMessage!,
        onReload: () => ref
            .read(laterControllerNotifierProvider(widget.viewType))
            .onRefresh(widget.viewType),
      );
    }

    if (state.items.isEmpty) {
      return const HttpError(
        errMsg: '暂无数据',
      );
    }

    return SliverGrid.builder(
      gridDelegate: gridDelegate,
      itemBuilder: (context, index) {
        final videoItem = state.items[index];

        // 在倒数第二个触发加载更多
        if (index == state.items.length - 2) {
          Future.microtask(() {
            ref
                .read(laterControllerNotifierProvider(widget.viewType))
                .onLoadMore(widget.viewType);
          });
        }

        return LaterVideoCard(
          videoItem: videoItem,
          onDelete: () => _showDeleteDialog(videoItem, index),
        );
      },
      itemCount: state.items.length,
    );
  }

  void _showDeleteDialog(LaterItemEntity item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('即将移除该视频，确定是否移除'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref
                  .read(laterControllerNotifierProvider(widget.viewType))
                  .removeItem(item.aid.toString(), widget.viewType);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              }
            },
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
  }
}
