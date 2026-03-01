import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/fav/fav_topic/presentation/providers/fav_topic_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:flutter/material.dart'
    hide SliverGridDelegateWithMaxCrossAxisExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Favorite topics page
class FavTopicPage extends ConsumerStatefulWidget {
  const FavTopicPage({super.key});

  @override
  ConsumerState<FavTopicPage> createState() => _FavTopicPageState();
}

class _FavTopicPageState extends ConsumerState<FavTopicPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final controller = ref.watch(favTopicControllerProvider);

    return refreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: StyleString.safeSpace,
              right: StyleString.safeSpace,
              top: StyleString.safeSpace,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
            ),
            sliver: _buildBody(theme, controller.state.listState),
          ),
        ],
      ),
    );
  }

  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    maxCrossAxisExtent: Grid.smallCardWidth,
    mainAxisExtent: MediaQuery.textScalerOf(context).scale(30),
  );

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<FavTopicItem>?> loadingState,
  ) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(
        child: SizedBox(
          height: 125,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    ref.read(favTopicControllerProvider).onLoadMore();
                  }
                  final item = response[index];

                  void onLongPress() => showConfirmDialog(
                    context: context,
                    title: '确定取消收藏？',
                    onConfirm: () => _onRemove(index, item.id!),
                  );

                  return Material(
                    color: theme.colorScheme.onInverseSurface,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    child: InkWell(
                      onTap: () => PageUtils.pushNamed(AppRoutes.dynTopic, parameters: {
                          'id': item.id!.toString(),
                          'name': item.name!,
                        },
                      ),
                      onLongPress: onLongPress,
                      onSecondaryTap: PlatformUtils.isMobile
                          ? null
                          : onLongPress,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(6),
                      ),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        child: Text(
                          '# ${item.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: response.length,
              )
            : HttpError(
                onReload: ref.read(favTopicControllerProvider).onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: ref.read(favTopicControllerProvider).onReload,
      ),
    };
  }

  Future<void> _onRemove(int index, int id) async {
    final controller = ref.read(favTopicControllerProvider);
    final success = await controller.removeTopic(index, id);
    if (success) {
      // Show success message or handle UI update
    }
  }
}
