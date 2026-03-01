import 'dart:math';

import 'package:PiliPlus/shared/widgets/custom_tooltip.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';
import 'package:PiliPlus/models/live/live_emote/emoticon.dart';
import 'package:PiliPlus/features/live_emote/presentation/providers/live_emote_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/utils/waterfall.dart';

class LiveEmotePanelV2 extends ConsumerStatefulWidget {
  final int roomId;
  final Function(Emoticon emote, double? width, double? height) onChoose;
  final ValueChanged<Emoticon> onSendEmoticonUnique;

  const LiveEmotePanelV2({
    super.key,
    required this.roomId,
    required this.onChoose,
    required this.onSendEmoticonUnique,
  });

  @override
  ConsumerState<LiveEmotePanelV2> createState() => _LiveEmotePanelV2State();
}

class _LiveEmotePanelV2State extends ConsumerState<LiveEmotePanelV2>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(liveEmoteListControllerProvider(widget.roomId));

    // Initialize tab controller when data is available
    if (state.listState case Success(:final response) when response != null && response.isNotEmpty) {
      if (_tabController == null || _tabController!.length != response.length) {
        _tabController?.dispose();
        _tabController = TabController(
          length: response.length,
          vsync: this,
        );
      }
    }

    return _buildBody(state.listState);
  }

  Widget _buildBody(LoadingState<List<LiveEmoteDatum>?> loadingState) {
    final theme = Theme.of(context);
    final color = ElevationOverlay.colorWithOverlay(
      theme.colorScheme.surface,
      theme.hoverColor,
      2,
    );

    return switch (loadingState) {
      Loading() => loadingWidget,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: tabBarView(
                      controller: _tabController,
                      children: response.map(
                        (item) {
                          final emote = item.emoticons;
                          if (emote == null || emote.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          final first = emote.first;
                          final widthFac = first.width == null
                              ? 1.0
                              : max(1.0, first.width! / 80);
                          final heightFac = first.height == null
                              ? 1.0
                              : max(1.0, first.height! / 80);
                          final width = widthFac * 38;
                          final height = heightFac * 38;
                          return GridView.builder(
                            physics: const ClampingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 12,
                              bottom: 12,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: widthFac * 40,
                                  mainAxisExtent: heightFac * 40,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: emote.length,
                            itemBuilder: (context, index) {
                              final e = emote[index];
                              return Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(6),
                                  ),
                                  onTap: () {
                                    if (item.pkgType == 3) {
                                      widget.onChoose(e, width, height);
                                    } else {
                                      widget.onSendEmoticonUnique(e);
                                    }
                                  },
                                  child: CustomTooltip(
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
                                            src: e.url,
                                            width: 65,
                                            height: 65,
                                            type: ImageType.emote,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            e.emoji == null
                                                ? ''
                                                : e.emoji!.startsWith('[')
                                                ? e.emoji!.substring(
                                                    1,
                                                    e.emoji!.length - 1,
                                                  )
                                                : e.emoji!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: NetworkImgLayer(
                                        fit: BoxFit.contain,
                                        src: e.url,
                                        width: width,
                                        height: height,
                                        type: ImageType.emote,
                                        quality: item.pkgType == 3 ? 1 : 80,
                                      ),
                                    ),
                                  ),
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
                  TabBar(
                    controller: _tabController,
                    padding: const EdgeInsets.only(right: 60),
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    isScrollable: true,
                    tabs: response
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: NetworkImgLayer(
                              width: 24,
                              height: 24,
                              type: ImageType.emote,
                              src: item.currentCover,
                            ),
                          ),
                        )
                        .toList(),
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
      onPressed: () {
        ref.read(liveEmoteListControllerProvider(widget.roomId).notifier).queryData(widget.roomId);
      },
      icon: const Icon(Icons.refresh),
      label: Text(errMsg ?? '没有数据'),
    ),
  );
}
