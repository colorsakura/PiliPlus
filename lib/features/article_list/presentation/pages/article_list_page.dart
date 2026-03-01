import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/article_list/presentation/providers/article_list_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/article_list/presentation/widgets/item.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

/// Article list page
///
/// Displays a list of articles for a given collection
class ArticleListPage extends ConsumerStatefulWidget {
  const ArticleListPage({super.key});

  @override
  ConsumerState<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends ConsumerState<ArticleListPage> {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );

  Widget get gridSkeletonWithPadding => SliverPadding(
    padding: EdgeInsets.only(
      top: padding.top + kToolbarHeight + 120,
    ),
    sliver: gridSkeleton,
  );

  late final String _id;
  late EdgeInsets padding;

  @override
  void initState() {
    super.initState();
    // Get ID from route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        setState(() {
          _id = args;
        });
        // Trigger data load
        ref.read(articleListControllerProvider.notifier).setId(_id);
      }
    });
    _id = '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    padding = MediaQuery.viewPaddingOf(context);

    return Material(
      color: theme.colorScheme.surface,
      child: refreshIndicator(
        onRefresh: () =>
            ref.read(articleListControllerProvider.notifier).onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
                bottom: padding.bottom + 100,
              ),
              sliver: _buildBody(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    final state = ref.watch(articleListControllerProvider);

    return switch (state.loadingState) {
      Loading() => gridSkeletonWithPadding,
      Success(:final response) =>
        response.items.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) =>
                    ArticleListItem(item: response.items[index]),
                itemCount: response.items.length,
              )
            : HttpError(
                onReload: () =>
                    ref.read(articleListControllerProvider.notifier).onReload(),
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () =>
            ref.read(articleListControllerProvider.notifier).onReload(),
      ),
    };
  }
}
