import 'package:PiliPlus/common/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/msg/msg_reply/item.dart';
import 'package:PiliPlus/features/msg_feed/presentation/controllers/msg_feed_controllers.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart' show DateFormatUtils;
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reply to me page - V2 Riverpod version
class MsgReplyMePageV2 extends ConsumerStatefulWidget {
  const MsgReplyMePageV2({super.key});

  @override
  ConsumerState<MsgReplyMePageV2> createState() => _MsgReplyMePageV2State();
}

class _MsgReplyMePageV2State extends ConsumerState<MsgReplyMePageV2> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(msgReplyMeControllerProvider).queryData(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('收到的回复')),
      body: refreshIndicator(
        onRefresh: () => ref.read(msgReplyMeControllerProvider).onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: Consumer(
                builder: (context, ref, child) {
                  final controller = ref.watch(msgReplyMeControllerProvider);
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
    MsgReplyMeController controller,
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
        response != null && response.isNotEmpty
            ? SliverList.separated(
                itemCount: response.length,
                itemBuilder: (context, int index) {
                  if (index == response.length - 1 && !controller.state.isEnd) {
                    controller.queryData(isRefresh: false);
                  }
                  final item = response[index];
                  void onLongPress() => showConfirmDialog(
                    context: context,
                    title: '确定删除该通知?',
                    onConfirm: () => controller.onRemove(item.id!, index),
                  );

                  return ListTile(
                    onLongPress: onLongPress,
                    leading: NetworkImgLayer(
                      type: ImageType.avatar,
                      src: item.user?.face ?? '',
                      width: 45,
                      height: 45,
                    ),
                    title: Text(
                      item.user?.nickname ?? '',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.item?.desc ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          item.item?.sourceContent ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    trailing: _buildTrailing(item, theme),
                    onTap: () => _handleItemClick(context, item),
                  );
                },
                separatorBuilder: (context, index) => divider,
              )
            : const HttpError(
                errMsg: '暂无消息',
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
      ),
    };
  }

  Widget _buildTrailing(MsgReplyItem item, ThemeData theme) {
    final time = DateFormatUtils.dateFormat(item.replyTime ?? 0);
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
      ],
    );
  }

  void _handleItemClick(BuildContext context, MsgReplyItem item) {
    final String? uri = item.item?.uri;
    if (uri != null) {
      final parsed = Uri.tryParse(uri);
      if (parsed != null && parsed.scheme.contains('bili')) {
        PiliScheme.routePushFromUrl(parsed.toString());
      }
    }
  }
}
