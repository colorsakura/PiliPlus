import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository for "also followed" users (我关注的也关注了)
abstract class FollowedRepository {
  /// Fetch list of users that are also followed by the target user
  Future<LoadingState<FollowData>> getFollowedList({
    required int mid,
    required int pn,
  });

  /// Get user name by mid
  Future<String?> getUserName(int mid);
}
