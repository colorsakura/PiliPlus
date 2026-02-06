// ignore_for_file: unused_import

import 'package:PiliPlus/src/rust/validation/video_validator.dart';

/// Example usage of the VideoApiValidator.
///
/// This file demonstrates how to use the A/B comparison validator
/// to compare Rust and Flutter video API implementations.
///
/// **Usage Examples:**
///
/// 1. **Basic validation:**
/// ```dart
/// final result = await VideoApiValidator.validateGetVideoInfo('BV1xx411c7mD');
/// if (result.passed) {
///   print('✅ Validation passed: ${result.message}');
/// } else {
///   print('❌ Validation failed: ${result.message}');
/// }
/// ```
///
/// 2. **Validating multiple videos:**
/// ```dart
/// final testBvids = [
///   'BV1xx411c7mD',
///   'BV1yy411c7mE',
///   'BV1zz411c7mF',
/// ];
///
/// for (final bvid in testBvids) {
///   final result = await VideoApiValidator.validateGetVideoInfo(bvid);
///   print('$bvid: $result');
/// }
/// ```
///
/// 3. **Comparing results manually:**
/// ```dart
/// // Get results from both implementations
/// final rustResult = await VideoApiValidator._callRustImplementation(bvid);
/// final flutterResult = await VideoApiValidator._callFlutterImplementation(bvid);
///
/// // Compare them
/// final comparison = VideoApiValidator.compareResults(
///   bvid,
///   rustResult,
///   flutterResult,
/// );
///
/// print(comparison);
/// ```
///
/// **Output Format:**
///
/// The validator will output detailed information to the console:
///
/// - ✅ When validation passes: `✅ Validation passed for BV1xx411c7mD`
/// - ❌ When validation fails: `❌ Mismatch for BV1xx411c7mD.title`
/// - ⚠️  When both implementations fail: `⚠️  Both implementations failed for BV1xx411c7mD`
///
/// **Validation Results:**
///
/// The [ValidationResult] object contains:
/// - `passed`: Boolean indicating if validation passed
/// - `message`: Detailed message about the result
///
/// **Compared Fields:**
///
/// The validator compares the following fields:
/// - Video IDs (bvid, aid)
/// - Metadata (title, desc, duration)
/// - Owner info (name, mid)
/// - Statistics (view, like, coin, favorite, share)
/// - Pages count
///
/// **Debug Mode:**
///
/// In debug mode, the validator will:
/// - Log all mismatches to console with emoji indicators
/// - Show detailed field-by-field comparisons
/// - Print stack traces for errors
///
/// **Performance Considerations:**
///
/// - Validation calls both implementations in parallel for speed
/// - Network requests are made twice (once per implementation)
/// - Consider caching results to avoid redundant API calls
///
/// **Error Handling:**
///
/// - Network errors are caught and returned as validation failures
/// - JSON parsing errors are caught and logged
/// - Both implementations failing is considered a "pass" (consistent behavior)
///
/// **Integration with Facade:**
///
/// The validator works independently of the [VideoApiFacade] routing logic.
/// It calls both implementations directly to ensure accurate comparison.
///
/// **Future Enhancements:**
///
/// - Performance metrics collection (Task 56)
/// - Batch validation for multiple videos
/// - Statistical analysis of mismatch patterns
/// - Automatic regression testing in CI/CD
