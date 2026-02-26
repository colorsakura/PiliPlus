import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/domain/entities/follow_up.dart';
import 'package:PiliPlus/features/dynamics/presentation/providers/dynamics_tab_controller.dart';
import 'package:PiliPlus/features/dynamics/presentation/providers/follow_up_controller.dart';
import 'package:PiliPlus/shared/widgets/flutter/dyn/ink_well.dart' as dyn;
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';

/// Widget displaying the UP (creator) panel.
///
/// Shows followed creators with their avatars and names.
class UpPanelWidget extends ConsumerStatefulWidget {
  const UpPanelWidget({
    super.key,
    required this.tabController,
  });

  final TabController tabController;

  @override
  ConsumerState<UpPanelWidget> createState() => _UpPanelWidgetState();
}

class _UpPanelWidgetState extends ConsumerState<UpPanelWidget> {
  bool _showLiveUp = true;

  @override
  Widget build(BuildContext context) {
    final followUpState = ref.watch(followUpControllerProvider);
    final positionStr = ref.watch(
      dynamicsTabControllerProvider.select(
        (config) => config.getUpPanelPosition(),
      ),
    );
    final position = UpPanelPosition.values.firstWhere(
      (e) => e.name == positionStr,
      orElse: () => UpPanelPosition.top,
    );

    final isTop = position == UpPanelPosition.top;

    return followUpState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Center(
        child: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(followUpControllerProvider.notifier).refresh();
          },
        ),
      ),
      data: (data) {
        return CustomScrollView(
          scrollDirection: isTop ? Axis.horizontal : Axis.vertical,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: dyn.InkWell(
                onTap: () => setState(() {
                  _showLiveUp = !_showLiveUp;
                }),
                onLongPress: () {
                  // TODO: Navigate to live follow page
                },
                child: Container(
                  alignment: Alignment.center,
                  height: isTop ? 76 : 60,
                  padding: isTop
                      ? const EdgeInsets.only(left: 12, right: 6)
                      : null,
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5CB67B),
                    ),
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Live(${data.liveUsers?.count ?? 0})',
                        ),
                        if (!isTop) ...[
                          const TextSpan(text: '\n'),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              _showLiveUp
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 12,
                              color: const Color(0xFF5CB67B),
                            ),
                          ),
                        ] else
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              _showLiveUp
                                  ? Icons.keyboard_arrow_right
                                  : Icons.keyboard_arrow_left,
                              color: const Color(0xFF5CB67B),
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showLiveUp &&
                data.liveUsers?.items != null &&
                data.liveUsers!.items!.isNotEmpty)
              SliverList.builder(
                itemCount: data.liveUsers!.items!.length,
                itemBuilder: (context, index) {
                  return _buildUpItem(
                    data.liveUsers!.items![index],
                    isLive: true,
                    isTop: isTop,
                    data: data,
                  );
                },
              ),
            SliverToBoxAdapter(
              child: _buildUpItem(
                UpItemEntity(mid: -1, name: '全部动态'),
                isLive: false,
                isTop: isTop,
                data: data,
              ),
            ),
            if (data.upList.isNotEmpty)
              SliverList.builder(
                itemCount: data.upList.length,
                itemBuilder: (context, index) {
                  return _buildUpItem(
                    data.upList[index],
                    isLive: false,
                    isTop: isTop,
                    data: data,
                  );
                },
              ),
            if (!isTop) const SliverToBoxAdapter(child: SizedBox(height: 200)),
          ],
        );
      },
    );
  }

  Widget _buildUpItem(
    UpItemEntity upItem, {
    required bool isLive,
    required bool isTop,
    required FollowUpEntity data,
  }) {
    final theme = Theme.of(context);
    final isAll = upItem.mid == -1;

    return SizedBox(
      height: 76,
      width: isTop ? 70 : null,
      child: dyn.InkWell(
        onTap: () {
          if (isLive && upItem is LiveUserItemEntity) {
            // TODO: Navigate to live room
          } else {
            _onSelectUp(upItem.mid);
          }
        },
        onLongPress: isAll
            ? null
            : () {
                // TODO: Navigate to member page
              },
        child: Opacity(
          opacity: _isCurrentUp(upItem, data) ? 1 : 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAvatar(upItem, isLive, isAll, isTop, theme),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  isTop ? '${upItem.name}\n' : upItem.name ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCurrentUp(upItem, data)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    height: 1.1,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(
    UpItemEntity upItem,
    bool isLive,
    bool isAll,
    bool isTop,
    ThemeData theme,
  ) {
    if (isAll) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 5,
            color: const Color(0xFF5CB67B),
          ),
        ),
        child: Image.asset(
          'assets/images/logo/logo.png',
          width: 38,
          height: 38,
        ),
      );
    }

    Widget avatar = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: NetworkImgLayer(
        src: upItem.face,
        width: 38,
        height: 38,
        type: ImageType.avatar,
      ),
    );

    if (isLive || upItem.hasUpdate == true) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          if (isLive)
            Positioned(
              top: !isTop ? -5 : 0,
              right: -6,
              child: Badge(
                label: const Text(' Live '),
                textColor: theme.colorScheme.onSecondaryContainer,
                backgroundColor: theme.colorScheme.secondaryContainer
                    .withValues(alpha: 0.75),
              ),
            )
          else if (upItem.hasUpdate == true)
            Positioned(
              top: 0,
              right: 4,
              child: Badge(
                smallSize: 8,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
        ],
      );
    }

    return avatar;
  }

  bool _isCurrentUp(UpItemEntity upItem, FollowUpEntity data) {
    // TODO: Track current selected UP
    return upItem.mid == -1;
  }

  void _onSelectUp(int mid) {
    // Switch to the UP tab and filter by mid
    // TODO: Implement UP selection logic
  }
}
