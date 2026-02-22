import 'package:PiliPlus/features/home_hot/domain/entities/hot_video.dart';

/// 热门视频结果实体
///
/// 包含热门视频列表及相关状态
class HotVideoResult {
  /// 热门视频列表
  final List<HotVideo> videos;

  /// 是否还有更多数据
  final bool hasMore;

  /// 当前页码
  final int currentPage;

  const HotVideoResult({
    required this.videos,
    required this.hasMore,
    required this.currentPage,
  });

  /// 创建空结果
  factory HotVideoResult.empty() {
    return const HotVideoResult(
      videos: [],
      hasMore: true,
      currentPage: 0,
    );
  }

  /// 复制并更新
  HotVideoResult copyWith({
    List<HotVideo>? videos,
    bool? hasMore,
    int? currentPage,
  }) {
    return HotVideoResult(
      videos: videos ?? this.videos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
