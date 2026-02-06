/// Example showing how to use the Rust Video API
///
/// This file demonstrates the integration between Flutter and Rust
/// for video API calls using the flutter_rust_bridge.
///
/// ## Basic Usage
///
/// ```dart
/// import 'package:PiliPlus/src/rust/api/video.dart';
/// import 'package:PiliPlus/src/rust/adapters/video_adapter.dart';
/// import 'package:PiliPlus/utils/storage_pref.dart';
///
/// Future<void> example() async {
///   // Check if Rust API is enabled
///   if (Pref.useRustVideoApi) {
///     // Get video info using Rust API
///     final result = await getVideoInfo(bvid: 'BV1xx411c7mD');
///
///     if (resultisOk) {
///       final video = VideoAdapter.fromRust(result.unwrap());
///       print('Title: ${video.title}');
///       print('Duration: ${video.duration}');
///     } else {
///       // Handle error
///       final error = result.err;
///       print('Error: ${error?.message}');
///     }
///   } else {
///     // Fall back to original Dart API
///     print('Using Dart API');
///   }
/// }
/// ```
///
/// ## Getting Video Playback URL
///
/// ```dart
/// import 'package:PiliPlus/src/rust/api/video.dart';
/// import 'package:PiliPlus/src/rust/models/video.dart';
///
/// Future<void> getPlaybackUrl() async {
///   // Get video URL with specific quality
///   final result = await getVideoUrl(
///     bvid: 'BV1xx411c7mD',
///     cid: 12345678,
///     quality: VideoQuality.q1080P,
///   );
///
///   if (result.isOk) {
///     final url = result.unwrap();
///     print('Video URL: ${url.videoUrl}');
///     print('Audio URL: ${url.audioUrl}');
///   }
/// }
/// ```
///
/// ## Error Handling
///
/// The Rust API returns `Result<T, SerializableError>` which can be
/// handled using the `.isOk` and `.isErr` checkers:
///
/// ```dart
/// final result = await getVideoInfo(bvid: 'BV1xx411c7mD');
///
/// if (result.isOk) {
///   final data = result.unwrap();
///   // Use data
/// } else {
///   final error = result.err;
///   // Handle error
///   print('Error code: ${error?.code}');
///   print('Error message: ${error?.message}');
/// }
/// ```
///
/// ## Feature Flag
///
/// To enable/disable the Rust API, use the feature flag:
///
/// ```dart
/// import 'package:PiliPlus/utils/storage_pref.dart';
///
/// // Enable Rust API
/// await Pref.useRustVideoApi.set(true);
///
/// // Disable Rust API (fallback to Dart)
/// await Pref.useRustVideoApi.set(false);
///
/// // Check current setting
/// if (Pref.useRustVideoApi.isTrue) {
///   // Use Rust API
/// }
/// ```
///
/// ## Integration with Existing Code
///
/// The `VideoAdapter` class provides a compatibility layer between
/// Rust and Dart data models:
///
/// ```dart
/// // Convert Rust VideoInfo to existing VideoItem model
/// final rustVideo = await getVideoInfo(bvid: '...');
/// final videoItem = VideoAdapter.fromRust(rustVideo.unwrap());
///
/// // Now use videoItem just like the original VideoItem
/// final title = videoItem.title;
/// final owner = videoItem.owner;
/// ```
///
/// ## Performance Considerations
///
/// - The Rust API runs in a separate thread via FFI
/// - First call may have slight overhead for initialization
/// - Subsequent calls benefit from Rust's performance
/// - Use the feature flag to toggle between Rust and Dart implementations
/// - Monitor performance metrics to determine optimal setting
///
/// ## Testing
///
/// When writing tests, you can mock the Rust API calls:
///
/// ```dart
/// void main() {
///   group('Video API Tests', () {
///     setUp(() {
///       // Enable Rust API for tests
///       Pref.useRustVideoApi.set(true);
///     });
///
///     test('get video info', () async {
///       final result = await getVideoInfo(bvid: testBvid);
///       expect(result.isOk, true);
///       expect(result.unwrap().title, isNotEmpty);
///     });
///   });
/// }
/// ```
///
/// This file serves as documentation only and is not intended to be imported as a library.

