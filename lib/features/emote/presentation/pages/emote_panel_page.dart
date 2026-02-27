import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/custom_tooltip.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/features/emote/presentation/providers/emote_providers.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/emote/emote.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// 表情面板组件
///
/// 显示表情选择面板,支持多个表情包分类
class EmotePanel extends ConsumerStatefulWidget {
  final Function(Emote emote, double? width, double? height) onChoose;

  const EmotePanel({super.key, required this.onChoose});

  @override
  ConsumerState<EmotePanel> createState() => _EmotePanelState();
}

class _EmotePanelState extends ConsumerState<EmotePanel>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 初始化时获取表情包数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(emoteControllerProvider.notifier).setTickerProvider(this);
    });
  }

  @override
  void dispose() {
    // Don't null out the vsync during dispose as it may cause issues
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData theme = Theme.of(context);
    final emoteState = ref.watch(emoteControllerProvider);

    return _buildBody(theme, emoteState.loadingState);
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<Package>?> loadingState,
  ) {
    late final color = ElevationOverlay.colorWithOverlay(
      theme.colorScheme.surface,
      theme.hoverColor,
      Get.currentRoute.startsWith('/whisperDetail') ? 8 : 2,
    );
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: tabBarView(
                      controller: ref
                          .read(emoteControllerProvider)
                          .tabController,
                      children: response.map(
                        (e) {
                          final emote = e.emote;
                          if (emote == null || emote.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final flag = emote.first.meta?.size == 1;
                          final size = flag ? 40.0 : 60.0;
                          final isTextEmote = e.type == 4;
                          return GridView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 12,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: isTextEmote ? 100 : size,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  mainAxisExtent: size,
                                ),
                            itemCount: emote.length,
                            itemBuilder: (context, index) {
                              final item = emote[index];
                              Widget child = Padding(
                                padding: const EdgeInsets.all(6),
                                child: isTextEmote
                                    ? Center(
                                        child: Text(
                                          item.text ?? '',
                                          overflow: TextOverflow.clip,
                                          maxLines: 1,
                                        ),
                                      )
                                    : NetworkImgLayer(
                                        src: item.url,
                                        width: size,
                                        height: size,
                                        type: ImageType.emote,
                                        fit: BoxFit.contain,
                                      ),
                              );
                              if (!isTextEmote) {
                                child = CustomTooltip(
                                  indicator: () => Triangle(
                                    color: color,
                                    size: const Size(14, 8),
                                  ),
                                  overlayWidget: () => Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                    ),
                                    child: Column(
                                      spacing: 4,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        NetworkImgLayer(
                                          src: item.url,
                                          width: 65,
                                          height: 65,
                                          type: ImageType.emote,
                                          fit: BoxFit.contain,
                                        ),
                                        Text(
                                          item.meta?.alias ??
                                              item.text?.substring(
                                                1,
                                                item.text!.length - 1,
                                              ) ??
                                              '',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: child,
                                );
                              }
                              return Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                  onTap: () => widget.onChoose(
                                    item,
                                    isTextEmote
                                        ? null
                                        : flag
                                        ? 24
                                        : 42,
                                    null,
                                  ),
                                  child: child,
                                ),
                              );
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: iconButton(
                          iconSize: 20,
                          iconColor: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                          onPressed: () => PageUtils.toDupNamed(
                            '/webview',
                            parameters: {
                              'url':
                                  'https://www.bilibili.com/h5/mall/emoji-package/home?navhide=1&${Utils.themeUrl(theme.colorScheme.isDark)}',
                            },
                          ),
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                      Expanded(
                        child: TabBar(
                          controller: ref
                              .read(emoteControllerProvider)
                              .tabController,
                          padding: const EdgeInsets.only(right: 60),
                          dividerColor: Colors.transparent,
                          dividerHeight: 0,
                          isScrollable: true,
                          tabs: response
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: NetworkImgLayer(
                                    width: 24,
                                    height: 24,
                                    type: ImageType.emote,
                                    src: e.url,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
                ],
              )
            : _errorWidget(),
      Error(:final errMsg) => _errorWidget(errMsg),
    };
  }

  Widget _errorWidget([String? errMsg]) => Center(
    child: TextButton.icon(
      onPressed: ref.read(emoteControllerProvider.notifier).onReload,
      icon: const Icon(Icons.refresh),
      label: Text(errMsg ?? '没有数据'),
    ),
  );
}
