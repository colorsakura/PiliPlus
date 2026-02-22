import 'package:PiliPlus/features/home_rcmd/data/datasources/video_recommendation_remote_datasource.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/recommendation_result.dart';
import 'package:PiliPlus/features/home_rcmd/domain/entities/video_recommendation.dart';
import 'package:PiliPlus/features/home_rcmd/domain/repositories/video_recommendation_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';

/// 视频推荐仓库实现
class VideoRecommendationRepositoryImpl
    implements VideoRecommendationRepository {
  final VideoRecommendationRemoteDataSource _remoteDataSource;

  VideoRecommendationRepositoryImpl({
    required VideoRecommendationRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<RecommendationResult> getRecommendations({
    required int freshIdx,
    required bool useAppApi,
  }) async {
    if (useAppApi) {
      final result =
          await _remoteDataSource.fetchAppRecommendations(freshIdx: freshIdx);
      return _mapAppRecommendationResult(result);
    } else {
      final result = await _remoteDataSource.fetchWebRecommendations(
        freshIdx: freshIdx,
        ps: 20,
      );
      return _mapWebRecommendationResult(result);
    }
  }

  RecommendationResult _mapWebRecommendationResult(
    LoadingState<List<RecVideoItemModel>> result,
  ) {
    if (result case Success(:final response)) {
      final videos = response
          .map<VideoRecommendation>((item) => VideoRecommendation(
                video: item,
                rcmdReason: item.rcmdReason,
              ))
          .toList();

      return RecommendationResult(
        videos: videos,
        hasMore: videos.isNotEmpty,
        currentPage: 0,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('Loading...');
    }
  }

  RecommendationResult _mapAppRecommendationResult(
    LoadingState<List<RecVideoItemAppModel>> result,
  ) {
    if (result case Success(:final response)) {
      final videos = response
          .map<VideoRecommendation>((item) => VideoRecommendation(
                video: item,
                rcmdReason: item.rcmdReason,
              ))
          .toList();

      return RecommendationResult(
        videos: videos,
        hasMore: videos.isNotEmpty,
        currentPage: 0,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('Loading...');
    }
  }
}
