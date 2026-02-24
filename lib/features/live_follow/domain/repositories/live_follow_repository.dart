import 'package:PiliPlus/features/live_follow/domain/entities/live_follow_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for live follow data
abstract class LiveFollowRepository {
  Future<LoadingState<List<LiveFollowItemEntity>>> fetchLiveFollow({
    required int page,
  });
}
