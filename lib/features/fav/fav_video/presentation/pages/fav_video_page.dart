import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/fav/fav_video/presentation/providers/fav_video_providers.dart';
import 'package:PiliPlus/features/fav/presentation/pages/video/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Favorite folders (video collections) page
class FavVideoPage extends ConsumerStatefulWidget {
  const FavVideoPage({super.key});

  @override
  ConsumerState<FavVideoPage> createState() => _FavVideoPageState();
}

class _FavVideoPageState extends ConsumerState<FavVideoPage>
    with AutomaticKeepAliveClientMixin, GridMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(favVideoControllerProvider);

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              top: 7,
              bottom: 100 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            sliver: _buildBody(controller.state.listState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LoadingState<List<FavFolderInfo>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (BuildContext context, int index) {
                  if (index == response.length - 1) {
                    ref.read(favVideoControllerProvider).onLoadMore();
                  }
                  final item = response[index];
                  String heroTag = Utils.makeHeroTag(item.fid);
                  return FavVideoItem(
                    heroTag: heroTag,
                    item: item,
                    onTap: () async {
                      final res = await PageUtils.pushNamed(AppRoutes.favDetail, extra: item,
                        parameters: {
                          'heroTag': heroTag,
                          'mediaId': item.id.toString(),
                        },
                      );
                      if (res == true) {
                        ref
                            .read(favVideoControllerProvider)
                            .removeFolder(index);
                      }
                    },
                  );
                },
                itemCount: response.length,
              )
            : HttpError(
                onReload: ref.read(favVideoControllerProvider).onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: ref.read(favVideoControllerProvider).onReload,
      ),
    };
  }
}
