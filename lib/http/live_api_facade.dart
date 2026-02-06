import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_room_info_h5/data.dart';
import 'package:PiliPlus/models/live/live_room_play_info/data.dart';
import 'package:PiliPlus/src/rust/adapters/live_adapter.dart';
import 'package:PiliPlus/src/rust/api/live.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for live API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for live API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustLiveApi] is `true`, attempts to use the Rust implementation
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
/// final roomInfo = await LiveApiFacade.getRoomInfo(roomId: 123456);
/// final playUrl = await LiveApiFacade.getPlayUrl(roomId: 123456, quality: 10000);
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustLiveApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class LiveApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  LiveApiFacade._();

  /// Get live room information from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustLiveApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `roomId`: The ID of the live room
  ///
  /// **Returns:**
  /// - [Future<LoadingState<RoomInfoH5Data>>] containing room information or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustLiveApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetRoomInfo]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustLiveApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetRoomInfo]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap results in [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// final result = await LiveApiFacade.getRoomInfo(roomId: 123456);
  /// switch (result) {
  ///   case Success<RoomInfoH5Data>(:final data):
  ///     print('Room: ${data.roomInfo?.title}');
  ///     break;
  ///   case Error<RoomInfoH5Data>(:final error):
  ///     print('Error: $error');
  ///     break;
  /// }
  /// ```
  static Future<LoadingState<RoomInfoH5Data>> getRoomInfo({
    required int roomId,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true; // Default to true
    try {
      useRust = Pref.useRustLiveApi;
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
        final result = await _rustGetRoomInfo(roomId: roomId);
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust live room info API failed for roomId $roomId: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetRoomInfo(roomId: roomId);
      }
    } else {
      // Use Flutter implementation
      return _flutterGetRoomInfo(roomId: roomId);
    }
  }

  /// Get live playback URLs from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustLiveApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `roomId`: The ID of the live room
  /// - `quality`: Quality code (default: 10000 for origin/4K)
  ///
  /// **Returns:**
  /// - [Future<LoadingState<RoomPlayInfoData>>] containing playback URLs or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustLiveApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustGetPlayUrl]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustLiveApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterGetPlayUrl]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap results in [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  ///
  /// **Example:**
  /// ```dart
  /// final result = await LiveApiFacade.getPlayUrl(roomId: 123456, quality: 10000);
  /// switch (result) {
  ///   case Success<RoomPlayInfoData>(:final data):
  ///     print('Got ${data.playurlInfo?.playurl?.stream?.length} streams');
  ///     break;
  ///   case Error<RoomPlayInfoData>(:final error):
  ///     print('Error: $error');
  ///     break;
  /// }
  /// ```
  static Future<LoadingState<RoomPlayInfoData>> getPlayUrl({
    required int roomId,
    int quality = 10000,
  }) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true; // Default to true
    try {
      useRust = Pref.useRustLiveApi;
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
        final result = await _rustGetPlayUrl(roomId: roomId, quality: quality);
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust live play URL API failed for roomId $roomId: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterGetPlayUrl(roomId: roomId, quality: quality);
      }
    } else {
      // Use Flutter implementation
      return _flutterGetPlayUrl(roomId: roomId, quality: quality);
    }
  }

  /// Flutter/Dart implementation of live room info retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.liveRoomInfoH5] with the room ID
  /// - Handles response parsing and error cases
  /// - Returns a [LoadingState<RoomInfoH5Data>] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<RoomInfoH5Data>> _flutterGetRoomInfo({
    required int roomId,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final response = await Request().get(
        Api.liveRoomInfoH5,
        queryParameters: {
          'room_id': roomId,
        },
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        return Success(RoomInfoH5Data.fromJson(response.data['data']));
      } else {
        return Error(response.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and return error
      if (kDebugMode) {
        debugPrint('Flutter live room info API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Flutter/Dart implementation of live playback URL retrieval.
  ///
  /// Uses the existing [Request] singleton to make HTTP requests
  /// via the Dio client to Bilibili's web API.
  ///
  /// **Implementation Details:**
  /// - Makes GET request to [Api.liveRoomInfo] with the room ID and quality
  /// - Handles response parsing and error cases
  /// - Returns a [LoadingState<RoomPlayInfoData>] with the same structure as the web API
  ///
  /// **Advantages:**
  /// - Stable, production-tested code
  /// - Full feature parity with existing implementation
  /// - No additional dependencies
  ///
  /// **Disadvantages:**
  /// - Potentially slower than Rust implementation
  /// - Higher memory usage for JSON parsing
  static Future<LoadingState<RoomPlayInfoData>> _flutterGetPlayUrl({
    required int roomId,
    required int quality,
  }) async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final response = await Request().get(
        Api.liveRoomInfo,
        queryParameters: {
          'room_id': roomId,
          'qn': quality,
        },
      );

      stopwatch.stop();

      if (response.data['code'] == 0) {
        return Success(RoomPlayInfoData.fromJson(response.data['data']));
      } else {
        return Error(response.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and return error
      if (kDebugMode) {
        debugPrint('Flutter live play URL API failed: $e');
      }
      return Error(e.toString());
    }
  }

  /// Rust implementation of live room info retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [getLiveRoomInfo] from `package:PiliPlus/src/rust/api/live.dart`
  /// - Converts Rust [LiveRoomInfo] model to Flutter [RoomInfoH5Data] via [LiveAdapter]
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
  static Future<LoadingState<RoomInfoH5Data>> _rustGetRoomInfo({
    required int roomId,
  }) async {
    try {
      // Call Rust bridge API
      // Note: PlatformInt64 is the internal representation, but in Dart it's just int
      final rustRoomInfo = await getLiveRoomInfo(roomId: roomId);

      // Convert Rust model to Flutter model
      final roomInfo = LiveAdapter.fromRustRoomInfo(rustRoomInfo);

      // Return success
      return Success(roomInfo);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust live room info API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  /// Rust implementation of live playback URL retrieval.
  ///
  /// Uses the Rust FFI bridge to call native Rust code for API requests.
  ///
  /// **Implementation Details:**
  /// - Calls [getLivePlayUrl] from `package:PiliPlus/src/rust/api/live.dart`
  /// - Converts Rust [LivePlayUrl] model to Flutter [RoomPlayInfoData] via [LiveAdapter]
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
  static Future<LoadingState<RoomPlayInfoData>> _rustGetPlayUrl({
    required int roomId,
    required int quality,
  }) async {
    try {
      // Call Rust bridge API
      final rustPlayUrl = await getLivePlayUrl(
        roomId: roomId,
        quality: quality,
      );

      // Convert Rust model to Flutter model
      final playUrl = LiveAdapter.fromRustPlayUrl(roomId, rustPlayUrl);

      // Return success
      return Success(playUrl);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust live play URL API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
