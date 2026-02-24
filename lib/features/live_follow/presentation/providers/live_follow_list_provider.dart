import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live_follow/data/repositories/live_follow_repository_impl.dart';
import 'package:PiliPlus/features/live_follow/domain/usecases/fetch_live_follow.dart';
import 'package:PiliPlus/features/live_follow/presentation/providers/live_follow_list_controller.dart';

final liveFollowRepositoryProvider = Provider<LiveFollowRepositoryImpl>((ref) {
  return const LiveFollowRepositoryImpl();
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
