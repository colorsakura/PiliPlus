import 'package:PiliPlus/features/dynamics_tab/data/datasources/dyn_tab_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_tab/domain/repositories/dyn_tab_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';

/// Implementation of dynamics tab repository
class DynTabRepositoryImpl implements DynTabRepository {
  final DynTabRemoteDatasource _remoteDatasource;

  DynTabRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoadingState<dynamic>> followDynamic({
    required DynamicsTabType type,
    required String offset,
    int? mid,
    required Set<int> tempBannedList,
  }) {
    return _remoteDatasource.followDynamic(
      type: type,
      offset: offset,
      mid: mid,
      tempBannedList: tempBannedList,
    );
  }

  @override
  Future<LoadingState> removeDynamic({required String dynIdStr}) {
    return _remoteDatasource.removeDynamic(dynIdStr: dynIdStr);
  }
}
