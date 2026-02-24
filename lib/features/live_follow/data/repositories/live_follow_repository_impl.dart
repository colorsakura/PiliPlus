import 'package:PiliPlus/features/live_follow/domain/entities/live_follow_item_entity.dart';
import 'package:PiliPlus/features/live_follow/domain/repositories/live_follow_repository.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_follow/data.dart';

/// Implementation of live follow repository
class LiveFollowRepositoryImpl implements LiveFollowRepository {
  const LiveFollowRepositoryImpl();

  @override
  Future<LoadingState<List<LiveFollowItemEntity>>> fetchLiveFollow({
    required int page,
  }) async {
    final result = await LiveHttp.liveFollow(page);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.list ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
