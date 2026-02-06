import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/src/rust/adapters/comments_adapter.dart';
import 'package:PiliPlus/src/rust/api/comments.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for comments API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for comments API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustCommentsApi] is `true`, attempts to use the Rust implementation
/// - Automatically falls back to Flutter implementation if Rust fails
/// - In debug mode, logs implementation choice and any errors
///
/// **Benefits:**
/// - Easy A/B testing between Rust and Flutter implementations
/// - Seamless rollout and rollback via feature flag
/// - Graceful degradation if Rust implementation encounters errors
///
/// **Usage:**
/// ```dart
/// final result = await CommentsApiFacade.getComments(oid: 123456, page: 1);
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustCommentsApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class CommentsApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  CommentsApiFacade._();

  /// Get comments for a video or other content from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustCommentsApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `oid`: The ID of the content (e.g., video ID)
  /// - `page`: Page number (0-indexed)
  /// - `pageSize`: Number of comments per page (default: 20)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<ReplyData>>] containing comments data or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustCommentsApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetComments]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustCommentsApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetComments]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap results in [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// final result = await CommentsApiFacade.getComments(oid: 123456, page: 0);
  /// switch (result) {
  ///   case Success<ReplyData>(:final data):
  ///     print('Got ${data.replies?.length ?? 0} comments');
  ///     break;
  ///   case Error<ReplyData>(:final error):
  ///     print('Error: $error');
  ///     break;
  /// }
  /// ```
  static Future<LoadingState<ReplyData>> getComments({
    required int oid,
    int page = 0,
    int pageSize = 20,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true; // Default to true
    try {
      useRust = Pref.useRustCommentsApi;
    } catch (e) {
      // GStorage not initialized (e.g., in tests), default to Rust
      if (kDebugMode) {
        debugPrint('GStorage not initialized, using Rust implementation');
      }
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_call');
      try {
        // Try Rust implementation first
        final result = await _rustGetComments(
          oid: oid,
          page: page,
          pageSize: pageSize,
        );
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust comments API failed for oid $oid: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetComments(oid: oid, page: page, pageSize: pageSize);
      }
    } else {
      // Use Flutter implementation
      return _flutterGetComments(oid: oid, page: page, pageSize: pageSize);
    }
  }

  /// Flutter/Dart implementation of comments retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.replyList] with the provided parameters
  /// - Handles response parsing and error cases
  /// - Returns a [LoadingState<ReplyData>] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<ReplyData>> _flutterGetComments({
    required int oid,
    required int page,
    required int pageSize,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final response = await Request().get(
        Api.replyList,
        queryParameters: {
          'oid': oid,
          'type': 1, // Video comment type
          'mode': 3, // Sort by hot
          'pn': page + 1, // API uses 1-indexed pages
          'ps': pageSize,
        },
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        return Success(ReplyData.fromJson(response.data['data']));
      } else {
        return Error(response.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and return error
      if (kDebugMode) {
        debugPrint('Flutter comments API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of comments retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [rust.getVideoComments] from `package:PiliPlus/src/rust/api/comments.dart`
  /// - Converts Rust [CommentList] model to Flutter [ReplyData] via [CommentsAdapter]
  /// - Wraps the result in a [LoadingState]
  /// - Handles Rust-specific errors and converts them to error format
  ///
  /// **Advantages:**
  /// - Faster JSON parsing (Rust serde)
  /// - Lower memory footprint
  /// - Better performance for large responses
  ///
  /// **Disadvantages:**
  /// - Additional FFI overhead
  /// - Different error handling patterns
  /// - Simplified data model (fewer fields than Flutter API)
  static Future<LoadingState<ReplyData>> _rustGetComments({
    required int oid,
    required int page,
    required int pageSize,
  }) async {
    try {
      // Call Rust bridge API
      // Note: PlatformInt64 is the internal representation, but in Dart it's just int
      final rustCommentList = await getVideoComments(
        oid: oid,
        page: page,
        pageSize: pageSize,
      );

      // Convert Rust model to Flutter model
      final replyData = CommentsAdapter.fromRust(rustCommentList);

      // Return success
      return Success(replyData);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust comments API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
