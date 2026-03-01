import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/features/live_area/presentation/providers/live_area_list_controller.dart';
import 'package:PiliPlus/features/live_area/presentation/providers/live_area_providers.dart';
import 'package:PiliPlus/features/live_area_detail/live_area_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class LiveAreaPageV2 extends ConsumerWidget {
  const LiveAreaPageV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(liveAreaListControllerProvider);
    final controller = ref.read(liveAreaListControllerProvider.notifier);
    final isLogin = ref.watch(isLoginProvider);
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('全部标签'),
        actions: isLogin
            ? [
                TextButton(
                  onPressed: controller.onEdit,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(state.isEditing ? '完成' : '编辑'),
                ),
                const SizedBox(width: 16),
              ]
            : null,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: padding.left, right: padding.right),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLogin)
              _buildFavWidget(theme, state.favState, controller),
            Expanded(
              child: _buildBody(
                theme,
                padding.bottom,
                state,
                controller,
                context,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    double bottom,
    LiveAreaListState state,
    dynamic controller,
    BuildContext context,
  ) {
    return switch (state.listState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? DefaultTabController(
                length: response.length,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: response.map((e) => Tab(text: e.name)).toList(),
                    ),
                    Expanded(
                      child: tabBarView(
                        children: response
                            .map(
                              (e) => KeepAliveWrapper(
                                builder: (context) {
                                  if (e.areaList == null ||
                                      e.areaList!.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return GridView.builder(
                                    padding: EdgeInsets.only(
                                      top: 12,
                                      bottom: bottom + 100,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 100,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 10,
                                          mainAxisExtent: 80,
                                        ),
                                    itemCount: e.areaList!.length,
                                    itemBuilder: (context, index) {
                                      final item = e.areaList![index];
                                      return _tagItem(
                                        theme: theme,
                                        item: item,
                                        isEditing: state.isEditing,
                                        onTap: () {
                                          Get.to(
                                            LiveAreaDetailPage(
                                              areaId: item.id,
                                              parentAreaId: item.parentId,
                                              parentName: item.parentName ?? '',
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              )
            : _scrollErrorWidget(
                onReload: controller.onReload,
                theme: theme,
              ),
      Error(:final errMsg) => _scrollErrorWidget(
        errMsg: errMsg,
        onReload: controller.onReload,
        theme: theme,
      ),
    };
  }

  Widget _buildFavWidget(
    ThemeData theme,
    LoadingState<List<AreaItem>> loadingState,
    dynamic controller,
  ) {
    if (loadingState case Success(:final response)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '我的常用标签  '),
                  TextSpan(
                    text: '点击进入标签',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (response.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: response
                    .map(
                      (item) => _favTagItem(
                        theme: theme,
                        item: item,
                        onTap: () {
                          // Navigate to area detail
                        },
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 4),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _tagItem({
    required ThemeData theme,
    required AreaItem item,
    required bool isEditing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NetworkImgLayer(
            width: 45,
            height: 45,
            src: item.pic,
            type: ImageType.emote,
          ),
          const SizedBox(height: 4),
          Text(
            item.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _favTagItem({
    required ThemeData theme,
    required AreaItem item,
    required VoidCallback onTap,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          child: Text(
            item.name ?? '',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _scrollErrorWidget({
    String? errMsg,
    required VoidCallback onReload,
    required ThemeData theme,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 60),
          const SizedBox(height: 16),
          Text(errMsg ?? '加载失败'),
          const SizedBox(height: 16),
          iconButton(
            icon: const Icon(Icons.refresh),
            bgColor: theme.colorScheme.secondaryContainer,
            iconColor: theme.colorScheme.onSecondaryContainer,
            onPressed: onReload,
          ),
        ],
      ),
    );
  }
}
