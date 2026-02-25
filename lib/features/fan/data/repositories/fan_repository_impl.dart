import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/features/fan/domain/repositories/fan_repository.dart';
import 'package:PiliPlus/features/fan/data/datasources/fan_remote_datasource.dart';

/// Repository implementation for fan data
class FanRepositoryImpl implements FanRepository {
  const FanRepositoryImpl(this._datasource);

  final FanRemoteDatasource _datasource;

  @override
  Future<LoadingState<FollowData>> getFans({
    required int vmid,
    required int pn,
    required String orderType,
  }) => _datasource.getFans(
    vmid: vmid,
    pn: pn,
    orderType: orderType,
  );

  @override
  Future<LoadingState<void>> removeFan({
    required int mid,
    required int act,
    required int reSrc,
  }) => _datasource.removeFan(
    mid: mid,
    act: act,
    reSrc: reSrc,
  );
}
