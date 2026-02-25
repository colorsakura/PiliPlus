import 'package:PiliPlus/features/home_live/domain/entities/live_stream.dart';
import 'package:PiliPlus/models/live/live_feed_index/card_data_list_item.dart';

/// 直播Feed结果实体
class LiveFeedResult {
  /// 直播流列表
  final List<LiveStream> streams;

  /// 是否有更多数据
  final bool hasMore;

  /// 关注的直播主播列表
  final List<CardLiveItem>? followingItems;

  /// 关注总数
  final int? followingCount;

  /// 分区入口列表
  final List<CardLiveItem>? areaItems;

  const LiveFeedResult({
    required this.streams,
    required this.hasMore,
    this.followingItems,
    this.followingCount,
    this.areaItems,
  });

  /// 创建空结果
  const LiveFeedResult.empty()
    : streams = const [],
      hasMore = true,
      followingItems = null,
      followingCount = null,
      areaItems = null;

  /// 复制并更新
  LiveFeedResult copyWith({
    List<LiveStream>? streams,
    bool? hasMore,
    List<CardLiveItem>? followingItems,
    int? followingCount,
    List<CardLiveItem>? areaItems,
  }) {
    return LiveFeedResult(
      streams: streams ?? this.streams,
      hasMore: hasMore ?? this.hasMore,
      followingItems: followingItems ?? this.followingItems,
      followingCount: followingCount ?? this.followingCount,
      areaItems: areaItems ?? this.areaItems,
    );
  }
}
