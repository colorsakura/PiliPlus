import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

/// Remote data source for dynamics tab
///
/// Fetches dynamics from the Bilibili API.
class DynTabRemoteDatasource {
  /// Fetch follow dynamics
  Future<LoadingState<dynamic>> followDynamic({
    required DynamicsTabType type,
    required String offset,
    int? mid,
    required Set<int> tempBannedList,
  }) {
    return DynamicsHttp.followDynamic(
      type: type,
      offset: offset,
      mid: mid,
      tempBannedList: tempBannedList,
    );
  }

  /// Remove a dynamic
  Future<LoadingState> removeDynamic({required String dynIdStr}) {
    return MsgHttp.removeDynamic(dynIdStr: dynIdStr);
  }
}
