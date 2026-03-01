import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/custom_icon.dart';
import 'package:PiliPlus/shared/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/flutter/selectable_text/selectable_text.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/pgc_review/presentation/pages/post/view.dart';
import 'package:PiliPlus/features/pgc_review/presentation/providers/pgc_review_controller.dart';
import 'package:PiliPlus/features/pgc_review/presentation/providers/pgc_review_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/common/pgc_review_type.dart';
import 'package:PiliPlus/models/pgc/pgc_review/list.dart';
import 'package:PiliPlus/shared/skeleton/video_reply.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide SelectableText;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// PGC Review page - V2 with Riverpod
class PgcReviewPageV2 extends ConsumerStatefulWidget {
  const PgcReviewPageV2({
    super.key,
    required this.type,
    required this.name,
    required this.mediaId,
  });

  final PgcReviewType type;
  final String name;
  final dynamic mediaId;

  @override
  ConsumerState<PgcReviewPageV2> createState() => _PgcReviewPageV2State();
}

class _PgcReviewPageV2State extends ConsumerState<PgcReviewPageV2>
    with AutomaticKeepAliveClientMixin {
  late final PgcReviewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(
      pgcReviewControllerProvider(
        PgcReviewParams(
          type: widget.type,
          mediaId: widget.mediaId,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return refreshIndicator(
          onRefresh: _controller.onRefresh,
          child: CustomScrollView(
            controller: _controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildHeader(theme),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
                ),
                sliver: _buildBody(theme, _controller.loadingState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<PgcReviewItemModel>?> loadingState,
  ) {
    late final divider = Divider(
      height: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    return switch (loadingState) {
      Loading() => SliverPrototypeExtentList.builder(
        prototypeItem: const VideoReplySkeleton(),
        itemBuilder: (_, _) => const VideoReplySkeleton(),
        itemCount: 8,
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.separated(
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return _itemWidget(theme, index, response[index]);
                },
                itemCount: response.length,
                separatorBuilder: (context, index) => divider,
              )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _itemWidget(ThemeData theme, int index, PgcReviewItemModel item) {
    final isLongReview = widget.type == PgcReviewType.long;

    void showMore() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.author!.mid == Accounts.main.mid) ...[
              ListTile(
                dense: true,
                title: const Text(
                  '编辑',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  PageUtils.pop();
                  showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    isScrollControlled: true,
                    builder: (context) {
                      return PgcReviewPostPanel(
                        name: widget.name,
                        mediaId: widget.mediaId,
                        reviewId: item.reviewId,
                        content: item.content,
                        score: item.score,
                      );
                    },
                  );
                },
              ),
              ListTile(
                dense: true,
                title: const Text(
                  '删除',
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  PageUtils.pop();
                  showConfirmDialog(
                    context: context,
                    title: '删除短评，同时删除评分？',
                    onConfirm: () {
                      _controller.onDel(index, item.reviewId!);
                      setState(() {}); // Refresh UI
                    },
                  );
                },
              ),
            ],
            ListTile(
              dense: true,
              title: const Text(
                '举报',
                style: TextStyle(fontSize: 14),
              ),
              onTap: () => Get
                ..back()
                ..toNamed(
                  '/webview',
                  parameters: {
                    'url':
                        'https://www.bilibili.com/appeal/?reviewId=${item.reviewId}&type=shortComment&mediaId=${widget.mediaId}',
                  },
                ),
            ),
          ],
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: isLongReview
            ? () => PageUtils.pushNamed(AppRoutes.articlePage, parameters: {
                  'id': item.articleId!.toString(),
                  'type': 'read',
                },
              )
            : null,
        onLongPress: !isLongReview ? showMore : null,
        onSecondaryTap: !isLongReview && !PlatformUtils.isMobile
            ? showMore
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => PageUtils.toMemberPage(item.author!.mid!),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NetworkImgLayer(
                      height: 34,
                      width: 34,
                      src: item.author!.avatar,
                      type: ImageType.avatar,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      spacing: 2,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: 6,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.author!.uname!,
                              style: TextStyle(
                                color:
                                    item.author?.vip?.status != null &&
                                        item.author!.vip!.status > 0 &&
                                        item.author!.vip!.type == 2
                                    ? Colors.amber
                                    : theme.colorScheme.outline,
                                fontSize: 13,
                              ),
                            ),
                            Image.asset(
                              Utils.levelName(item.author!.level!),
                              height: 11,
                              cacheHeight: 11.cacheSize(context),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (item.pushTimeStr != null) ...[
                              Text(
                                item.pushTimeStr!,
                                style: TextStyle(
                                  color: theme.colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            ...List.generate(
                              5,
                              (index) {
                                if (index <= item.score - 1) {
                                  return const Icon(
                                    CustomIcons.star_favorite_solid,
                                    size: 13,
                                    color: Color(0xFFFFAD35),
                                  );
                                }
                                return const Icon(
                                  CustomIcons.star_favorite_line,
                                  size: 14,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              if (item.title != null)
                Text(
                  item.title!,
                  style: const TextStyle(
                    height: 1.75,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (isLongReview)
                Text(
                  item.content!,
                  style: const TextStyle(height: 1.75),
                )
              else
                SelectableText(
                  item.content!,
                  style: const TextStyle(height: 1.75),
                ),
              Builder(
                builder: (context) {
                  final Color color = theme.colorScheme.outline;
                  final Color primary = theme.colorScheme.primary;
                  final ButtonStyle style = TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                  final isLike = item.stat?.liked == 1;
                  final isDislike = item.stat?.disliked == 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isLongReview)
                        SizedBox(
                          height: 32,
                          child: TextButton(
                            style: style,
                            onPressed: () async {
                              await _controller.onDislike(
                                item,
                                isDislike,
                                item.reviewId,
                              );
                              setState(() {}); // Refresh UI
                            },
                            child: Icon(
                              isDislike
                                  ? FontAwesomeIcons.solidThumbsDown
                                  : FontAwesomeIcons.thumbsDown,
                              size: 16,
                              color: isDislike ? primary : color,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 32,
                        child: TextButton(
                          style: style,
                          onPressed: isLongReview
                              ? null
                              : () async {
                                  await _controller.onLike(
                                    item,
                                    isLike,
                                    item.reviewId,
                                  );
                                  setState(() {}); // Refresh UI
                                },
                          child: Row(
                            spacing: 4,
                            children: [
                              Icon(
                                isLike
                                    ? FontAwesomeIcons.solidThumbsUp
                                    : FontAwesomeIcons.thumbsUp,
                                size: 16,
                                color: isLike ? primary : color,
                              ),
                              Text(
                                NumUtils.numFormat(item.stat?.likes ?? 0),
                                style: TextStyle(
                                  color: isLike ? primary : color,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => SliverPersistentHeader(
    pinned: false,
    floating: true,
    delegate: CustomSliverPersistentHeaderDelegate(
      extent: 40,
      bgColor: theme.colorScheme.surface,
      child: Container(
        height: 40,
        padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_controller.count == null)
              const SizedBox.shrink()
            else
              Text(
                '${NumUtils.numFormat(_controller.count!)}条点评',
                style: const TextStyle(fontSize: 13),
              ),
            SizedBox(
              height: 35,
              child: TextButton.icon(
                onPressed: () {
                  _controller.queryBySort();
                  setState(() {}); // Refresh UI
                },
                icon: Icon(
                  Icons.sort,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                label: Text(
                  _controller.sortType.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
