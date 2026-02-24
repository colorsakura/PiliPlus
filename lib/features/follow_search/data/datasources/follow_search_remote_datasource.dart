import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote data source for follow search
class FollowSearchRemoteDatasource {
  const FollowSearchRemoteDatasource();

  /// Search followed users via API
  Future<LoadingState<FollowData>> searchFollows({
    required int mid,
    required String name,
    required int page,
    required int pageSize,
  }) {
    return MemberHttp.getfollowSearch(
      mid: mid,
      ps: pageSize,
      pn: page,
      name: name,
    );
  }
}
