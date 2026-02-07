import 'package:PiliPlus/src/rust/models/download.dart' as rust;
import 'package:PiliPlus/src/rust/models/video.dart';

/// Adapter for converting Rust download models to Flutter download models.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/download/)
///
/// Key conversions:
/// - `DownloadStatusData` (Rust) → app-specific download status
/// - `BigInt`/`PlatformInt64` (Rust) → int (Flutter)
/// - Timestamps → DateTime objects
class DownloadAdapter {
  /// Convert Rust DownloadTaskData to app-compatible format.
  ///
  /// Since the existing download system uses complex models with many fields,
  /// this adapter extracts the essential information that can be used
  /// throughout the app.
  ///
  /// Returns a map with task properties that can be used to update
  /// existing download models or create new ones.
  static Map<String, dynamic> toMap(rust.DownloadTaskData rustTask) {
    return {
      'id': rustTask.id,
      'videoId': rustTask.videoId,
      'title': rustTask.title,
      'totalBytes': rustTask.totalBytes.toInt(),
      'downloadedBytes': rustTask.downloadedBytes.toInt(),
      'filePath': rustTask.filePath,
      'canResume': rustTask.canResume,
      'createdAt': rustTask.createdAt.toInt(),
      'completedAt': rustTask.completedAt?.toInt(),
      'status': _convertStatus(rustTask.status),
      'quality': _convertQuality(rustTask.quality),
    };
  }

  /// Convert Rust DownloadStatusData to app status enum.
  static String _convertStatus(rust.DownloadStatusData status) {
    return status.when(
      pending: () => 'pending',
      downloading: (speed, eta) => 'downloading',
      paused: () => 'paused',
      completed: () => 'completed',
      failed: (error) => 'failed',
      cancelled: () => 'cancelled',
    );
  }

  /// Convert Rust VideoQuality to quality ID.
  static int _convertQuality(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.low:
        return 16; // 360p
      case VideoQuality.medium:
        return 64; // 720p
      case VideoQuality.high:
        return 80; // 1080p
      case VideoQuality.ultra:
        return 112; // 1080p+
      case VideoQuality.fourK:
        return 120; // 4K
    }
  }

  /// Extract speed from DownloadStatusData if downloading.
  static double? extractSpeed(rust.DownloadStatusData status) {
    return status.when(
      pending: () => null,
      downloading: (speed, eta) => speed,
      paused: () => null,
      completed: () => null,
      failed: (error) => null,
      cancelled: () => null,
    );
  }

  /// Extract ETA from DownloadStatusData if downloading.
  static double? extractEta(rust.DownloadStatusData status) {
    return status.when(
      pending: () => null,
      downloading: (speed, eta) => eta,
      paused: () => null,
      completed: () => null,
      failed: (error) => null,
      cancelled: () => null,
    );
  }

  /// Extract error message from DownloadStatusData if failed.
  static String? extractError(rust.DownloadStatusData status) {
    return status.when(
      pending: () => null,
      downloading: (speed, eta) => null,
      paused: () => null,
      completed: () => null,
      failed: (error) => error,
      cancelled: () => null,
    );
  }
}
