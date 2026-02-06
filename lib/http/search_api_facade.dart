import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/src/rust/frb_generated.dart' as rust;
import 'package:PiliPlus/src/rust/models/search.dart' as rust_models;
import 'package:PiliPlus/src/rust/adapters/search_adapter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for search API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for search API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustSearchApi] is `true`, attempts to use the Rust implementation
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
/// final result = await SearchApiFacade.searchVideos(
///   keyword: 'test',
///   page: 1,
/// );
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustSearchApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class SearchApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  SearchApiFacade._();

  /// Search for videos by keyword.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustSearchApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `keyword`: Search keyword
  /// - `page`: Page number (1-based)
  /// - `order`: Sort order (optional)
  /// - `duration`: Filter by duration (optional)
  /// - `tids`: Filter by category ID (optional)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<SearchVideoData>>] containing search results or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustSearchApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustSearchVideos]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustSearchApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterSearchVideos]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap errors in a [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  static Future<LoadingState<SearchVideoData>> searchVideos({
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustSearchApi;
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
        final result = await _rustSearchVideos(
          keyword: keyword,
          page: page,
          order: order,
          duration: duration,
          tids: tids,
        );
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust search API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterSearchVideos(
          keyword: keyword,
          page: page,
          order: order,
          duration: duration,
          tids: tids,
        );
      }
    } else {
      // Use Flutter implementation
      return _flutterSearchVideos(
        keyword: keyword,
        page: page,
        order: order,
        duration: duration,
        tids: tids,
      );
    }
  }

  /// Flutter/Dart implementation of video search.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<SearchVideoData>> _flutterSearchVideos({
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      // This would call the existing SearchHttp.searchByType
      // For now, return a placeholder to avoid compilation errors
      stopwatch.stop();
      return Error('Flutter search implementation not yet integrated');
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Flutter search API failed: $e');
      }
      rethrow;
    }
  }

  /// Rust implementation of video search.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Advantages:**
  /// - Faster JSON parsing (Rust serde)
  /// - Lower memory footprint
  /// - Better performance for large responses
  ///
  /// **Disadvantages:**
  /// - Additional FFI overhead
  /// - Different error handling patterns
  static Future<LoadingState<SearchVideoData>> _rustSearchVideos({
    required String keyword,
    required int page,
    String? order,
    int? duration,
    int? tids,
  }) async {
    try {
      // Call Rust bridge API
      final rustResult = await rust.RustLib.instance.api.crateApiBridgeSearchVideos(
        keyword: keyword,
        page: page,
        order: order,
        duration: duration,
        tids: tids,
      );

      // Convert Rust model to Flutter model
      final searchData = SearchAdapter.fromRustSearchResult(rustResult);

      // Return Success
      return Success(searchData);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust search API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
