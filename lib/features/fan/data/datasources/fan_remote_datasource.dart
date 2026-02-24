import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/fan.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/follow/data.dart';

/// Remote datasource for fan data
class FanRemoteDatasource {
  const FanRemoteDatasource();

  /// Get fans (followers) for a user
  Future<LoadingState<FollowData>> getFans({
    required int vmid,
    required int pn,
    required String orderType,
 }) =>
      FanHttp.fans(
        vmid: vmid,
        pn: pn,
        orderType: orderType,
      );

  /// Remove a fan
  Future<LoadingState<void>> removeFan({
    required int mid,
    required int act,
    required int reSrc,
  }) =>
      VideoHttp.relationMod(
        mid: mid,
        act: act,
        reSrc: reSrc,
      );
}
