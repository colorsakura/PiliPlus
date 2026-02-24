import 'package:PiliPlus/http/loading_state.dart';

/// Repository for dynamics detail operations
abstract class DynDetailRepository {
  /// Fetch dynamic detail by ID
  Future<LoadingState<dynamic>> dynamicDetail({required String id});

  /// Set dynamic visibility (private/public)
  Future<LoadingState> setPubSetting({
    required Object dynId,
    required String action,
  });

  /// Modify reply subject settings
  Future<LoadingState> setReplySubject({
    required int oid,
    required int type,
    required int action,
  });
}
