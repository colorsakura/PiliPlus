import 'package:PiliPlus/features/home_rcmd/domain/entities/recommendation_result.dart';

/// 视频推荐仓库接口
abstract interface class VideoRecommendationRepository {
  /// 获取推荐视频列表
  ///
  /// [freshIdx] 刷新索引，用于分页
  /// [useAppApi] 是否使用App API（true）还是Web API（false）
  Future<RecommendationResult> getRecommendations({
    required int freshIdx,
    required bool useAppApi,
  });
}
