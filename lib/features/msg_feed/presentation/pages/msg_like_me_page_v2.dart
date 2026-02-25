import 'package:PiliPlus/common/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/msg/msg_like/item.dart';
import 'package:PiliPlus/features/msg_feed/presentation/controllers/msg_feed_controllers.dart';
import 'package:PiliPlus/utils/app_scheme.dart' as app_scheme;
import 'package:PiliPlus/utils/date_utils.dart' show DateFormatUtils;
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Like me page - V2 Riverpod version
class MsgLikeMePageV2 extends ConsumerStatefulWidget {
  const MsgLikeMePageV2({super.key});

  @override
  ConsumerState<MsgLikeMePageV2> createState() => _MsgLikeMePageV2State();
}

class _MsgLikeMePageV2State extends ConsumerState<MsgLikeMePageV2> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(msgLikeMeControllerProvider).queryData(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('收到的赞')),
      body: refreshIndicator(
        onRefresh: () => ref.read(msgLikeMeControllerProvider).onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: Consumer(
                builder: (context, ref, child) {
                  final controller = ref.watch(msgLikeMeControllerProvider);
                  return _buildBody(theme, controller.state.loadingState, controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState loadingState,
    MsgLikeMeController controller,
  ) {
    final divider = Divider(
      indent: 72,
      endIndent: 20,
      height: 6,
      color: Colors.grey.withValues(alpha: 0.1),
    );

    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
      ),
      Success(:final response) =>
        response != null &&
                (response.first.isNotEmpty || response.second.isNotEmpty)
            ? SliverList.separated(
                itemCount: response.first.length + response.second.length,
                itemBuilder: (context, int index) {
                  // Determine if we should load more
                  if (index == response.first.length + response.second.length - 1 &&
                      !controller.state.isEnd) {
                    controller.queryData(isRefresh: false);
                  }

                  // Check if item is from latest or total
                  final isLatest = index < response.first.length;
                  final item = isLatest
                      ? response.first[index]
                      : response.second[index - response.first.length];

                  void onLongPress() => showConfirmDialog(
                    context: context,
                    title: '确定删除该通知?',
                    onConfirm: () =>
                        controller.onRemove(item.id!, isLatest ? index : index - response.first.length, isLatest),
                  );

                  final hasNotice = item.noticeState != null;

                  return ListTile(
                    onLongPress: onLongPress,
                    leading: NetworkImgLayer(
                      type: ImageType.avatar,
                      src: item.users?.first.face ?? '',
                      width: 45,
                      height: 45,
                    ),
                    title: Text(
                      item.users?.first.nickname ?? '',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.desc ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item.content ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: _buildTrailing(item, theme, hasNotice, controller),
                    onTap: () => _handleItemClick(context, item),
                  );
                },
                separatorBuilder: (context, index) {
                  // Add divider between latest and total sections
                  if (index == response.first.length - 1 && response.second.isNotEmpty) {
                    return const Divider(height: 20);
                  }
                  return divider;
                },
              )
            : const HttpError(
                errMsg: '暂无消息',
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
      ),
    };
  }

  Widget _buildTrailing(
    MsgLikeItem item,
    ThemeData theme,
    bool hasNotice,
    MsgLikeMeController controller,
  ) {
    final time = DateFormatUtils.dateFormat(item.likeTime ?? 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        if (hasNotice)
          IconButton(
            icon: Icon(
              item.noticeState == 1 ? Icons.notifications : Icons.notifications_none,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            onPressed: () => controller.onSetNotice(item, item.noticeState == 0),
          ),
      ],
    );
  }

  void _handleItemClick(BuildContext context, MsgLikeItem item) {
    final String? uri = item.item?.nativeUri;
    if (uri != null && uri.isNotEmpty && !uri.startsWith('?')) {
      app_scheme.PiliScheme.routePushFromUrl(uri);
    }
  }
}
