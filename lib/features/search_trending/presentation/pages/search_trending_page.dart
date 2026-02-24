import 'dart:math' show min;

import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_state.dart';
import 'package:PiliPlus/features/search_trending/presentation/providers/search_trending_controller.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTrendingPage extends ConsumerStatefulWidget {
  const SearchTrendingPage({super.key});

  @override
  ConsumerState<SearchTrendingPage> createState() => _SearchTrendingPageState();
}

class _SearchTrendingPageState extends ConsumerState<SearchTrendingPage> {
  final ScrollController _scrollController = ScrollController();
  late double _offset;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  double get _scrollRatio {
    if (!_scrollController.hasClients || _offset == 0) return 0;
    return (_scrollController.position.pixels / _offset).clamp(0.0, 1.0);
  }

  void _scrollListener() {
    if (mounted) {
      setState(() {}); // Trigger rebuild for scroll ratio
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    final size = context.mediaQuerySize;
    final maxWidth = size.width - padding.horizontal;
    final width = size.isPortrait ? maxWidth : min(640.0, maxWidth * 0.6);
    final height = width * 528 / 1125;
    _offset = height - 56 - padding.top;

    final controllerState = ref.watch(searchTrendingControllerProvider);
    final scrollRatio = _scrollRatio;
    final flag = maxWidth > width || scrollRatio >= 0.5;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          title: Opacity(
            opacity: scrollRatio,
            child: Text(
              'bilibili热搜',
              style: TextStyle(
                color: flag ? null : Colors.white,
              ),
            ),
          ),
          backgroundColor: theme.colorScheme.surface.withValues(
            alpha: scrollRatio,
          ),
          foregroundColor: flag ? null : Colors.white,
          systemOverlayStyle: flag
              ? null
              : const SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                ),
          shape: scrollRatio == 1
              ? Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(
                      alpha: 0.1,
                    ),
                  ),
                )
              : null,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: padding.left,
          right: padding.right,
        ),
        child: Center(
          child: SizedBox(
            width: width,
            child: refreshIndicator(
              onRefresh: () => ref
                  .read(searchTrendingControllerProvider.notifier)
                  .reload(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Image.asset(
                      width: width,
                      height: height,
                      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
                      'assets/images/trending_banner.png',
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: padding.bottom + 100),
                    sliver: _buildBody(theme, controllerState),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    SearchTrendingState state,
  ) {
    late final divider = Divider(
      height: 1,
      indent: 48,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );

    return switch (state.items) {
      Loading() => linearLoading,
      Success(:final response) => () {
          if (response == null || response.isEmpty) {
            return HttpError(
              onReload: () => ref
                  .read(searchTrendingControllerProvider.notifier)
                  .reload(),
            );
          }

          return SliverList.separated(
            itemCount: response.length,
            itemBuilder: (context, index) {
              final item = response[index];
              return ListTile(
                dense: true,
                onTap: () => Navigator.of(context).pushNamed(
                  '/searchResult',
                  arguments: {'keyword': item.keyword},
                ),
                leading: index < state.topCount
                    ? const Icon(
                        size: 17,
                        Icons.vertical_align_top_outlined,
                        color: Color(0xFFd1403e),
                      )
                    : Text(
                        '${index + 1 - state.topCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Utils.index2Color(
                            index - state.topCount,
                            theme.colorScheme.outline,
                          ),
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.keyword ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        strutStyle: const StrutStyle(height: 1, leading: 0),
                        style: const TextStyle(height: 1, fontSize: 15),
                      ),
                    ),
                    if (item.icon?.isNotEmpty == true) ...[
                      const SizedBox(width: 4),
                      CachedNetworkImage(
                        height: 16,
                        memCacheWidth: (16 * MediaQuery.of(context).devicePixelRatio).toInt(),
                        imageUrl: ImageUtils.thumbnailUrl(item.icon!),
                        placeholder: (_, _) => const SizedBox.shrink(),
                      ),
                    ] else if (item.showLiveIcon == true) ...[
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/live/live.gif',
                        width: 51,
                        height: 16,
                        cacheHeight: (16 * MediaQuery.of(context).devicePixelRatio).toInt(),
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => divider,
          );
        }(),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () => ref
            .read(searchTrendingControllerProvider.notifier)
            .reload(),
      ),
    };
  }
}
