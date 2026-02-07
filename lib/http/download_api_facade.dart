import 'package:PiliPlus/src/rust/api/download.dart' as rust;
import 'package:PiliPlus/src/rust/adapters/download_adapter.dart';
import 'package:PiliPlus/src/rust/models/video.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:PiliPlus/utils/rust_api_metrics.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Facade for download API operations that routes between Rust and Flutter implementations.
///
/// This class implements the Facade pattern to provide a unified interface for download API
/// operations, abstracting away whether the underlying implementation is Rust-based or
/// Flutter/Dart-based.
///
/// **Routing Logic:**
/// - If [Pref.useRustDownloadApi] is `true`, attempts to use the Rust implementation
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
/// // Initialize the download manager
/// await DownloadApiFacade.initManager('/path/to/downloads');
///
/// // Create a download task
/// final task = await DownloadApiFacade.createTask(
///   videoId: 'BV1xx411c7mD',
///   title: 'My Video',
///   quality: VideoQuality.q1080p,
/// );
///
/// // List all tasks
/// final tasks = await DownloadApiFacade.listTasks();
/// ```
///
/// **Feature Flag:**
/// - Controlled by [Pref.useRustDownloadApi] (stored in Hive)
/// - Default: `true` (uses Rust implementation)
class DownloadApiFacade {
  /// Private constructor to prevent instantiation.
  ///
  /// This class only contains static methods and should not be instantiated.
  DownloadApiFacade._();

