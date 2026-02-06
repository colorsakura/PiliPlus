import 'package:PiliPlus/http/comments_api_facade.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/utils/storage_pref.dart';

/// Simplified comments API that routes between Rust and Flutter implementations.
///
/// This provides a simpler interface than [ReplyHttp.replyList] for basic comment
/// fetching. For advanced features (login status, pagination offset, sorting),
/// use [ReplyHttp.replyList] directly.
///
/// **Routing:**
/// - Uses [CommentsApiFacade] which handles Rust/Flutter routing
/// - Controlled by [Pref.useRustCommentsApi]
/// - Automatic fallback to Flutter on error
///
/// **Usage:**
/// ```dart
/// final result = CommentsApi.getReplyList(oid: 123456);
/// ```
abstract final class CommentsApi {
  /// Get comments for a video or other content.
  ///
  /// Simplified version of [ReplyHttp.replyList] that uses the facade.
  /// Only supports basic video comments (type=1, sorted by hot).
  ///
  /// For advanced features, use [ReplyHttp.replyList] directly.
  static Future<LoadingState<ReplyData>> getReplyList({
    required int oid,
    int page = 0,
    int pageSize = 20,
  }) {
    return CommentsApiFacade.getComments(
      oid: oid,
      page: page,
      pageSize: pageSize,
    );
  }
}
