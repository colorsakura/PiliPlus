import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/src/rust/api/user.dart' as rust;
import 'package:PiliPlus/src/rust/adapters/user_adapter.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for user API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for user API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustUserApi] is `true`, attempts to use the Rust implementation
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
/// final result = await UserApiFacade.userInfo();
/// if (result is Success<UserInfoData>) {
///   final user = (result as Success<UserInfoData>).data;
/// }
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustUserApi] (stored in Hive)
/// - Default: `false` (uses Flutter implementation)
class UserApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  UserApiFacade._();

  /// Get current user information from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustUserApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Returns:**
  /// - [Future<LoadingState<UserInfoData>>] containing user information or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustUserApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustUserInfo]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustUserApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterUserInfo]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap errors in a [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  static Future<LoadingState<UserInfoData>> userInfo() async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustUserApi;
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
        final result = await _rustUserInfo();
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust user info API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterUserInfo();
      }
    } else {
      // Use Flutter implementation
      return _flutterUserInfo();
    }
  }

  /// Get current user statistics from Bilibili API.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustUserApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Returns:**
  /// - [Future<LoadingState<UserStat>>] containing user statistics or error
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustUserApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustUserStats]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustUserApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterUserStats]
  ///
  /// **Error Handling:**
  /// - Both implementations wrap errors in a [LoadingState]
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  static Future<LoadingState<UserStat>> userStatOwner() async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = false;
    try {
      useRust = Pref.useRustUserApi;
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
        final result = await _rustUserStats();
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust user stats API failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterUserStats();
      }
    } else {
      // Use Flutter implementation
      return _flutterUserStats();
    }
  }

  /// Flutter/Dart implementation of user info retrieval.
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
  static Future<LoadingState<UserInfoData>> _flutterUserInfo() async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final res = await Request().get(Api.userInfo);
      stopwatch.stop();

      if (res.data['code'] == 0) {
        UserInfoData data = UserInfoData.fromJson(res.data['data']);
        return Success(data);
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Flutter user info API failed: $e');
      }
      rethrow;
    }
  }

  /// Flutter/Dart implementation of user stats retrieval.
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
  static Future<LoadingState<UserStat>> _flutterUserStats() async {
    final stopwatch = RustMetricsStopwatch('flutter_call');
    try {
      final res = await Request().get(Api.userStatOwner);
      stopwatch.stop();

      if (res.data['code'] == 0) {
        return Success(UserStat.fromJson(res.data['data']));
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      // Record error
      stopwatch.stopAsError('FlutterError');

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Flutter user stats API failed: $e');
      }
      rethrow;
    }
  }

  /// Rust implementation of user info retrieval.
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
  static Future<LoadingState<UserInfoData>> _rustUserInfo() async {
    try {
      // Call Rust bridge API
      final rustUser = await rust.getUserInfo();

      // Convert Rust model to Flutter model
      final userData = UserAdapter.fromRustUserInfo(rustUser);
      userData.isLogin = true; // API call succeeded, so user is logged in

      // Return Success
      return Success(userData);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust user info API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }

  /// Rust implementation of user stats retrieval.
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
  static Future<LoadingState<UserStat>> _rustUserStats() async {
    try {
      // Call Rust bridge API
      final rustStats = await rust.getUserStats();

      // Convert Rust model to Flutter model
      final userStat = UserAdapter.fromRustUserStats(rustStats);

      // Return Success
      return Success(userStat);
    } catch (e) {
      // Convert Rust errors to string for logging
      final errorMessage = e.toString();

      // Log and rethrow
      if (kDebugMode) {
        debugPrint('Rust user stats API failed: $errorMessage');
      }
      throw Exception(errorMessage);
    }
  }
}
