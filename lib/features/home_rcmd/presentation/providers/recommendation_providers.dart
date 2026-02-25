import 'package:PiliPlus/features/home_rcmd/data/datasources/recommendation_settings_local_datasource.dart';
import 'package:PiliPlus/features/home_rcmd/data/datasources/video_recommendation_remote_datasource.dart';
import 'package:PiliPlus/features/home_rcmd/data/repositories/recommendation_settings_repository_impl.dart';
import 'package:PiliPlus/features/home_rcmd/data/repositories/video_recommendation_repository_impl.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/fetch_recommendations.dart';
import 'package:PiliPlus/features/home_rcmd/domain/usecases/get_recommendation_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== Data Sources ==========

/// 视频推荐远程数据源 Provider
final videoRecommendationRemoteDataSourceProvider =
    Provider<VideoRecommendationRemoteDataSource>((ref) {
      return VideoRecommendationRemoteDataSource();
    });

/// 推荐设置本地数据源 Provider
final recommendationSettingsLocalDataSourceProvider =
    Provider<RecommendationSettingsLocalDataSource>((ref) {
      return RecommendationSettingsLocalDataSource();
    });

// ========== Repositories ==========

/// 视频推荐仓库 Provider
final videoRecommendationRepositoryProvider =
    Provider<VideoRecommendationRepositoryImpl>((ref) {
      return VideoRecommendationRepositoryImpl(
        remoteDataSource: ref.read(videoRecommendationRemoteDataSourceProvider),
      );
    });

/// 推荐设置仓库 Provider
final recommendationSettingsRepositoryProvider =
    Provider<RecommendationSettingsRepositoryImpl>((ref) {
      return RecommendationSettingsRepositoryImpl(
        localDataSource: ref.read(
          recommendationSettingsLocalDataSourceProvider,
        ),
      );
    });

// ========== Use Cases ==========

/// 获取推荐视频用例 Provider
final fetchRecommendationsUseCaseProvider =
    Provider<FetchRecommendationsUseCase>((ref) {
      return FetchRecommendationsUseCase(
        ref.read(videoRecommendationRepositoryProvider),
      );
    });

/// 获取推荐设置用例 Provider
final getRecommendationSettingsUseCaseProvider =
    Provider<GetRecommendationSettingsUseCase>((ref) {
      return GetRecommendationSettingsUseCase(
        ref.read(recommendationSettingsRepositoryProvider),
      );
    });
