import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Repository for fan/follower data
abstract class FanRepository {
  /// Get fans (followers) for a user
  Future<LoadingState<FollowData>> getFans({
    required int vmid,
    required int pn,
    required String orderType,
  });

  /// Remove a fan
  Future<LoadingState<void>> removeFan({
    required int mid,
    required int act,
    required int reSrc,
  });
}
