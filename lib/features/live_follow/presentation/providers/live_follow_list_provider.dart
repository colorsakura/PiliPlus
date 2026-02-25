import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/features/live_follow/data/repositories/live_follow_repository_impl.dart';
import 'package:PiliPlus/features/live_follow/domain/usecases/fetch_live_follow.dart';
import 'package:PiliPlus/features/live_follow/presentation/providers/live_follow_list_controller.dart';

final liveRemoteDataSourceProvider = Provider<LiveRemoteDataSource>((ref) {
  return LiveRemoteDataSource();
});

final liveFollowRepositoryProvider = Provider<LiveFollowRepositoryImpl>((ref) {
  return LiveFollowRepositoryImpl(
    remoteDataSource: ref.watch(liveRemoteDataSourceProvider),
  );
});

final fetchLiveFollowUseCaseProvider = Provider<FetchLiveFollowUseCase>((ref) {
  return FetchLiveFollowUseCase(
    ref.watch(liveFollowRepositoryProvider),
  );
});

final liveFollowListControllerProvider =
    Provider<LiveFollowListController>((ref) {
  return LiveFollowListController(
    fetchLiveFollow: ref.watch(fetchLiveFollowUseCaseProvider),
  );
});
