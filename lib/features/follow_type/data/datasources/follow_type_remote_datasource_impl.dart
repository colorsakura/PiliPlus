import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/follow_type/data/datasources/follow_type_remote_datasource.dart';
import 'package:PiliPlus/features/follow_type/domain/entities/follow_type_params.dart';
import 'package:PiliPlus/http/user.dart' as http;

/// Implementation of follow type remote data source using UserHttp
class FollowTypeRemoteDataSourceImpl implements FollowTypeRemoteDataSource {
  const FollowTypeRemoteDataSourceImpl();

  @override
  Future<LoadingState<FollowData>> fetchFollowed(FollowedParams params) {
    return http.UserHttp.followedUp(
      mid: params.mid,
      pn: params.page,
    );
  }

  @override
  Future<LoadingState<FollowData>> fetchFollowSame(FollowSameParams params) {
    return http.UserHttp.sameFollowing(
      mid: params.mid,
      pn: params.page,
    );
  }
}
