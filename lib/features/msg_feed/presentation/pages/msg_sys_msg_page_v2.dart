import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/msg_feed/presentation/controllers/msg_feed_controllers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_sys/data.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart' show DateFormatUtils;
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// System messages page - V2 Riverpod version
class MsgSysMsgPageV2 extends ConsumerStatefulWidget {
  const MsgSysMsgPageV2({super.key});

  @override
  ConsumerState<MsgSysMsgPageV2> createState() => _MsgSysMsgPageV2State();
}

class _MsgSysMsgPageV2State extends ConsumerState<MsgSysMsgPageV2> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(msgSysMsgControllerProvider).queryData(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('系统消息')),
      body: refreshIndicator(
        onRefresh: () => ref.read(msgSysMsgControllerProvider).onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: Consumer(
                builder: (context, ref, child) {
                  final controller = ref.watch(msgSysMsgControllerProvider);
                  return _buildBody(controller.state.loadingState, controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LoadingState loadingState, MsgSysMsgController controller) {
    return switch (loadingState) {
      Loading() => SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length,
                itemBuilder: (context, int index) {
                  final item = response[index];
                  void onLongPress() => showConfirmDialog(
                    context: context,
                    title: '确定删除该通知?',
                    onConfirm: () => controller.onRemove(item.id!, index),
                  );

                  return ListTile(
                    onLongPress: onLongPress,
                    title: Text(item.title ?? ''),
                    subtitle: Text(
                      item.content ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      DateFormatUtils.dateFormat(
                        int.tryParse(item.timeAt ?? '0') ?? 0,
                      ),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => _handleItemClick(context, item),
                  );
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

  void _handleItemClick(BuildContext context, MsgSysItem item) {
    final String? link = item.cardLink;
    if (link != null) {
      PiliScheme.routePushFromUrl(link);
    }
  }
}
