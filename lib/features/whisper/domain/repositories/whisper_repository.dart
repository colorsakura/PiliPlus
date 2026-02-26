import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for whisper (private message) operations
abstract class WhisperRepository {
  /// Fetch session list (main chat list)
  ///
  /// [offset] is pagination offset
  ///
  /// Returns [Success] with session list, or [Error] if failed
  Future<LoadingState<dynamic>> fetchSessions({
    dynamic offset,
  });

  /// Fetch unread message counts
  ///
  /// Returns [Success] with unread counts, or [Error] if failed
  Future<LoadingState<dynamic>> fetchUnreadCounts();
}
