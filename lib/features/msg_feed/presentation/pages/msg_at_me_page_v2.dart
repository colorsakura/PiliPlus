import 'package:PiliPlus/common/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/common/widgets/dialog/dialog.dart';
import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/grpc/bilibili/app/im/v1.pbenum.dart'
    show IMSettingType;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/msg/msg_at/item.dart';
import 'package:PiliPlus/features/msg_feed/presentation/controllers/msg_feed_controllers.dart';
import 'package:PiliPlus/features/whisper_settings/whisper_settings.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/date_utils.dart' show DateFormatUtils;
import 'package:PiliPlus/utils/platform_utils.dart';

// Import PiliScheme correctly
import 'package:PiliPlus/utils/app_scheme.dart' as app_scheme;
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// @Me notifications page - V2 Riverpod version
class MsgAtMePageV2 extends ConsumerStatefulWidget {
  const MsgAtMePageV2({super.key});

  @override
  ConsumerState<MsgAtMePageV2> createState() => _MsgAtMePageV2State();
}

class _MsgAtMePageV2State extends ConsumerState<MsgAtMePageV2> {
  @override
  void initState() {
    super.initState();
    // Initial data load
    Future.microtask(() {
      ref.read(msgAtMeControllerProvider).queryData(isRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('@我的'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const WhisperSettingsPage(
                  imSettingType: IMSettingType.SETTING_TYPE_OLD_AT_ME,
                ),
              ),
            ),
            icon: Icon(
              size: 20,
              Icons.settings,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: refreshIndicator(
        onRefresh: () =>
            ref.read(msgAtMeControllerProvider).onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: Consumer(
                builder: (context, ref, child) {
                  final controller = ref.watch(msgAtMeControllerProvider);
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
    MsgAtMeController controller,
  ) {
    late final divider = Divider(
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

                  final itemType = item.item?.type;
                  return ListTile(
                    onLongPress: onLongPress,
                    leading: NetworkImgLayer(
                      type: ImageType.avatar,
                      src: item.user?.face ?? '',
                      width: 45,
                      height: 45,
                    ),
                    title: Text(
                      itemType == 2
                          ? item.reply?.nickname ?? ''
                          : item.user?.nickname ?? '',
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemType == 2) ...[
                          if (item.reply?.content != null)
                            Text(
                              item.reply!.content!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                        ] else ...[
                          Text(
                            item.item?.title ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
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

  Widget _buildTrailing(MsgAtItem item, ThemeData theme) {
    final time = DateFormatUtils.dateFormat(item.atTime ?? 0);
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
        const SizedBox(height: 4),
        if (item.item?.type == 0 ||
            item.item?.type == 1 ||
            item.item?.type == 3)
          Image.asset(
            'assets/images/bili_${item.item?.business}.png',
            width: 20,
            height: 20,
          ),
      ],
    );
  }

  void _handleItemClick(BuildContext context, MsgAtItem item) {
    final String? uri = item.item?.nativeUri;
    if (uri != null && uri.isNotEmpty && !uri.startsWith('?')) {
      app_scheme.PiliScheme.routePushFromUrl(uri);
    }
  }
}
