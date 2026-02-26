import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/features/video/data/repositories/video_repository_impl.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_ai_conclusion.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_detail.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_play_url.dart';
import 'package:PiliPlus/features/video/domain/usecases/get_video_relation.dart';
import 'package:PiliPlus/features/video/domain/usecases/like_video.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 视频远程数据源 Provider
final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSource();
});

/// 视频仓库实现 Provider
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final remoteDataSource = ref.watch(videoRemoteDataSourceProvider);
  return VideoRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取视频详情用例 Provider
final getVideoDetailUseCaseProvider = Provider<GetVideoDetailUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetVideoDetailUseCase(repository);
});

/// 获取视频播放URL用例 Provider
final getVideoPlayUrlUseCaseProvider = Provider<GetVideoPlayUrlUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetVideoPlayUrlUseCase(repository);
});

/// 点赞视频用例 Provider
final likeVideoUseCaseProvider = Provider<LikeVideoUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return LikeVideoUseCase(repository);
});

/// 获取视频关系用例 Provider
final getVideoRelationUseCaseProvider = Provider<GetVideoRelationUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetVideoRelationUseCase(repository);
});

/// 获取AI总结用例 Provider
final getAIConclusionUseCaseProvider = Provider<GetAIConclusionUseCase>((ref) {
  final repository = ref.watch(videoRepositoryProvider);
  return GetAIConclusionUseCase(repository);
});
