import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/login.dart';
import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/src/rust/adapters/rcmd_app_adapter.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/recommend_filter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

// Conditional imports for Rust components
import 'package:PiliPlus/src/rust/api/rcmd_app.dart' as rust;
import 'package:PiliPlus/utils/rust_api_metrics.dart';

/// Facade for APP recommendation API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for
/// APP recommendation API operations, abstracting away whether the underlying implementation
/// is Rust-based or Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustRcmdAppApi] is `true`, attempts to use the Rust implementation
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
/// final response = await RcmdAppApiFacade.getRecommendList(ps: 20, freshIdx: 0);
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustRcmdAppApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class RcmdAppApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  RcmdAppApiFacade._();

  /// Get APP recommendation list from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustRcmdAppApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  /// Applies the same filtering logic to both implementations.
  ///
  /// **Parameters:**
  /// - `ps`: Page size (number of recommendations to fetch, usually 20)
  /// - `freshIdx`: Freshness index for recommendations (idx parameter)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<List<RecVideoItemAppModel>>>] containing recommendation list
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustRcmdAppApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetRecommendList]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  ///    - Applies filters in Dart layer (same as Flutter implementation)
  /// 2. If [Pref.useRustRcmdAppApi] is `false`:
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
  ///   final result = await RcmdAppApiFacade.getRecommendList(ps: 20, freshIdx: 0);
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
  static Future<LoadingState<List<RecVideoItemAppModel>>> getRecommendList({
    required int ps,
    required int freshIdx,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustRcmdAppApi;
    } catch (e) {
      // GStorage not initialized (e.g., in tests), default to Flutter
      if (kDebugMode) {
        debugPrint('GStorage not initialized, using Flutter implementation');
      }
    }

    if (useRust) {
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
    return _flutterGetRecommendList(ps, freshIdx);
  }

  /// Check if Rust bridge is available
  static Future<bool> _isRustAvailable() async {
    try {
      // Try to access Rust API
      // This will throw if Rust bridge is not available
      await rust.getRecommendListApp(ps: 1, freshIdx: 0);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get recommendation list using Rust implementation with metrics and fallback
  static Future<LoadingState<List<RecVideoItemAppModel>>>
  _getRecommendListWithRust(
    int ps,
    int freshIdx,
  ) async {
    final stopwatch = RustMetricsStopwatch('rust_rcmd_app_call');
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
      RustApiMetrics.recordError('RustRcmdAppFallback');

      // Fallback to Flutter on any error
      if (kDebugMode) {
        debugPrint('Rust rcmd APP API failed: $e');
        debugPrint('Stack trace: $stack');
        debugPrint('Falling back to Flutter implementation');
      }
      return _flutterGetRecommendList(ps, freshIdx);
    }
  }

  /// Flutter/Dart implementation of APP recommendation list retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's APP API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.recommendListApp]
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
  static Future<LoadingState<List<RecVideoItemAppModel>>>
  _flutterGetRecommendList(
    int ps,
    int freshIdx,
  ) async {
    final stopwatch = RustMetricsStopwatch('flutter_rcmd_app_call');
    try {
      final params = {
        'build': 2001100,
        'c_locale': 'zh_CN',
        'channel': 'master',
        'column': 4,
        'device': 'pad',
        'device_name': 'android',
        'device_type': 0,
        'disable_rcmd': 0,
        'flush': 5,
        'fnval': 976,
        'fnver': 0,
        'force_host': 2, //使用https
        'fourk': 1,
        'guidance': 0,
        'https_url_req': 0,
        'idx': freshIdx,
        'mobi_app': 'android_hd',
        'network': 'wifi',
        'platform': 'android',
        'player_net': 1,
        'pull': freshIdx == 0 ? 'true' : 'false',
        'qn': 32,
        'recsys_mode': 0,
        's_locale': 'zh_CN',
        'splash_id': '',
        'statistics': Constants.statistics,
        'voice_balance': 0,
        'ps': ps,
      };

      final res = await Request().get(
        Api.recommendListApp,
        queryParameters: params,
        options: Options(
          headers: {
            'buvid': LoginHttp.buvid,
            'fp_local':
                '1111111111111111111111111111111111111111111111111111111111111111',
            'fp_remote':
                '1111111111111111111111111111111111111111111111111111111111111111',
            'session_id': '11111111',
            'env': 'prod',
            'app-key': 'android_hd',
            'User-Agent': Constants.userAgent,
            'x-bili-trace-id': Constants.traceId,
            'x-bili-aurora-eid': '',
            'x-bili-aurora-zone': '',
            'bili-http-engine': 'cronet',
          },
        ),
      );

      stopwatch.stop();

      if (res.data['code'] == 0) {
        List<RecVideoItemAppModel> list = [];
        for (final i in res.data['data']['items']) {
          // 过滤广告和非视频内容
          if (i['card_goto'] == 'av' &&
              i['ad_info'] == null &&
              i['player_args']?['aid'] != null) {
            RecVideoItemAppModel videoItem = RecVideoItemAppModel.fromJson(i);
            // 过滤拉黑UP主
            if (!GlobalData().blackMids.contains(videoItem.owner.mid)) {
              // 内容过滤
              if (!RecommendFilter.filter(videoItem)) {
                list.add(videoItem);
              }
            }
          }
        }
        return Success(list);
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterRcmdAppError');

      // Log and return error state
      if (kDebugMode) {
        debugPrint('Flutter rcmd APP API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of APP recommendation list retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [rust.getRecommendListApp] from `package:PiliPlus/src/rust/api/rcmd_app.dart`
  /// - Converts Rust models to Flutter models via [RcmdAppAdapter]
  /// - Handles Rust-specific errors and converts them to API error format
  /// - Note: Filtering is applied in Dart layer for consistency
  ///
  /// **Advantages:**
  /// - Faster JSON parsing (Rust serde)
  /// - Lower memory footprint
  /// - Better performance for large responses
  ///
  /// **Disadvantages:**
  /// - Additional FFI overhead
  /// - Different error handling patterns
  /// - May have subtle behavioral differences
  static Future<List<RecVideoItemAppModel>> _rustGetRecommendList(
    int ps,
    int freshIdx,
  ) async {
    try {
      // Call Rust bridge API
      final rustList = await rust.getRecommendListApp(
        ps: ps,
        freshIdx: freshIdx,
      );

      // Convert Rust models to Flutter models
      return RcmdAppAdapter.fromRustList(rustList);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust rcmd APP API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  /// Apply filters to the APP recommendation list.
  ///
  /// This method applies the same filtering logic as the original Flutter implementation:
  /// - Only keeps video type (goto='av')
  /// - Filters blocked UP owners via [GlobalData().blackMids]
  /// - Applies [RecommendFilter] to filter content
  ///
  /// **Parameters:**
  /// - `videos`: List of RecVideoItemAppModel to filter
  ///
  /// **Returns:**
  /// - Filtered list containing only valid video recommendations
  static List<RecVideoItemAppModel> _applyFilters(
    List<RecVideoItemAppModel> videos,
  ) {
    List<RecVideoItemAppModel> filteredList = [];

    for (final video in videos) {
      // Apply the same filtering logic as Flutter implementation
      // owner is late and non-null, but owner.mid can be null
      if (video.goto == 'av' &&
          video.owner.mid != null &&
          !GlobalData().blackMids.contains(video.owner.mid)) {
        if (!RecommendFilter.filter(video)) {
          filteredList.add(video);
        }
      }
    }

    return filteredList;
  }
}
