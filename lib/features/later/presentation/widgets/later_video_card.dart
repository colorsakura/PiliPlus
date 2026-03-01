import 'package:PiliPlus/shared/widgets/badge.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/progress_bar/video_progress_indicator.dart';
import 'package:PiliPlus/shared/widgets/stat/stat.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/features/later/domain/entities/later_item.dart';
import 'package:PiliPlus/models/common/badge_type.dart';
import 'package:PiliPlus/models/common/stat_type.dart';
import 'package:PiliPlus/utils/duration_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// 稍后再看视频卡片
class LaterVideoCard extends StatelessWidget {
  const LaterVideoCard({
    super.key,
    required this.videoItem,
    this.onDelete,
  });

  final LaterItemEntity videoItem;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _onTap(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: StyleString.safeSpace,
            vertical: 5,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: StyleString.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, boxConstraints) {
                    final double maxWidth = boxConstraints.maxWidth;
                    final double maxHeight = boxConstraints.maxHeight;
                    final num? progress = videoItem.progress;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        NetworkImgLayer(
                          src: videoItem.pic,
                          width: maxWidth,
                          height: maxHeight,
                        ),
                        if (videoItem.isCharging == true)
                          const PBadge(
                            text: '充电专属',
                            top: 6.0,
                            right: 6.0,
                            type: PBadgeType.error,
                          )
                        else if (videoItem.pgcLabel != null)
                          PBadge(
                            text: videoItem.pgcLabel,
                            top: 6.0,
                            right: 6.0,
                          )
                        else if (videoItem.isPugv ?? false)
                          const PBadge(
                            text: '课堂',
                            top: 6.0,
                            right: 6.0,
                          ),
                        if (progress != null && progress != 0) ...[
                          PBadge(
                            text: progress == -1
                                ? '已看完'
                                : '${DurationUtils.formatDuration(progress.toInt())}/${DurationUtils.formatDuration(videoItem.duration ?? 0)}',
                            right: 6,
                            bottom: 8,
                            type: PBadgeType.gray,
                          ),
                          Positioned(
                            left: 0,
                            bottom: 0,
                            right: 0,
                            child: VideoProgressIndicator(
                              color: theme.colorScheme.primary,
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              progress: progress == -1
                                  ? 1
                                  : progress / (videoItem.duration ?? 1),
                            ),
                          ),
                        ] else if (videoItem.duration != null &&
                            videoItem.duration! > 0)
                          PBadge(
                            text: DurationUtils.formatDuration(
                              videoItem.duration!,
                            ),
                            right: 6.0,
                            bottom: 6.0,
                            type: PBadgeType.gray,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              _content(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ThemeData theme) {
    final isPgc = videoItem.isPgc == true;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: isPgc
                ? [
                    Text(
                      videoItem.subtitle ?? '',
                      style: TextStyle(
                        fontSize: theme.textTheme.bodyMedium!.fontSize,
                        height: 1.42,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      videoItem.title ?? '',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    StatWidget(
                      type: StatType.play,
                      value: _getViewCount(),
                    ),
                  ]
                : [
                    Expanded(
                      child: Text(
                        videoItem.title ?? '',
                        style: TextStyle(
                          fontSize: theme.textTheme.bodyMedium!.fontSize,
                          height: 1.42,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _getOwnerName(),
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                        color: theme.colorScheme.outline,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        StatWidget(
                          type: StatType.play,
                          value: _getViewCount(),
                        ),
                        const SizedBox(width: 8),
                        StatWidget(
                          type: StatType.danmaku,
                          value: _getDanmakuCount(),
                        ),
                      ],
                    ),
                  ],
          ),
          Positioned(
            right: 0,
            bottom: -8,
            child: IconButton(
              tooltip: '移除',
              onPressed: onDelete,
              icon: const Icon(Icons.clear),
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String _getOwnerName() {
    if (videoItem.owner == null) return '';
    // Handle if owner is a Map (from JSON) or Owner object
    if (videoItem.owner is Map) {
      return (videoItem.owner as Map)['name']?.toString() ?? '';
    }
    // If it's an Owner object, try to access the name property via reflection
    // This is a fallback - ideally we'd properly type the entity
    try {
      return videoItem.owner
          .toString()
          .replaceAll('Owner(', '')
          .replaceAll(')', '');
    } catch (e) {
      return '';
    }
  }

  int? _getViewCount() {
    if (videoItem.stat == null) return null;
    if (videoItem.stat is Map) {
      return (videoItem.stat as Map)['view'] as int?;
    }
    return null;
  }

  int? _getDanmakuCount() {
    if (videoItem.stat == null) return null;
    if (videoItem.stat is Map) {
      return (videoItem.stat as Map)['danmaku'] as int?;
    }
    return null;
  }

  void _onTap(BuildContext context) {
    if (videoItem.isPugv ?? false) {
      PageUtils.viewPugv(seasonId: videoItem.aid);
      return;
    }
    if (videoItem.isPgc ?? false) {
      _handlePgcTap();
      return;
    }

    // Handle regular video
    if (videoItem.cid != null) {
      PageUtils.toVideoPage(
        bvid: videoItem.bvid,
        cid: videoItem.cid!,
        cover: videoItem.pic,
        title: videoItem.title,
      );
    } else {
      ToastUtils.showToast('无法播放该视频');
    }
  }

  void _handlePgcTap() {
    if (videoItem.bangumi == null) {
      if (videoItem.redirectUrl != null && videoItem.redirectUrl!.isNotEmpty) {
        PageUtils.viewPgcFromUri(videoItem.redirectUrl!);
      }
      return;
    }

    if (videoItem.bangumi is Map) {
      final bangumi = videoItem.bangumi as Map;
      final epId = bangumi['epId'];
      if (epId != null) {
        PageUtils.viewPgc(epId: epId);
      } else if (videoItem.redirectUrl != null &&
          videoItem.redirectUrl!.isNotEmpty) {
        PageUtils.viewPgcFromUri(videoItem.redirectUrl!);
      }
    }
  }
}
