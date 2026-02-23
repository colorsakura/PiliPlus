import 'package:PiliPlus/features/home_live/domain/entities/live_stream.dart';
import 'package:PiliPlus/models/live/live_second_list/tag.dart';

/// 直播分区结果实体
class LiveAreaResult {
  /// 直播流列表
  final List<LiveStream> streams;

  /// 总数量
  final int? totalCount;

  /// 排序标签列表
  final List<LiveSecondTag>? sortTags;

  /// 当前排序类型
  final String? currentSortType;

  const LiveAreaResult({
    required this.streams,
    this.totalCount,
    this.sortTags,
    this.currentSortType,
  });

  /// 创建空结果
  const LiveAreaResult.empty()
      : streams = const [],
        totalCount = null,
        sortTags = null,
        currentSortType = null;

  /// 是否到达末尾
  bool get isEnd => totalCount != null && streams.length >= totalCount!;

  /// 复制并更新
  LiveAreaResult copyWith({
    List<LiveStream>? streams,
    int? totalCount,
    List<LiveSecondTag>? sortTags,
    String? currentSortType,
  }) {
    return LiveAreaResult(
      streams: streams ?? this.streams,
      totalCount: totalCount ?? this.totalCount,
      sortTags: sortTags ?? this.sortTags,
      currentSortType: currentSortType ?? this.currentSortType,
    );
  }
}
