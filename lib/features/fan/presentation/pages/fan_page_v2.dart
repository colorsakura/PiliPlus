import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/features/follow_type/presentation/widgets/item.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/features/share/share.dart' show UserModel;
import 'package:PiliPlus/features/fan/presentation/providers/fan_controller.dart';
import 'package:PiliPlus/features/fan/presentation/providers/fan_providers.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Fan page - V2 with Riverpod
class FanPageV2 extends ConsumerStatefulWidget {
  const FanPageV2({
    super.key,
    this.showName = true,
    this.onSelect,
    this.mid,
    this.name,
  });

  final bool showName;
  final ValueChanged<UserModel>? onSelect;
  final int? mid;
  final String? name;

  @override
  ConsumerState<FanPageV2> createState() => _FanPageV2State();

  static void toFanPage({int? mid, String? name}) {
    if (mid == null) return;
    PageUtils.pushNamed(AppRoutes.fan, extra: {
        'mid': mid,
        'name': name,
      },
    );
  }
}

class _FanPageV2State extends ConsumerState<FanPageV2> {
  late final FanController _controller;

  @override
  void initState() {
    super.initState();
    final mid = widget.mid ?? Get.arguments?['mid'] ?? Accounts.main.mid;
    final name = widget.name ?? Get.arguments?['name'];
    _controller = ref.read(
      fanControllerProvider(
        FanParams(
          mid: mid,
          name: name,
        ),
      ),
    );
  }

  bool get _isOwner => widget.mid == null || widget.mid == Accounts.main.mid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                if (widget.showName)
                  SliverAppBar(
                    title: _buildTitle(),
                  ),
                _buildBody(_controller.loadingState),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget? _buildTitle() {
    if (_isOwner) {
      return const Text('我的粉丝');
    }
    final name = _controller.name;
    if (name != null) return Text('$name的粉丝');
    return null;
  }

  Widget _buildBody(LoadingState<List<FollowItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemBuilder: (context, index) {
                  if (index == response.length - 1) {
                    _controller.onLoadMore();
                  }
                  return _buildItem(index, response[index]);
                },
                itemCount: response.length,
              )
            : HttpError(
                errMsg: '暂无粉丝',
                onReload: _controller.onReload,
              ),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg ?? '加载失败',
        onReload: _controller.onReload,
      ),
    };
  }

  Widget _buildItem(int index, FollowItemModel item) {
    final flag = widget.onSelect == null && _isOwner;

    void onRemove() => showConfirmDialog(
      context: context,
      title: '确定移除 ${item.uname} ？',
      onConfirm: () => _controller.removeFan(index, item.mid),
    );

    return FollowTypeItem(
      item: item,
      onTap: () {
        if (widget.onSelect != null) {
          widget.onSelect!(
            UserModel(
              mid: item.mid,
              name: item.uname!,
              avatar: item.face!,
              selected: true,
            ),
          );
          return;
        }
        PageUtils.toMemberPage(item.mid!);
      },
      onLongPress: flag ? onRemove : null,
      onSecondaryTap: flag && !PlatformUtils.isMobile ? onRemove : null,
    );
  }
}
