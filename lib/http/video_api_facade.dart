import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models/video/video_detail/video_detail_response.dart';
import 'package:PiliPlus/src/rust/api/video.dart' as rust;
import 'package:PiliPlus/src/rust/adapters/video_adapter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for video API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for video API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustVideoApi] is `true`, attempts to use the Rust implementation
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
/// final response = await VideoApiFacade.getVideoInfo('BV1xx411c7mD');
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustVideoApi] (stored in Hive)
/// - Default: `false` (uses Flutter implementation)
class VideoApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  VideoApiFacade._();

  /// Get video information from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustVideoApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `bvid`: The Bilibili video ID (e.g., 'BV1xx411c7mD')
  ///
  /// **Returns:**
  /// - [Future<VideoDetailResponse>] containing video information
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustVideoApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetVideoInfo]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustVideoApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetVideoInfo]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap errors in a [VideoDetailResponse] with error information
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final response = await VideoApiFacade.getVideoInfo('BV1xx411c7mD');
  ///   if (response.data != null) {
  ///     print('Video title: ${response.data!.title}');
  ///   } else if (response.code != 0) {
  ///     print('Error: ${response.message}');
  ///   }
  /// } catch (e) {
  ///   print('Unexpected error: $e');
  /// }
  /// ```
  static Future<VideoDetailResponse> getVideoInfo(String bvid) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustVideoApi;
    } catch (e) {
      // GStorage not initialized (e.g., in tests), default to Flutter
      if (kDebugMode) {
        debugPrint('GStorage not initialized, using Flutter implementation');
      }
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_call');
      try {
        // Try Rust implementation first
        final result = await _rustGetVideoInfo(bvid);
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust video API failed for $bvid: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetVideoInfo(bvid);
      }
    } else {
      // Use Flutter implementation
      return _flutterGetVideoInfo(bvid);
    }
  }

  /// Flutter/Dart implementation of video info retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details (Task 44):**
  /// - Makes GET request to [Api.videoIntro] with the provided [bvid]
  /// - Handles response parsing and error cases
  /// - Returns a [VideoDetailResponse] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<VideoDetailResponse> _flutterGetVideoInfo(String bvid) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final response = await Request().get(
        Api.videoIntro,
        queryParameters: {'bvid': bvid},
      );

      stopwatch.stop();
      return VideoDetailResponse.fromJson(response.data);
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Flutter video API failed: $e');
      }
      rethrow;
    }
  }

  /// Rust implementation of video info retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [rust.getVideoInfo] from `package:PiliPlus/src/rust/api/video.dart`
  /// - Converts Rust [VideoInfo] model to Flutter [VideoDetailData] via [VideoAdapter]
  /// - Wraps the result in a [VideoDetailResponse]
  /// - Handles Rust-specific errors and converts them to API error format
  ///
  /// **Advantages:**
  /// - Faster JSON parsing (Rust serde)
  /// - Lower memory footprint
  /// - Better performance for large responses
  ///
  /// **Disadvantages:**
  /// - Additional FFI overhead
  /// - Different error handling patterns
  static Future<VideoDetailResponse> _rustGetVideoInfo(String bvid) async {
    try {
      // Call Rust bridge API
      final rustVideo = await rust.getVideoInfo(bvid: bvid);

      // Convert Rust model to Flutter model
      final videoData = VideoAdapter.fromRust(rustVideo);

      // Wrap in response
      return VideoDetailResponse(
        code: 0,
        data: videoData,
        message: 'success',
      );
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust video API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
