import 'package:PiliPlus/features/dynamics_detail/data/datasources/dyn_detail_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_detail/domain/repositories/dyn_detail_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of dynamics detail repository
class DynDetailRepositoryImpl implements DynDetailRepository {
  final DynDetailRemoteDatasource _remoteDatasource;

  DynDetailRepositoryImpl(this._remoteDatasource);

  @override
  Future<LoadingState<dynamic>> dynamicDetail({required String id}) {
    return _remoteDatasource.dynamicDetail(id: id);
  }

  @override
  Future<LoadingState> setPubSetting({
    required Object dynId,
    required String action,
  }) {
    return _remoteDatasource.setPubSetting(
      dynId: dynId,
      action: action,
    );
  }

  @override
  Future<LoadingState> setReplySubject({
    required int oid,
    required int type,
    required int action,
  }) {
    return _remoteDatasource.setReplySubject(
      oid: oid,
      type: type,
      action: action,
    );
  }
}
