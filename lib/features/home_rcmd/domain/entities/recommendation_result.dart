import 'package:PiliPlus/features/home_rcmd/domain/entities/video_recommendation.dart';

/// 推荐结果实体
///
/// 包含推荐视频列表及相关状态
class RecommendationResult {
  /// 推荐视频列表
  final List<VideoRecommendation> videos;

  /// 是否还有更多数据
  final bool hasMore;

  /// 当前页码
  final int currentPage;

  const RecommendationResult({
    required this.videos,
    required this.hasMore,
    required this.currentPage,
  });

  /// 创建空结果
  factory RecommendationResult.empty() {
    return const RecommendationResult(
      videos: [],
      hasMore: true,
      currentPage: 0,
    );
  }

  /// 复制并更新
  RecommendationResult copyWith({
    List<VideoRecommendation>? videos,
    bool? hasMore,
    int? currentPage,
  }) {
    return RecommendationResult(
      videos: videos ?? this.videos,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
