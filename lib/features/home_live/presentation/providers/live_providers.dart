import 'package:PiliPlus/features/home_live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/features/home_live/data/repositories/live_repository_impl.dart';
import 'package:PiliPlus/features/home_live/domain/usecases/fetch_live_area_list.dart';
import 'package:PiliPlus/features/home_live/domain/usecases/fetch_live_feed.dart';
import 'package:PiliPlus/features/home_live/presentation/providers/live_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 直播远程数据源 Provider
final liveRemoteDataSourceProvider = Provider<LiveRemoteDataSource>((ref) {
  return LiveRemoteDataSource();
});

/// 直播仓库 Provider
final liveRepositoryProvider = Provider<LiveRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(liveRemoteDataSourceProvider);
  return LiveRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// 获取直播Feed用例 Provider
final fetchLiveFeedUseCaseProvider = Provider<FetchLiveFeedUseCase>((ref) {
  final repository = ref.watch(liveRepositoryProvider);
  return FetchLiveFeedUseCase(repository);
});

/// 获取直播分区列表用例 Provider
final fetchLiveAreaListUseCaseProvider = Provider<FetchLiveAreaListUseCase>((
  ref,
) {
  final repository = ref.watch(liveRepositoryProvider);
  return FetchLiveAreaListUseCase(repository);
});

/// 直播Controller Provider
final liveControllerProvider =
    NotifierProvider<LiveController, LiveControllerState>(LiveController.new);
