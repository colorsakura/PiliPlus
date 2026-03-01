import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/fav/fav_article/presentation/providers/fav_article_providers.dart';
import 'package:PiliPlus/features/fav/fav_article/presentation/widgets/fav_article_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite articles page
class FavArticlePage extends ConsumerStatefulWidget {
  const FavArticlePage({super.key});

  @override
  ConsumerState<FavArticlePage> createState() => _FavArticlePageState();
}

class _FavArticlePageState extends ConsumerState<FavArticlePage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(favArticleControllerProvider);

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(controller.state.listState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<FavArticleItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    ref.read(favArticleControllerProvider).onLoadMore();
                  }
                  final item = response[index];
                  return FavArticleItem(
                    item: item,
                    onDelete: () => showConfirmDialog(
                      context: context,
                      title: '确定取消收藏？',
                      onConfirm: () => _onRemove(index, item.opusId!),
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(
                onReload: ref.read(favArticleControllerProvider).onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: ref.read(favArticleControllerProvider).onReload,
      ),
    };
  }

  Future<void> _onRemove(int index, String opusId) async {
    final controller = ref.read(favArticleControllerProvider);
    final success = await controller.removeArticle(index, opusId);
    if (success) {
      // Show success message or handle UI update
    }
  }
}
