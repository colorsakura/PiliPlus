import 'package:PiliPlus/models/model_rec_video_item.dart';
import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/model_video.dart';
import 'package:PiliPlus/src/rust/models/rcmd.dart';

/// Adapter for converting Rust RcmdVideoInfo to Flutter RecVideoItemModel.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/)
///
/// Key conversions:
/// - `id` (Rust) → `aid` (Flutter)
/// - `pic` (Rust) → `cover` (Flutter)
/// - `RcmdStat` (Rust) → `Stat` (Flutter)
/// - `RcmdOwner` (Rust) → `Owner` (Flutter)
/// - `PlatformInt64` (Rust) → int (Flutter)
/// - `Option<T>` (Rust) → nullable type (Flutter)
class RcmdAdapter {
  /// Convert Rust RcmdVideoInfo to Flutter RecVideoItemModel.
  ///
  /// Handles all field mappings and provides sensible defaults for:
  /// - `desc`: Set to empty string
  /// - All other optional fields: Use Flutter model's defaults
  static RecVideoItemModel fromRust(RcmdVideoInfo rustVideo) {
    // Create a JSON map that matches the RecVideoItemModel.fromJson structure
    final json = {
      'id': rustVideo.id?.toInt(),
      'bvid': rustVideo.bvid,
      'cid': rustVideo.cid?.toInt(),
      'goto': rustVideo.goto,
      'uri': rustVideo.uri,
      'pic': rustVideo.pic,
      'title': rustVideo.title,
      'duration': rustVideo.duration,
      'pubdate': rustVideo.pubdate?.toInt(),
      'owner': {
        'mid': rustVideo.owner.mid.toInt(),
        'name': rustVideo.owner.name,
        'face': rustVideo.owner.face,
      },
      'stat': {
        'view': rustVideo.stat.view?.toInt(),
        'like': rustVideo.stat.like?.toInt(),
        'danmaku': rustVideo.stat.danmaku?.toInt(),
      },
      'is_followed': rustVideo.isFollowed ? 1 : 0,
      'rcmd_reason': rustVideo.rcmdReason != null ? {'content': rustVideo.rcmdReason} : null,
    };

    return RecVideoItemModel.fromJson(json);
  }

  /// Convert a list of Rust RcmdVideoInfo to Flutter RecVideoItemModel.
  static List<RecVideoItemModel> fromRustList(List<RcmdVideoInfo> rustVideos) {
    return rustVideos.map(fromRust).toList();
  }
}