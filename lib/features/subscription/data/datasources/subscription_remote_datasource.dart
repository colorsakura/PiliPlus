import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/sub/sub/data.dart';

/// Remote datasource for subscription data
class SubscriptionRemoteDatasource {
  const SubscriptionRemoteDatasource();

  /// Fetch user subscription folders from API
  Future<LoadingState<SubData>> getUserSubFolders({
    required int pn,
    required int ps,
    required int mid,
  }) =>
      UserHttp.userSubFolder(
        pn: pn,
        ps: ps,
        mid: mid,
      );

  /// Cancel a subscription
  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  }) =>
      FavHttp.cancelSub(
        id: id,
        type: type,
      );
}
