import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/request_utils.dart';

/// Share remote data source interface
abstract class ShareRemoteDataSource {
  /// Send share message to a user
  Future<bool> sendShareMessage({
    required int receiverId,
    required Map content,
    String? message,
  });
}

/// Share remote data source implementation
class ShareRemoteDataSourceImpl implements ShareRemoteDataSource {
  const ShareRemoteDataSourceImpl();

  @override
  Future<bool> sendShareMessage({
    required int receiverId,
    required Map content,
    String? message,
  }) async {
    return RequestUtils.pmShare(
      receiverId: receiverId,
      content: content,
      message: message,
    );
  }
}
