// Example usage of the fixed Rust bridge API
// This file demonstrates that the types are now properly accessible in Dart

import 'package:PiliPlus/src/rust/api/video.dart';
import 'package:PiliPlus/src/rust/models/video.dart';

/// Example function showing how to use the video API
Future<void> exampleUsage() async {
  // Get video info - now returns ApiResult<VideoInfo> with accessible fields
  final result = await getVideoInfo(bvid: 'BV1xx411c7mD');

  if (result.success) {
    // Can now access VideoInfo fields directly!
    final info = result.data;
    if (info != null) {
      print('Video title: ${info.title}');
      print('Video BVID: ${info.bvid}');
      print('Video owner: ${info.owner.name}');
      print('View count: ${info.stats.viewCount}');
      print('Duration: ${info.duration} seconds');

      // Access nested fields
      for (final page in info.pages) {
        print('Page ${page.page}: ${page.part_}');
      }
    }
  } else {
    // Error handling
    print('Error: ${result.error}');
  }

  // Get video URL - similar pattern
  final urlResult = await getVideoUrl(
    bvid: 'BV1xx411c7mD',
    cid: result.data?.cid ?? 0,
    quality: VideoQuality.high,
  );

  if (urlResult.success && urlResult.data != null) {
    final urlInfo = urlResult.data!;
    print('Quality: ${urlInfo.quality}');
    print('Format: ${urlInfo.format}');
    print('Segments: ${urlInfo.segments.length}');
  }
}
