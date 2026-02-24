import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/features/member_dynamics/domain/repositories/member_dynamics_repository.dart';
import 'package:PiliPlus/features/member_dynamics/data/datasources/member_dynamics_remote_datasource.dart';

/// Repository implementation for member dynamics data
class MemberDynamicsRepositoryImpl implements MemberDynamicsRepository {
  const MemberDynamicsRepositoryImpl(this._datasource);

  final MemberDynamicsRemoteDatasource _datasource;

  @override
  Future<LoadingState<DynamicsDataModel>> getMemberDynamics({
    required int mid,
    required String offset,
  }) =>
      _datasource.getMemberDynamics(
        mid: mid,
        offset: offset,
      );

  @override
  Future<LoadingState<void>> removeDynamic({required dynamic dynIdStr}) =>
      _datasource.removeDynamic(dynIdStr: dynIdStr);

  @override
  Future<LoadingState<void>> setDynamicTop({
    required dynamic dynamicId,
    required bool isTop,
  }) =>
      isTop
          ? _datasource.rmDynamicTop(dynamicId: dynamicId)
          : _datasource.setDynamicTop(dynamicId: dynamicId);
}
