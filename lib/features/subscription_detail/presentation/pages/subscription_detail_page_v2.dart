import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/subscription_detail/presentation/providers/subscription_detail_controller.dart';
import 'package:PiliPlus/features/subscription_detail/presentation/providers/subscription_detail_providers.dart';
import 'package:PiliPlus/features/subscription_detail/presentation/widgets/sub_video_card.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:PiliPlus/models/sub/sub_detail/media.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/shared/skeleton/video_card_h.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/waterfall.dart';

/// Subscription Detail page - V2 with Riverpod
class SubscriptionDetailPageV2 extends ConsumerStatefulWidget {
  const SubscriptionDetailPageV2({
    super.key,
    required this.id,
    this.heroTag,
    this.subInfo,
  });

  final int id;
  final String? heroTag;
  final SubItemModel? subInfo;

  @override
  ConsumerState<SubscriptionDetailPageV2> createState() =>
      _SubscriptionDetailPageV2State();

  static void toSubDetailPage(
    int id, {
    String? heroTag,
    SubItemModel? subInfo,
  }) {
    PageUtils.pushNamed(AppRoutes.subDetail, extra: {
        'id': id,
        'subInfo': subInfo,
        'heroTag': heroTag,
      },
    );
  }
}

class _SubscriptionDetailPageV2State
    extends ConsumerState<SubscriptionDetailPageV2> {
  late final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 0,
    childAspectRatio: (16 / 9) * 2.2,
  );

  Widget get gridSkeleton => SliverGrid.builder(
    gridDelegate: gridDelegate,
    itemBuilder: (_, _) => const VideoCardHSkeleton(),
    itemCount: 10,
  );
  late final SubscriptionDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(
      subscriptionDetailControllerProvider(
        SubscriptionDetailParams(
          id: widget.id,
          initialSubInfo: widget.subInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);
    return Material(
      color: theme.colorScheme.surface,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          return refreshIndicator(
            onRefresh: _controller.onRefresh,
            child: CustomScrollView(
              controller: _controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _appBar(theme, padding),
                SliverPadding(
                  padding: EdgeInsets.only(
                    top: 7,
                    left: padding.left,
                    right: padding.right,
                    bottom: padding.bottom + 100,
                  ),
                  sliver: _buildBody(_controller.loadingState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(LoadingState<List<SubDetailItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => gridSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return SubVideoCardH(
                    videoItem: response[index],
                  );
                },
                itemCount: response.length,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _appBar(ThemeData theme, EdgeInsets padding) {
    final info = _controller.subInfo;
    if (info != null) return _buildAppBar(theme, padding, info);
    // Show loading app bar while data loads
    return switch (_controller.loadingState) {
      Loading() || Error() => const SliverAppBar(),
      Success() => _buildAppBar(
        theme,
        padding,
        _controller.subInfo!,
      ),
    };
  }

  Widget _buildAppBar(ThemeData theme, EdgeInsets padding, SubItemModel info) {
    final style = TextStyle(
      height: 1,
      fontSize: 12.5,
      color: theme.colorScheme.outline,
    );
    Widget cover = NetworkImgLayer(
      width: 176,
      height: 110,
      src: info.cover,
    );
    if (widget.heroTag != null) {
      cover = Hero(
        tag: widget.heroTag!,
        child: cover,
      );
    }
    return SliverAppBar.medium(
      expandedHeight: kToolbarHeight + 132,
      pinned: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            '共${info.mediaCount}条视频',
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            top: kToolbarHeight + padding.top + 10,
            left: 12 + padding.left,
            right: 12,
            bottom: 12,
          ),
          child: Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cover,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        info.title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          PageUtils.toMemberPage(info.upper!.mid!),
                      child: Text(
                        info.upper!.name!,
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('共${info.mediaCount}条视频', style: style),
                    const SizedBox(height: 4),
                    Text(
                      '${NumUtils.numFormat(info.viewCount ?? info.cntInfo?.play)}次播放',
                      style: style,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
