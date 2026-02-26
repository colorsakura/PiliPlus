import 'package:PiliPlus/http/loading_state.dart';

/// Data source interface for whisper operations
abstract class WhisperRemoteDataSource {
  /// Fetch session list via gRPC API
  Future<LoadingState<dynamic>> fetchSessions({
    dynamic offset,
  });

  /// Fetch unread message counts via gRPC API
  Future<LoadingState<dynamic>> fetchUnreadCounts();
}
