import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote datasource for "same followed" users
class FollowSameRemoteDatasource {
  const FollowSameRemoteDatasource();

  /// Fetch list of users that both users follow
  Future<LoadingState<FollowData>> getSameFollowList({
    required int mid,
    required int pn,
  }) => UserHttp.sameFollowing(
    mid: mid,
    pn: pn,
  );

  /// Get user name by mid
  Future<String?> getUserName(int mid) async {
    final res = await MemberHttp.memberCardInfo(mid: mid);
    return res.dataOrNull?.card?.name;
  }
}
