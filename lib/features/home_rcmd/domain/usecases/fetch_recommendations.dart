import 'package:PiliPlus/features/home_rcmd/domain/entities/recommendation_result.dart';
import 'package:PiliPlus/features/home_rcmd/domain/repositories/video_recommendation_repository.dart';

/// 获取推荐视频用例
class FetchRecommendationsUseCase {
  final VideoRecommendationRepository _repository;

  const FetchRecommendationsUseCase(this._repository);

  /// 执行用例：获取推荐视频
  ///
  /// [freshIdx] 刷新索引，用于分页
  /// [useAppApi] 是否使用App API
  Future<RecommendationResult> call({
    required int freshIdx,
    required bool useAppApi,
  }) {
    return _repository.getRecommendations(
      freshIdx: freshIdx,
      useAppApi: useAppApi,
    );
  }
}
