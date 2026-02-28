import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_item.dart';
import 'package:PiliPlus/features/blacklist/presentation/providers/blacklist_controller.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/shared/skeleton/msg_feed_top.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// 黑名单管理页面
///
/// 使用 Clean Architecture + Riverpod 重构
class BlacklistPage extends ConsumerStatefulWidget {
  const BlacklistPage({super.key});

  @override
  ConsumerState<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends ConsumerState<BlacklistPage> {
  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blacklistControllerProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    // 保存黑名单用户ID到全局状态
    final state = ref.read(blacklistControllerProvider);
    final blackMids = state.result?.items.map((e) => e.mid).toSet() ?? {};
    GlobalData().blackMids = blackMids;
    Pref.blackMids = blackMids;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blacklistControllerProvider);
    final controller = ref.read(blacklistControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '黑名单管理${state.total == 0 ? '' : ': ${state.total}'}',
        ),
      ),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
              ),
              sliver: _buildBody(state, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BlacklistState state, BlacklistController controller) {
    if (state.isLoading && state.result == null) {
      return SliverList.builder(
        itemCount: 12,
        itemBuilder: (context, index) => const MsgFeedTopSkeleton(),
      );
    }

    if (state.errorMessage != null && state.result == null) {
      return HttpError(
        errMsg: state.errorMessage,
        onReload: controller.onReload,
      );
    }

    final items = state.items;

    if (items.isEmpty) {
      return HttpError(onReload: controller.onReload);
    }

    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        // 在最后一个item时加载更多
        if (index == items.length - 1) {
          Future.microtask(() => controller.onLoadMore());
        }

        final item = items[index];
        return _buildListItem(item, index, controller);
      },
    );
  }

  Widget _buildListItem(
    BlacklistItemEntity item,
    int index,
    BlacklistController controller,
  ) {
    final style = TextStyle(color: Theme.of(context).colorScheme.outline);

    return ListTile(
      visualDensity: VisualDensity.standard,
      onTap: () => PageUtils.toMemberPage(item.mid!),
      leading: NetworkImgLayer(
        width: 45,
        height: 45,
        type: ImageType.avatar,
        src: item.face,
      ),
      title: Text(
        item.uname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '添加时间: ${DateFormatUtils.format(item.mtime, format: DateFormatUtils.longFormatDs)}',
        maxLines: 1,
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
      dense: true,
      trailing: TextButton(
        onPressed: () => _showRemoveDialog(item, index, controller),
        child: const Text('移除'),
      ),
    );
  }

  void _showRemoveDialog(
    BlacklistItemEntity item,
    int index,
    BlacklistController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认'),
        content: Text('确定将 ${item.uname} 移出黑名单？'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '取消',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              PageUtils.pop();
              final success = await controller.removeFromBlacklist(
                index,
                item.mid,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('操作成功')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
