import 'package:PiliPlus/features/dynamics_create_reserve/data/datasources/dyn_reserve_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_create_reserve/domain/repositories/dyn_reserve_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';

/// Dynamics reserve repository implementation
class DynReserveRepositoryImpl implements DynReserveRepository {
  final DynReserveRemoteDataSource _remoteDataSource;

  const DynReserveRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoadingState<ReserveInfoData>> getReserveInfo({required int sid}) {
    return _remoteDataSource.getReserveInfo(sid: sid);
  }

  @override
  Future<LoadingState<int?>> createReserve({
    required String title,
    required int subType,
    required int livePlanStartTime,
  }) {
    return _remoteDataSource.createReserve(
      title: title,
      subType: subType,
      livePlanStartTime: livePlanStartTime,
    );
  }

  @override
  Future<LoadingState<void>> updateReserve({
    required int sid,
    required int subType,
    required String title,
    required int livePlanStartTime,
  }) {
    return _remoteDataSource.updateReserve(
      sid: sid,
      subType: subType,
      title: title,
      livePlanStartTime: livePlanStartTime,
    );
  }
}
