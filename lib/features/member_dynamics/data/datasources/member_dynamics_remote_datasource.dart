import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/msg.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// Remote datasource for member dynamics data
class MemberDynamicsRemoteDatasource {
  const MemberDynamicsRemoteDatasource();

  /// Get member dynamics with pagination
  Future<LoadingState<DynamicsDataModel>> getMemberDynamics({
    required int mid,
    required String offset,
  }) =>
      MemberHttp.memberDynamic(
        offset: offset,
        mid: mid,
      );

  /// Remove a dynamic post
  Future<LoadingState<void>> removeDynamic({required dynamic dynIdStr}) =>
      MsgHttp.removeDynamic(dynIdStr: dynIdStr);

  /// Set dynamic as top
  Future<LoadingState<void>> setDynamicTop({required dynamic dynamicId}) =>
      DynamicsHttp.setTop(dynamicId: dynamicId);

  /// Remove dynamic from top
  Future<LoadingState<void>> rmDynamicTop({required dynamic dynamicId}) =>
      DynamicsHttp.rmTop(dynamicId: dynamicId);
}
