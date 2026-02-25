import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/features/follow/data/datasources/follow_api_datasource.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote data source for dynamics.
class DynamicsRemoteDataSource {
  final _followDataSource = FollowRemoteDataSource();

  DynamicsRemoteDataSource();

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
  Future<LoadingState<FollowData>> getAllFollowings({
    required int mid,
    required int page,
  }) async {
    try {
      final result = await _followDataSource.followings(
        vmid: mid,
        pn: page,
        orderType: 'attention',
        ps: 50,
      );
      return Success(FollowData.fromJson(result));
    } catch (e) {
      return Error(e.toString());
    }
  }
}
