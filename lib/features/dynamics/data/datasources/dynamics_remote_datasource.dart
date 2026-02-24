import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/follow.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

/// Remote data source for dynamics.
class DynamicsRemoteDataSource {
  const DynamicsRemoteDataSource();

  /// Get dynamics feed for a specific tab.
  Future<LoadingState> getDynamics({
    required DynamicsTabType tabType,
    String? offset,
  }) {
    return DynamicsHttp.followDynamic(
      type: tabType,
      offset: offset,
    );
  }

  /// Get follow-up UP users list.
  Future<LoadingState> getFollowUp() {
    return DynamicsHttp.followUp();
  }

  /// Get dynamics UP list (paginated).
  Future<LoadingState> getDynamicsUpList({
    String? offset,
  }) {
    return DynamicsHttp.dynUpList(offset);
  }

  /// Get all followings for a user.
  Future<LoadingState> getAllFollowings({
    required int mid,
    required int page,
  }) {
    return FollowHttp.followings(
      vmid: mid,
      pn: page,
      orderType: 'attention',
      ps: 50,
    );
  }
}
