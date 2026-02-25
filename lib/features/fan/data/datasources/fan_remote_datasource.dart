import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fan/data/datasources/fan_api_datasource.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote datasource for fan data
///
/// This class now delegates to FanRemoteDataSource which uses
/// the new clean architecture with HttpClientManager
class FanRemoteDatasource {
  final _dataSource = FanRemoteDataSource();

  /// Get fans (followers) for a user
  Future<LoadingState<FollowData>> getFans({
    required int vmid,
    required int pn,
    required String orderType,
  }) async {
    try {
      final result = await _dataSource.fans(
        vmid: vmid,
        pn: pn,
        orderType: orderType,
      );
      return Success(result);
    } catch (e) {
      return Error(e.toString());
    }
  }

  /// Remove a fan
  Future<LoadingState<void>> removeFan({
    required int mid,
    required int act,
    required int reSrc,
  }) async {
    // This method uses VideoHttp.relationMod which is in video.dart
    // Will be migrated when we process video.dart
    // For now, keep the old implementation or mark as TODO
    return Error('Not implemented - needs video.dart migration');
  }
}
