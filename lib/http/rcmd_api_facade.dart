import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/model_video.dart';
import 'package:PiliPlus/src/rust/adapters/rcmd_adapter.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/wbi_sign.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

// Conditional imports for Rust components
import 'package:PiliPlus/src/rust/api/rcmd.dart' as rust;
import 'package:PiliPlus/src/rust/error/api_error.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';

/// Facade for recommendation API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for
/// recommendation API operations, abstracting away whether the underlying implementation
/// is Rust-based or Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustRcmdApi] is `true`, attempts to use the Rust implementation
/// - Automatically falls back to Flutter implementation if Rust fails
/// - In debug mode, logs implementation choice and any errors
///
/// **Benefits:**
/// - Easy A/B testing between Rust and Flutter implementations
/// - Seamless rollout and rollback via feature flag
/// - Graceful degradation if Rust implementation encounters errors
/// - Same filtering logic applied to both implementations
///
/// **Usage:**
/// ```dart
/// final response = await RcmdApiFacade.getRecommendList(ps: 20, freshIdx: 0);
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustRcmdApi] (stored in Hive)
/// - Default: `false` (uses Flutter implementation)
class RcmdApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  RcmdApiFacade._();

  /// Get recommendation list from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustRcmdApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  /// Applies the same filtering logic to both implementations.
  ///
  /// **Parameters:**
  /// - `ps`: Page size (number of recommendations to fetch, usually 20)
  /// - `freshIdx`: Freshness index for recommendations (0, 1, 2...)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<List<RecVideoItemModel>>>] containing recommendation list
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustRcmdApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetRecommendList]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  ///    - Applies filters in Dart layer (same as Flutter implementation)
  /// 2. If [Pref.useRustRcmdApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetRecommendList]
  ///    - Applies filters in Dart layer
  ///
  /// **Error Handling:**
  /// - Both implementations wrap errors in a [LoadingState] with error information
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  /// - Blacklist filtering is applied to both implementations
  ///
  /// **Filtering:**
  /// - Only keeps video type (goto='av')
  /// - Filters blocked UP owners via [GlobalData().blackMids]
  /// - Applies [RecommendFilter] to filter content
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   final result = await RcmdApiFacade.getRecommendList(ps: 20, freshIdx: 0);
  ///   if (result is Success) {
  ///     final videos = (result as Success).response;
  ///     print('Found ${videos.length} recommendations');
  ///   } else if (result is Error) {
  ///     print('Error: ${(result as Error).message}');
  ///   }
  /// } catch (e) {
  ///   print('Unexpected error: $e');
  /// }
  /// ```
  static Future<LoadingState<List<RecVideoItemModel>>> getRecommendList({
    required int ps,
    required int freshIdx,
  }) async {
    // Check feature flag
    if (Pref.useRustRcmdApi) {
      // Try to use Rust implementation if available
      try {
        // Check if Rust bridge is available
        final rustAvailable = await _isRustAvailable();
        if (rustAvailable) {
          // Use Rust implementation with metrics
          return await _getRecommendListWithRust(ps, freshIdx);
        }
      } catch (e) {
        // Rust not available, fallback to Flutter
        if (kDebugMode) {
          debugPrint('Rust bridge not available, using Flutter: $e');
        }
      }
    }

    // Use Flutter implementation
    return await _flutterGetRecommendList(ps, freshIdx);
  }

  /// Check if Rust bridge is available
  static Future<bool> _isRustAvailable() async {
    try {
      // Try to access Rust API
      // This will throw if Rust bridge is not available
      await rust.getRecommendList(ps: 1, freshIdx: 0);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get recommendation list using Rust implementation with metrics and fallback
  static Future<LoadingState<List<RecVideoItemModel>>> _getRecommendListWithRust(
    int ps,
    int freshIdx,
  ) async {
    final stopwatch = RustMetricsStopwatch('rust_rcmd_call');
    try {
      // Try Rust implementation first
      final rustList = await _rustGetRecommendList(ps, freshIdx);
      stopwatch.stop();

      // Apply filters in Dart layer (same as Flutter implementation)
      final filteredList = _applyFilters(rustList);

      return Success(filteredList);
    } catch (e, stack) {
      // Record fallback and error
      stopwatch.stopAsFallback(e.toString());
      RustApiMetrics.recordError('RustRcmdFallback');

      // Fallback to Flutter on any error
      if (kDebugMode) {
        debugPrint('Rust rcmd API failed: $e');
        debugPrint('Stack trace: $stack');
        debugPrint('Falling back to Flutter implementation');
      }
      return await _flutterGetRecommendList(ps, freshIdx);
    }
  }

  /// Flutter/Dart implementation of recommendation list retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API with WBI signature.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.recommendListWeb] with WBI signing
  /// - Handles response parsing and error cases
  /// - Applies blacklist and content filtering
  /// - Returns a [LoadingState] with the same structure as Rust
  ///
  /// **Filtering Logic:**
  /// - Only keeps video type (goto='av')
  /// - Filters blocked UP owners via [GlobalData().blackMids]
  /// - Applies [RecommendFilter] to filter content
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  /// - Same filtering logic as original implementation
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<List<RecVideoItemModel>>> _flutterGetRecommendList(
    int ps,
    int freshIdx,
  ) async {
    final stopwatch = RustMetricsStopwatch('flutter_rcmd_call');
    try {
      // Make request with WBI signing
      final response = await Request().get(
        Api.recommendListWeb,
        queryParameters: await WbiSign.makSign({
          'version': 1,
          'feed_version': 'V8',
          'homepage_ver': 1,
          'ps': ps,
          'fresh_idx': freshIdx,
          'brush': freshIdx,
          'fresh_type': 4,
        }),
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        // Parse response and apply filters
        List<RecVideoItemModel> list = [];
        for (final i in response.data['data']['item']) {
          if (i['goto'] == 'av' &&
              (i['owner'] != null &&
                  !GlobalData().blackMids.contains(i['owner']['mid']))) {
            RecVideoItemModel videoItem = RecVideoItemModel.fromJson(i);
            if (!RecommendFilter.filter(videoItem)) {
              list.add(videoItem);
            }
          }
        }
        return Success(list);
      } else {
        return Error(response.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterRcmdError');

      // Log and return error state
      if (kDebugMode) {
        debugPrint('Flutter rcmd API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of recommendation list retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [rust.getRecommendList] from `package:PiliPlus/src/rust/api/rcmd.dart`
  /// - Converts Rust models to Flutter models via [RcmdAdapter]
  /// - Handles Rust-specific errors and converts them to API error format
  /// - Note: Filtering is applied in Dart layer for consistency
  ///
  /// **Advantages:**
  /// - Faster JSON parsing (Rust serde)
  /// - Lower memory footprint
  /// - Better performance for large responses
  /// - WBI signature handled natively in Rust
  ///
  /// **Disadvantages:**
  /// - Additional FFI overhead
  /// - Different error handling patterns
  /// - May have subtle behavioral differences
  static Future<List<RecVideoItemModel>> _rustGetRecommendList(
    int ps,
    int freshIdx,
  ) async {
    try {
      // Call Rust bridge API
      final rustList = await rust.getRecommendList(
        ps: ps,
        freshIdx: freshIdx,
      );

      // Convert Rust models to Flutter models
      return RcmdAdapter.fromRustList(rustList);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust rcmd API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  /// Apply filters to the recommendation list.
  ///
  /// This method applies the same filtering logic as the original Flutter implementation:
  /// - Only keeps video type (goto='av')
  /// - Filters blocked UP owners via [GlobalData().blackMids]
  /// - Applies [RecommendFilter] to filter content
  ///
  /// **Parameters:**
  /// - `videos`: List of RecVideoItemModel to filter
  ///
  /// **Returns:**
  /// - Filtered list containing only valid video recommendations
  static List<RecVideoItemModel> _applyFilters(List<RecVideoItemModel> videos) {
    List<RecVideoItemModel> filteredList = [];

    for (final video in videos) {
      // Apply the same filtering logic as Flutter implementation
      if (video.goto == 'av' &&
          (video.owner != null &&
              !GlobalData().blackMids.contains(video.owner.mid))) {
        if (!RecommendFilter.filter(video)) {
          filteredList.add(video);
        }
      }
    }

    return filteredList;
  }
}