import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/fav/fav_cheese/presentation/providers/fav_cheese_providers.dart';
import 'package:PiliPlus/features/member_cheese/presentation/widgets/item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/utils/styles/constants.dart';
import 'package:PiliPlus/shared/widgets/skeleton/video_card_h_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite cheese (courses) page
class FavCheesePage extends ConsumerStatefulWidget {
  const FavCheesePage({super.key});

  @override
  ConsumerState<FavCheesePage> createState() => _FavCheesePageState();
}

class _FavCheesePageState extends ConsumerState<FavCheesePage>
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
    final controller = ref.watch(favCheeseControllerProvider);

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

  Widget _buildBody(LoadingState<List<SpaceCheeseItem>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    ref.read(favCheeseControllerProvider).onLoadMore();
                  }
                  final item = response[index];
                  return MemberCheeseItem(
                    item: item,
                    onRemove: () => showConfirmDialog(
                      context: context,
                      title: '确定取消收藏该课堂？',
                      onConfirm: () => _onRemove(index, item.seasonId!),
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(
                onReload: ref.read(favCheeseControllerProvider).onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: ref.read(favCheeseControllerProvider).onReload,
      ),
    };
  }

  Future<void> _onRemove(int index, int sid) async {
    final controller = ref.read(favCheeseControllerProvider);
    final success = await controller.removeCheese(index, sid);
    if (success) {
      // Show success message or handle UI update
    }
  }
}
