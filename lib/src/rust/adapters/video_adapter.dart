import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/video/video_detail/data.dart';
import 'package:PiliPlus/models/video/video_detail/page.dart';
import 'package:PiliPlus/models/video/video_detail/stat.dart';
import 'package:PiliPlus/src/rust/models/video.dart' as rust;

/// Adapter for converting Rust VideoInfo to Flutter VideoDetailData.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/)
///
/// Key conversions:
/// - `description` (Rust) → `desc` (Flutter)
/// - `part_` (Rust) → `part` (Flutter)
/// - `viewCount` (Rust) → `view` (Flutter)
/// - `collectCount` (Rust) → `favorite` (Flutter)
/// - `Image.url` (Rust) → String (Flutter for pic/face fields)
/// - `PlatformInt64` (Rust) → int (Flutter)
/// - `BigInt` (Rust) → int (Flutter for stat counts)
class VideoAdapter {
  /// Convert Rust VideoInfo to Flutter VideoDetailData.
  ///
  /// Provides sensible defaults for fields not present in the Rust model:
  /// - `videos`: Set to pages.length
  /// - `pubdate`: Set to current timestamp
  /// - All other optional fields: Left null
  static VideoDetailData fromRust(rust.VideoInfo rustVideo) {
    // Create VideoStat from JSON since it only has fromJson constructor
    final stat = VideoStat.fromJson({
      'view': rustVideo.stats.viewCount.toInt(),
      'like': rustVideo.stats.likeCount.toInt(),
      'coin': rustVideo.stats.coinCount.toInt(),
      'favorite': rustVideo.stats.collectCount.toInt(),
    });

    return VideoDetailData(
      bvid: rustVideo.bvid,
      aid: rustVideo.aid.toInt(),
      title: rustVideo.title,
      desc: rustVideo.description,
      owner: Owner(
        mid: rustVideo.owner.mid.toInt(),
        name: rustVideo.owner.name,
        face: rustVideo.owner.face.url,
      ),
      pic: rustVideo.pic.url,
      duration: rustVideo.duration,
      cid: rustVideo.cid.toInt(),
      stat: stat,
      pages: rustVideo.pages
          .map(
            (p) => Part(
              cid: p.cid.toInt(),
              page: p.page,
              part: p.part_,
              duration: p.duration,
            ),
          )
          .toList(),
      // Set default values for fields not in Rust model
      videos: rustVideo.pages.length,
      pubdate: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
  }
}
