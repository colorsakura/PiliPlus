import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';
import 'package:PiliPlus/features/fav/presentation/pages/fav_article_controller.dart';
import 'package:PiliPlus/features/fav/fav_article/presentation/widgets/fav_article_item.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavArticlePage extends StatefulWidget {
  const FavArticlePage({super.key});

  @override
  State<FavArticlePage> createState() => _FavArticlePageState();
}

class _FavArticlePageState extends State<FavArticlePage>
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
  final FavArticleController _favArticleController = Get.put(
    FavArticleController(),
  );

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return refreshIndicator(
      onRefresh: _favArticleController.onRefresh,
      child: CustomScrollView(
        controller: _favArticleController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: Obx(
              () => _buildBody(_favArticleController.loadingState.value),
            ),
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
                    _favArticleController.onLoadMore();
                  }
                  final item = response[index];
                  return FavArticleItem(
                    item: item,
                    onDelete: () => showConfirmDialog(
                      context: context,
                      title: '确定取消收藏？',
                      onConfirm: () =>
                          _favArticleController.onRemove(index, item.opusId!),
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _favArticleController.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _favArticleController.onReload,
      ),
    };
  }
}
