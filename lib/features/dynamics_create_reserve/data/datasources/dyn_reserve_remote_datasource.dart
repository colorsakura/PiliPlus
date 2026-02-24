import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';

/// Dynamics reserve remote data source
class DynReserveRemoteDataSource {
  /// Get reserve info from API
  Future<LoadingState<ReserveInfoData>> getReserveInfo({required int sid}) {
    return DynamicsHttp.reserveInfo(sid: sid);
  }

  /// Create reserve via API
  Future<LoadingState<int?>> createReserve({
    required String title,
    required int subType,
    required int livePlanStartTime,
  }) {
    return DynamicsHttp.createReserve(
      title: title,
      subType: subType,
      livePlanStartTime: livePlanStartTime,
    );
  }

  /// Update reserve via API
  Future<LoadingState<void>> updateReserve({
    required int sid,
    required int subType,
    required String title,
    required int livePlanStartTime,
  }) {
    return DynamicsHttp.updateReserve(
      sid: sid,
      subType: subType,
      title: title,
      livePlanStartTime: livePlanStartTime,
    );
  }
}
