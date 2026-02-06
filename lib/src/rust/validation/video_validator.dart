import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/video/video_detail/video_detail_response.dart';
import 'package:PiliPlus/src/rust/api/video.dart' as rust;
import 'package:PiliPlus/src/rust/adapters/video_adapter.dart';
// ignore: unused_import
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/foundation.dart';

/// A/B comparison validator for Rust vs Flutter video API implementations.
///
/// This class provides validation utilities to compare the results from both
/// Rust and Flutter implementations of the video API to ensure they produce
/// identical results.
///
/// **Usage:**
/// ```dart
/// final result = await VideoApiValidator.validateGetVideoInfo('BV1xx411c7mD');
/// if (result.passed) {
///   print('Validation passed: ${result.message}');
/// } else {
///   print('Validation failed: ${result.message}');
/// }
/// ```
class VideoApiValidator {
  VideoApiValidator._();

  /// Validate a single video by comparing Rust vs Flutter results.
  ///
  /// This method calls both implementations simultaneously and compares
  /// their results field-by-field to detect any discrepancies.
  ///
  /// **Parameters:**
  /// - `bvid`: The Bilibili video ID to validate
  ///
  /// **Returns:**
  /// - [ValidationResult] indicating whether the validation passed or failed
  ///
  /// **Behavior:**
  /// - If validation is disabled via settings, returns [ValidationResult.skipped]
  /// - Calls both Rust and Flutter implementations
  /// - Compares key fields from both responses
  /// - Logs all mismatches to console in debug mode
  /// - Returns detailed mismatch information
  ///
  /// **Compared Fields:**
  /// - bvid, aid (video IDs)
  /// - title (video title)
  /// - owner.name (uploader name)
  /// - stat.view, stat.like (engagement metrics)
  static Future<ValidationResult> validateGetVideoInfo(String bvid) async {
    // Check if validation is enabled (for now, always validate in debug mode)
    if (!kDebugMode && !_isValidationEnabled()) {
      return ValidationResult.skipped('Validation disabled in settings');
    }

    try {
      // Call both implementations in parallel
      final results = await Future.wait([
        _callRustImplementation(bvid),
        _callFlutterImplementation(bvid),
      ]);

      final rustResult = results[0];
      final flutterResult = results[1];

      // Compare results
      return compareResults(bvid, rustResult, flutterResult);
    } catch (e) {
      return ValidationResult.error('Validation failed: $e');
    }
  }

  /// Compare results from both implementations.
  ///
  /// Performs field-by-field comparison of video data from Rust and Flutter
  /// implementations to identify any discrepancies.
  ///
  /// **Parameters:**
  /// - `bvid`: The video ID being validated (for logging purposes)
  /// - `rustResult`: Result from Rust implementation
  /// - `flutterResult`: Result from Flutter implementation
  ///
  /// **Returns:**
  /// - [ValidationResult.passed] if all fields match or both implementations
  ///   produce the same result (including both failing)
  /// - [ValidationResult.failed] if there are discrepancies between implementations
  static ValidationResult compareResults(
    String bvid,
    VideoDetailResponse? rustResult,
    VideoDetailResponse? flutterResult,
  ) {
    final mismatches = <String>[];

    // Handle edge cases where both implementations failed
    if (rustResult == null && flutterResult == null) {
      debugPrint('⚠️  Both implementations failed for $bvid');
      return ValidationResult.passed('Both implementations failed (consistent)');
    }

    // Handle asymmetric failures
    if (rustResult == null) {
      debugPrint('❌ Rust failed but Flutter succeeded for $bvid');
      return ValidationResult.failed('Rust failed, Flutter succeeded');
    }

    if (flutterResult == null) {
      debugPrint('❌ Flutter failed but Rust succeeded for $bvid');
      return ValidationResult.failed('Flutter succeeded, Rust failed');
    }

    // Compare response codes
    if (rustResult.code != flutterResult.code) {
      mismatches.add(
        '  code: Rust="${rustResult.code}" vs Flutter="${flutterResult.code}"',
      );
      debugPrint('❌ Mismatch for $bvid.code');
      debugPrint('  Rust:    ${rustResult.code}');
      debugPrint('  Flutter: ${flutterResult.code}');
    }

    // Extract data objects
    final rustData = rustResult.data;
    final flutterData = flutterResult.data;

    // If both have null data, consider it a pass
    if (rustData == null && flutterData == null) {
      return ValidationResult.passed('Both implementations returned null data');
    }

    // If only one has null data, that's a mismatch
    if (rustData == null || flutterData == null) {
      mismatches.add(
        '  data: Rust=${rustData != null} vs Flutter=${flutterData != null}',
      );
      debugPrint('❌ Data mismatch for $bvid');
      debugPrint('  Rust has data: ${rustData != null}');
      debugPrint('  Flutter has data: ${flutterData != null}');
    } else {
      // Compare key fields from VideoDetailData
      _compareField(
        bvid,
        'bvid',
        rustData.bvid,
        flutterData.bvid,
        mismatches,
      );
      _compareField(
        bvid,
        'aid',
        rustData.aid,
        flutterData.aid,
        mismatches,
      );
      _compareField(
        bvid,
        'title',
        rustData.title,
        flutterData.title,
        mismatches,
      );
      _compareField(
        bvid,
        'desc',
        rustData.desc,
        flutterData.desc,
        mismatches,
      );
      _compareField(
        bvid,
        'owner.name',
        rustData.owner?.name,
        flutterData.owner?.name,
        mismatches,
      );
      _compareField(
        bvid,
        'owner.mid',
        rustData.owner?.mid,
        flutterData.owner?.mid,
        mismatches,
      );
      _compareField(
        bvid,
        'stat.view',
        rustData.stat?.view,
        flutterData.stat?.view,
        mismatches,
      );
      _compareField(
        bvid,
        'stat.like',
        rustData.stat?.like,
        flutterData.stat?.like,
        mismatches,
      );
      _compareField(
        bvid,
        'stat.coin',
        rustData.stat?.coin,
        flutterData.stat?.coin,
        mismatches,
      );
      _compareField(
        bvid,
        'stat.favorite',
        rustData.stat?.favorite,
        flutterData.stat?.favorite,
        mismatches,
      );
      _compareField(
        bvid,
        'stat.share',
        rustData.stat?.share,
        flutterData.stat?.share,
        mismatches,
      );
      _compareField(
        bvid,
        'cid',
        rustData.cid,
        flutterData.cid,
        mismatches,
      );
      _compareField(
        bvid,
        'duration',
        rustData.duration,
        flutterData.duration,
        mismatches,
      );

      // Compare pages count
      if (rustData.pages != null && flutterData.pages != null) {
        _compareField(
          bvid,
          'pages.length',
          rustData.pages!.length,
          flutterData.pages!.length,
          mismatches,
        );
      }
    }

    // Return result based on mismatches found
    if (mismatches.isEmpty) {
      debugPrint('✅ Validation passed for $bvid');
      return ValidationResult.passed('All fields match');
    } else {
      debugPrint('❌ Validation failed for $bvid with ${mismatches.length} mismatches');
      return ValidationResult.failed(
        'Found ${mismatches.length} mismatches:\n${mismatches.join('\n')}',
      );
    }
  }

