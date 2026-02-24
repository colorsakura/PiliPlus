import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote datasource for "also followed" users
class FollowedRemoteDatasource {
  const FollowedRemoteDatasource();

  /// Fetch list of users that are also followed by the target user
  Future<LoadingState<FollowData>> getFollowedList({
    required int mid,
    required int pn,
  }) =>
      UserHttp.followedUp(
        mid: mid,
        pn: pn,
      );

  /// Get user name by mid
  Future<String?> getUserName(int mid) async {
    final res = await MemberHttp.memberCardInfo(mid: mid);
    return res.dataOrNull?.card?.name;
  }
}
