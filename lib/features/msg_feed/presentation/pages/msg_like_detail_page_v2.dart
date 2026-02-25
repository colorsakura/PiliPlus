import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/msg_feed/presentation/controllers/msg_like_detail_controller.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/msg/msg_like_detail/card.dart';
import 'package:PiliPlus/models/msg/msg_like_detail/item.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart' show DateFormatUtils;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Like detail page - V2 Riverpod version
class LikeDetailPageV2 extends ConsumerStatefulWidget {
  const LikeDetailPageV2({
    super.key,
    required this.cardId,
    this.uri,
    required this.counts,
  });

  final String cardId;
  final String? uri;
  final int counts;

  @override
  ConsumerState<LikeDetailPageV2> createState() => _LikeDetailPageV2State();
}

class _LikeDetailPageV2State extends ConsumerState<LikeDetailPageV2> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(
            likeDetailControllerProvider((
              cardId: widget.cardId,
              uri: widget.uri,
              counts: widget.counts,
            )),
          )
          .queryData(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(
      likeDetailControllerProvider((
        cardId: widget.cardId,
        uri: widget.uri,
        counts: widget.counts,
      )),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('点赞详情')),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: _buildBody(theme, controller.state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LikeDetailState state,
    LikeDetailController controller,
  ) {
    final divider = Divider(
      indent: 72,
      endIndent: 20,
      height: 6,
      color: Colors.grey.withValues(alpha: 0.1),
    );

    return switch (state.loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
      ),
      Success() => SliverMainAxisGroup(
        slivers: [
          if (state.card != null) ...[
            _buildCard(state.card!, state.uri),
            SliverToBoxAdapter(
              child: Divider(
                height: 1,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ],
          SliverList.separated(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              if (index == state.items.length - 1 && !state.isEnd) {
                controller.onLoadMore();
              }
              return _buildItem(theme, state.items[index]);
            },
            separatorBuilder: (context, index) => divider,
          ),
        ],
      ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onRefresh,
      ),
    };
  }

  Widget _buildCard(MsgLikeDetailCard card, String? uri) {
    return SliverToBoxAdapter(
      child: ListTile(
        onTap: () {
          if (uri != null) {
            PiliScheme.routePushFromUrl(uri);
          }
        },
        title: Text('${card.business}: ${card.title}'),
      ),
    );
  }

  Widget _buildItem(ThemeData theme, MsgLikeDetailItem item) {
    return ListTile(
      onTap: () =>
          Navigator.of(context).pushNamed('/member?mid=${item.user!.mid}'),
      leading: NetworkImgLayer(
        width: 45,
        height: 45,
        type: ImageType.avatar,
        src: item.user!.avatar,
      ),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "${item.user!.nickname}",
              style: theme.textTheme.titleSmall!.copyWith(
                height: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            TextSpan(
              text: " 赞了我",
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormatUtils.dateFormat(item.likeTime ?? 0),
        style: theme.textTheme.bodyMedium!.copyWith(
          fontSize: 13,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }
}
