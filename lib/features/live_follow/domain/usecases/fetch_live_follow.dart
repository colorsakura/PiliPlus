import 'package:PiliPlus/features/live_follow/domain/entities/live_follow_item_entity.dart';
import 'package:PiliPlus/features/live_follow/domain/repositories/live_follow_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching live follow
class FetchLiveFollowUseCase {
  const FetchLiveFollowUseCase(this._repository);

  final LiveFollowRepository _repository;

  Future<LoadingState<List<LiveFollowItemEntity>>> call({
    required int page,
  }) {
    return _repository.fetchLiveFollow(page: page);
  }
}