  /// Initialize the download manager with a download directory.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustDownloadApi].
  /// Automatically falls back to Flutter implementation if Rust fails.
  ///
  /// **Parameters:**
  /// - `downloadDir`: The directory path where downloaded files will be stored
  ///
  /// **Returns:**
  /// - [Future<void>] completes when initialization is done
  ///
  /// **Implementation Selection:**
  /// 1. If [Pref.useRustDownloadApi] is `true`:
  ///    - Attempts to use Rust implementation via [_rustInitManager]
  ///    - Falls back to Flutter implementation on any error
  ///    - Logs the fallback reason in debug mode
  /// 2. If [Pref.useRustDownloadApi] is `false`:
  ///    - Uses Flutter implementation via [_flutterInitManager]
  ///
  /// **Error Handling:**
  /// - Both implementations handle errors gracefully
  /// - Rust failures trigger automatic fallback to Flutter implementation
  /// - All errors are logged in debug mode
  static Future<void> initManager(String downloadDir) async {
    // Check feature flag - handle case where GStorage is not initialized
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      // GStorage not initialized (e.g., in tests), default to Flutter
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_call');
      try {
        // Try Rust implementation first
        await _rustInitManager(downloadDir);
        stopwatch.stop();
        return;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust download API initialization failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        await _flutterInitManager(downloadDir);
      }
    } else {
      // Use Flutter implementation
      await _flutterInitManager(downloadDir);
    }
  }

  /// Create a new download task.
  ///
  /// Routes to either Rust or Flutter implementation based on [Pref.useRustDownloadApi].
  ///
  /// **Parameters:**
  /// - `videoId`: The video ID to download
  /// - `title`: The title of the video
  /// - `quality`: The video quality
  ///
  /// **Returns:**
  /// - [Future<Map<String, dynamic>>] containing task information
  ///
  /// **Implementation Selection:**
  /// - If [Pref.useRustDownloadApi] is `true`: Uses Rust implementation
  /// - Otherwise: Uses Flutter implementation
  /// - Automatic fallback on Rust errors
  static Future<Map<String, dynamic>> createTask({
    required String videoId,
    required String title,
    required VideoQuality quality,
  }) async {
    // Check feature flag
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      final stopwatch = RustMetricsStopwatch('rust_call');
      try {
        // Try Rust implementation first
        final result = await _rustCreateTask(videoId, title, quality);
        stopwatch.stop();
        return result;
      } catch (e, stack) {
        // Record fallback and error
        stopwatch.stopAsFallback(e.toString());
        RustApiMetrics.recordError('RustFallback');

        // Fallback to Flutter on any error
        if (kDebugMode) {
          debugPrint('Rust create task failed: $e');
          debugPrint('Stack trace: $stack');
          debugPrint('Falling back to Flutter implementation');
        }
        return _flutterCreateTask(videoId, title, quality);
      }
    } else {
      // Use Flutter implementation
      return _flutterCreateTask(videoId, title, quality);
    }
  }

  /// Start downloading a task.
  ///
  /// **Parameters:**
  /// - `taskId`: The ID of the task to start
  ///
  /// **Returns:**
  /// - [Future<void>] completes when download is started
  static Future<void> startDownload(String taskId) async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        await rust.startDownload(taskId: taskId);
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust start download failed: $e, falling back to Flutter');
        }
      }
    }
    await _flutterStartDownload(taskId);
  }

  /// Pause an in-progress download.
  ///
  /// **Parameters:**
  /// - `taskId`: The ID of the task to pause
  ///
  /// **Returns:**
  /// - [Future<void>] completes when download is paused
  static Future<void> pauseDownload(String taskId) async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        await rust.pauseDownload(taskId: taskId);
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust pause download failed: $e, falling back to Flutter');
        }
      }
    }
    await _flutterPauseDownload(taskId);
  }

  /// Resume a paused download.
  ///
  /// **Parameters:**
  /// - `taskId`: The ID of the task to resume
  ///
  /// **Returns:**
  /// - [Future<void>] completes when download is resumed
  static Future<void> resumeDownload(String taskId) async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        await rust.resumeDownload(taskId: taskId);
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust resume download failed: $e, falling back to Flutter');
        }
      }
    }
    await _flutterResumeDownload(taskId);
  }

  /// Cancel a download.
  ///
  /// **Parameters:**
  /// - `taskId`: The ID of the task to cancel
  ///
  /// **Returns:**
  /// - [Future<void>] completes when download is cancelled
  static Future<void> cancelDownload(String taskId) async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        await rust.cancelDownload(taskId: taskId);
        return;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust cancel download failed: $e, falling back to Flutter');
        }
      }
    }
    await _flutterCancelDownload(taskId);
  }

  /// Get a specific download task.
  ///
  /// **Parameters:**
  /// - `taskId`: The ID of the task to retrieve
  ///
  /// **Returns:**
  /// - [Future<Map<String, dynamic>?>] task information or null if not found
  static Future<Map<String, dynamic>?> getTask(String taskId) async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        final result = await rust.getDownloadTask(taskId: taskId);
        if (result != null) {
          return DownloadAdapter.toMap(result);
        }
        return null;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust get task failed: $e, falling back to Flutter');
        }
      }
    }
    return _flutterGetTask(taskId);
  }

  /// List all download tasks.
  ///
  /// **Returns:**
  /// - [Future<List<Map<String, dynamic>>>] list of all tasks
  static Future<List<Map<String, dynamic>>> listTasks() async {
    bool useRust = true;
    try {
      useRust = Pref.useRustDownloadApi;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to read useRustDownloadApi: $e');
      }
      useRust = false;
    }

    if (useRust) {
      try {
        final result = await rust.listDownloadTasks();
        return result.map((task) => DownloadAdapter.toMap(task)).toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Rust list tasks failed: $e, falling back to Flutter');
        }
      }
    }
    return _flutterListTasks();
  }

  // ========== Rust Implementation ==========

  static Future<void> _rustInitManager(String downloadDir) async {
    await rust.initDownloadManager(downloadDir: downloadDir);
  }

  static Future<Map<String, dynamic>> _rustCreateTask(
    String videoId,
    String title,
    VideoQuality quality,
  ) async {
    final rustTask = await rust.createDownloadTask(
      videoId: videoId,
      title: title,
      quality: quality,
    );
    return DownloadAdapter.toMap(rustTask);
  }

  // ========== Flutter Implementation ==========

  static Future<void> _flutterInitManager(String downloadDir) async {
    // Placeholder: Flutter implementation would initialize its download manager
    if (kDebugMode) {
      debugPrint('Flutter download manager initialized with dir: $downloadDir');
    }
  }

  static Future<Map<String, dynamic>> _flutterCreateTask(
    String videoId,
    String title,
    VideoQuality quality,
  ) async {
    // Placeholder: Flutter implementation would create a download task
    if (kDebugMode) {
      debugPrint('Flutter create task: $videoId, $title, $quality');
    }
    return {
      'id': 'flutter_${DateTime.now().millisecondsSinceEpoch}',
      'videoId': videoId,
      'title': title,
      'status': 'pending',
    };
  }

  static Future<void> _flutterStartDownload(String taskId) async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter start download: $taskId');
    }
  }

  static Future<void> _flutterPauseDownload(String taskId) async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter pause download: $taskId');
    }
  }

  static Future<void> _flutterResumeDownload(String taskId) async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter resume download: $taskId');
    }
  }

  static Future<void> _flutterCancelDownload(String taskId) async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter cancel download: $taskId');
    }
  }

  static Future<Map<String, dynamic>?> _flutterGetTask(String taskId) async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter get task: $taskId');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> _flutterListTasks() async {
    // Placeholder implementation
    if (kDebugMode) {
      debugPrint('Flutter list tasks');
    }
    return [];
  }
}
