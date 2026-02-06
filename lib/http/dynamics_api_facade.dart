import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/src/rust/adapters/dynamics_adapter.dart';
import 'package:PiliPlus/src/rust/api/dynamics.dart' as rust_api;
import 'package:PiliPlus/src/rust/models/video.dart' as rust_models;
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for dynamics API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for dynamics API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustDynamicsApi] is `true`, attempts to use the Rust implementation
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
/// final result = await DynamicsApiFacade.getUserDynamics(uid: 123456);
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustDynamicsApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class DynamicsApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  DynamicsApiFacade._();

  /// Get user dynamics/posts from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustDynamicsApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `uid`: The ID of the user
  /// - `offset`: Pagination offset
  /// - `type`: Dynamic type filter (only used in Flutter implementation)
  /// - `hostMid`: Host mid for UP dynamics (only used in Flutter implementation)
  /// - `tempBannedList`: List of temporarily banned user IDs (only used in Flutter implementation)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<DynamicsDataModel>>] containing dynamics data or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustDynamicsApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetUserDynamics]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustDynamicsApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetUserDynamics]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap results in [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// final result = await DynamicsApiFacade.getUserDynamics(uid: 123456);
  /// switch (result) {
  ///   case Success<DynamicsDataModel>(:final data):
  ///     print('Got ${data.items?.length ?? 0} dynamics');
  ///     break;
  ///   case Error<DynamicsDataModel>(:final error):
  ///     print('Error: $error');
  ///     break;
  /// }
  /// ```
  static Future<LoadingState<DynamicsDataModel>> getUserDynamics({
    required int uid,
    String? offset,
    DynamicsTabType type = DynamicsTabType.all,
    int? hostMid,
    Set<int>? tempBannedList,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true; // Default to true
    try {
      useRust = Pref.useRustDynamicsApi;
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
        final result = await _rustGetUserDynamics(
          uid: uid,
          offset: offset,
        );
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust dynamics API failed for uid $uid: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetUserDynamics(
          uid: uid,
          offset: offset,
          type: type,
          hostMid: hostMid,
          tempBannedList: tempBannedList,
        );
      }
    } else {
      // Use Flutter implementation
      return _flutterGetUserDynamics(
        uid: uid,
        offset: offset,
        type: type,
        hostMid: hostMid,
        tempBannedList: tempBannedList,
      );
    }
  }

  /// Get dynamics detail by ID from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustDynamicsApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `dynamicId`: The ID of the dynamic
  ///
  /// **Returns:**
  /// - [Future<LoadingState<DynamicItemModel>>] containing dynamic detail or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustDynamicsApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetDynamicsDetail]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustDynamicsApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetDynamicsDetail]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap results in [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// final result = await DynamicsApiFacade.getDynamicsDetail(dynamicId: '123456');
  /// switch (result) {
  ///   case Success<DynamicItemModel>(:final data):
  ///     print('Got dynamic: ${data.modules.moduleDynamic?.desc?.text}');
  ///     break;
  ///   case Error<DynamicItemModel>(:final error):
  ///     print('Error: $error');
  ///     break;
  /// }
  /// ```
  static Future<LoadingState<DynamicItemModel>> getDynamicsDetail({
    required String dynamicId,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true; // Default to true
    try {
      useRust = Pref.useRustDynamicsApi;
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
        final result = await _rustGetDynamicsDetail(dynamicId: dynamicId);
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust dynamics detail API failed for dynamicId $dynamicId: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetDynamicsDetail(dynamicId: dynamicId);
      }
    } else {
      // Use Flutter implementation
      return _flutterGetDynamicsDetail(dynamicId: dynamicId);
    }
  }

  /// Flutter/Dart implementation of user dynamics retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.followDynamic] with the provided parameters
  /// - Handles response parsing and error cases
  /// - Returns a [LoadingState<DynamicsDataModel>] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<DynamicsDataModel>> _flutterGetUserDynamics({
    required int uid,
    String? offset,
    DynamicsTabType type = DynamicsTabType.all,
    int? hostMid,
    Set<int>? tempBannedList,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      Map<String, dynamic> data = {
        if (type == DynamicsTabType.up) 'host_mid': hostMid else ...{
          'type': type.name,
          'timezone_offset': '-480',
        },
        'offset': offset,
        'features': 'itemOpusStyle,listOnlyfans',
      };

      final response = await Request().get(
        Api.followDynamic,
        queryParameters: data,
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        final dynamicsData = DynamicsDataModel.fromJson(
          response.data['data'],
          type: type,
          tempBannedList: tempBannedList,
        );

        // Handle automatic pagination if needed
        if (dynamicsData.loadNext == true) {
          return _flutterGetUserDynamics(
            uid: uid,
            offset: dynamicsData.offset,
            type: type,
            hostMid: hostMid,
            tempBannedList: tempBannedList,
          );
        }

        return Success(dynamicsData);
      } else {
        return Error(
          response.data['code'] == 4101132 ? '没有数据' : response.data['message'],
        );
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and return error
      if (kDebugMode) {
        debugPrint('Flutter dynamics API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Flutter/Dart implementation of dynamics detail retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.dynamicDetail] with the provided parameters
  /// - Handles response parsing and error cases
  /// - Returns a [LoadingState<DynamicItemModel>] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<DynamicItemModel>> _flutterGetDynamicsDetail({
    required String dynamicId,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final response = await Request().get(
        Api.dynamicDetail,
        queryParameters: {
          'timezone_offset': -480,
          'id': dynamicId,
          'features': 'itemOpusStyle',
          'gaia_source': 'Athena',
          'web_location': '333.1330',
          'x-bili-device-req-json':
              '{"platform":"web","device":"pc","spmid":"333.1330"}',
        },
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        return Success(DynamicItemModel.fromJson(response.data['data']['item']));
      } else {
        return Error(response.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and return error
      if (kDebugMode) {
        debugPrint('Flutter dynamics detail API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of user dynamics retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [getUserDynamics] from `package:PiliPlus/src/rust/api/dynamics.dart`
  /// - Converts Rust [DynamicsList] model to Flutter [DynamicsDataModel] via [DynamicsAdapter]
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
  static Future<LoadingState<DynamicsDataModel>> _rustGetUserDynamics({
    required int uid,
    String? offset,
  }) async {
    try {
      // Call Rust bridge API
      // Note: PlatformInt64 is the internal representation, but in Dart it's just int
      final rust_models.DynamicsList rustDynamicsList = await rust_api.getUserDynamics(
        uid: uid,
        offset: offset,
      );

      // Convert Rust model to Flutter model
      final dynamicsData = DynamicsAdapter.fromRustList(rustDynamicsList);

      // Return success
      return Success(dynamicsData);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust dynamics API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  /// Rust implementation of dynamics detail retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [getDynamicsDetail] from `package:PiliPlus/src/rust/api/dynamics.dart`
  /// - Converts Rust [DynamicsItem] model to Flutter [DynamicItemModel] via [DynamicsAdapter]
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
  static Future<LoadingState<DynamicItemModel>> _rustGetDynamicsDetail({
    required String dynamicId,
  }) async {
    try {
      // Call Rust bridge API
      final rust_models.DynamicsItem rustDynamicsItem = await rust_api.getDynamicsDetail(dynamicId: dynamicId);

      // Convert Rust model to Flutter model
      final dynamicItem = DynamicsAdapter.fromRustItem(rustDynamicsItem);

      // Return success
      return Success(dynamicItem);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust dynamics detail API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