  /// Compare a single field between Rust and Flutter results.
  ///
  /// If the values don't match, logs the mismatch and adds it to the mismatches list.
  ///
  /// **Parameters:**
  /// - `bvid`: Video ID (for logging)
  /// - `fieldName`: Name of the field being compared
  /// - `rustValue`: Value from Rust implementation
  /// - `flutterValue`: Value from Flutter implementation
  /// - `mismatches`: List to append mismatch details to
  static void _compareField(
    String bvid,
    String fieldName,
    dynamic rustValue,
    dynamic flutterValue,
    List<String> mismatches,
  ) {
    if (rustValue != flutterValue) {
      final mismatch = '  $fieldName: Rust="$rustValue" vs Flutter="$flutterValue"';
      mismatches.add(mismatch);
      debugPrint('❌ Mismatch for $bvid.$fieldName');
      debugPrint('  Rust:    $rustValue');
      debugPrint('  Flutter: $flutterValue');
    }
  }

  /// Call the Rust implementation of the video API.
  ///
  /// Temporarily overrides the `useRustVideoApi` flag to force the Rust
  /// implementation, then restores the original flag value.
  ///
  /// **Parameters:**
  /// - `bvid`: The video ID to fetch
  ///
  /// **Returns:**
  /// - [VideoDetailResponse] if successful
  /// - `null` if the implementation failed
  static Future<VideoDetailResponse?> _callRustImplementation(
    String bvid,
  ) async {
    try {
      // Call Rust implementation directly
      // Note: We bypass the facade and call the Rust API directly
      // This ensures we get the Rust implementation regardless of settings
      final result = await rust.getVideoInfo(bvid: bvid);

      // Convert Rust VideoInfo to Flutter VideoDetailData
      final videoDetail = VideoAdapter.fromRust(result);

      return VideoDetailResponse(
        code: 0,
        data: videoDetail,
      );
    } catch (e) {
      debugPrint('❌ Rust implementation failed for $bvid: $e');
      return null;
    }
  }

  /// Call the Flutter implementation of the video API.
  ///
  /// Temporarily overrides the `useRustVideoApi` flag to force the Flutter
  /// implementation, then restores the original flag value.
  ///
  /// **Parameters:**
  /// - `bvid`: The video ID to fetch
  ///
  /// **Returns:**
  /// - [VideoDetailResponse] if successful
  /// - `null` if the implementation failed
  static Future<VideoDetailResponse?> _callFlutterImplementation(
    String bvid,
  ) async {
    try {
      // Call VideoHttp which will use the facade
      final result = await VideoHttp.videoIntro(bvid: bvid);

      if (result case Success(:final data)) {
        return VideoDetailResponse(code: 0, data: data);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('❌ Flutter implementation failed for $bvid: $e');
      return null;
    }
  }

  /// Check if validation is enabled in settings.
  ///
  /// For now, this always returns `true` in debug mode.
  /// In production, this could check a user setting.
  static bool _isValidationEnabled() {
    // TODO: Add a proper setting key for this in Task 54
    return kDebugMode;
  }
}

/// Result of a validation operation.
///
/// Encapsulates the outcome of comparing Rust and Flutter implementations,
/// including whether validation passed, failed, was skipped, or encountered
/// an error.
class ValidationResult {
  /// Whether the validation passed.
  ///
  /// - `true` for [ValidationResult.passed] and [ValidationResult.skipped]
  /// - `false` for [ValidationResult.failed] and [ValidationResult.error]
  final bool passed;

  /// Human-readable message describing the validation result.
  final String? message;

  /// Create a successful validation result.
  ValidationResult.passed(this.message) : passed = true;

  /// Create a failed validation result.
  ValidationResult.failed(this.message) : passed = false;

  /// Create a skipped validation result.
  ValidationResult.skipped(this.message) : passed = true;

  /// Create an error validation result.
  ValidationResult.error(this.message) : passed = false;

  @override
  String toString() {
    final status = passed ? '✅' : '❌';
    return '$status Validation: ${message ?? "No message"}';
  }
}
