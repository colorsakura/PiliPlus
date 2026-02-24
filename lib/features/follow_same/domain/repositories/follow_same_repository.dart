import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository for "same followed" users (共同关注)
abstract class FollowSameRepository {
  /// Fetch list of users that both users follow
  Future<LoadingState<FollowData>> getSameFollowList({
    required int mid,
    required int pn,
  });

  /// Get user name by mid
  Future<String?> getUserName(int mid);
}
