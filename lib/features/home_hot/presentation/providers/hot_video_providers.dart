import 'package:PiliPlus/features/home_hot/data/datasources/hot_video_remote_datasource.dart';
import 'package:PiliPlus/features/home_hot/data/repositories/hot_video_repository_impl.dart';
import 'package:PiliPlus/features/home_hot/domain/usecases/fetch_hot_videos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== Data Sources ==========

/// 热门视频远程数据源 Provider
final hotVideoRemoteDataSourceProvider =
    Provider<HotVideoRemoteDataSource>((ref) {
  return HotVideoRemoteDataSource();
});

// ========== Repositories ==========

/// 热门视频仓库 Provider
final hotVideoRepositoryProvider =
    Provider<HotVideoRepositoryImpl>((ref) {
  return HotVideoRepositoryImpl(
    remoteDataSource: ref.read(hotVideoRemoteDataSourceProvider),
  );
});

// ========== Use Cases ==========

/// 获取热门视频用例 Provider
final fetchHotVideosUseCaseProvider =
    Provider<FetchHotVideosUseCase>((ref) {
  return FetchHotVideosUseCase(
    ref.read(hotVideoRepositoryProvider),
  );
});
