import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/reply/data/datasources/reply_remote_datasource.dart';

/// Remote data source for dynamics detail
///
/// Fetches dynamic detail and settings from the Bilibili API.
class DynDetailRemoteDatasource {
  final ReplyRemoteDataSource _replyDataSource = ReplyRemoteDataSource();

  /// Fetch dynamic detail by ID
  Future<LoadingState<dynamic>> dynamicDetail({required String id}) {
    return DynamicsHttp.dynamicDetail(id: id);
  }

  /// Set dynamic visibility (private/public)
  Future<LoadingState> setPubSetting({
    required Object dynId,
    required String action,
  }) {
    return DynamicsHttp.dynPrivatePubSetting(
      dynId: dynId,
      action: action,
    );
  }

  /// Modify reply subject settings
  Future<LoadingState> setReplySubject({
    required int oid,
    required int type,
    required int action,
  }) {
    return _replyDataSource.replySubjectModify(
      oid: oid,
      type: type,
      action: action,
    );
  }
}
