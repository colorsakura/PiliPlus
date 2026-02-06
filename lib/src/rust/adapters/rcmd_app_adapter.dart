import 'package:PiliPlus/models/home/rcmd/result.dart';
import 'package:PiliPlus/src/rust/models/rcmd.dart';

/// Adapter for converting Rust RcmdVideoInfo to Flutter RecVideoItemAppModel.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/home/rcmd/result.dart)
///
/// Key conversions for APP API:
/// - `id` (Rust) → `aid` (Flutter)
/// - `pic` (Rust) → `cover` (Flutter)
/// - `RcmdStat` (Rust) → `RcmdStat` (Flutter, but different field sources)
/// - `RcmdOwner` (Rust) → `RcmdOwner` (Flutter)
/// - App-specific fields: `args`, `player_args` mapping
class RcmdAppAdapter {
  /// Convert Rust RcmdVideoInfo to Flutter RecVideoItemAppModel.
  ///
  /// Handles all field mappings and provides sensible defaults for:
  /// - `player_args`: Constructed from Rust fields
  /// - `args.up_name`/`up_id`: Mapped from owner
  /// - `cover_left_text_1/2`: Mapped from stat
  /// - App-specific fields: Set to reasonable defaults
  static RecVideoItemAppModel fromRust(RcmdVideoInfo rustVideo) {
    // Create a JSON map that matches the RecVideoItemAppModel.fromJson structure
    final json = {
      'player_args': {
        'aid': rustVideo.id?.toInt(),
        'cid': rustVideo.cid?.toInt(),
        'duration': rustVideo.duration,
      },
      'bvid': rustVideo.bvid,
      'cover': rustVideo.pic,
      'title': rustVideo.title,
      'rcmd_reason': rustVideo.rcmdReason,
      'goto': rustVideo.goto ?? 'av',
      'param': rustVideo.id?.toString() ?? '0',
      'uri': rustVideo.uri,
      // Stat fields (cover_left_text for view/danmaku)
      'cover_left_text_1': rustVideo.stat.view?.toString() ?? '',
      'cover_left_text_2': rustVideo.stat.danmaku?.toString() ?? '',
      // Owner fields in args
      'args': {
        'up_name': rustVideo.owner.name,
        'up_id': rustVideo.owner.mid.toInt(),
      },
      'desc': '', // App API doesn't return desc in Rust model
    };

    return RecVideoItemAppModel.fromJson(json);
  }

  /// Convert a list of Rust RcmdVideoInfo to Flutter RecVideoItemAppModel list.
  ///
  /// **Parameters:**
  /// - `rustVideos`: List of RcmdVideoInfo from Rust API
  ///
  /// **Returns:**
  /// - List of RecVideoItemAppModel for Flutter UI
  static List<RecVideoItemAppModel> fromRustList(
    List<RcmdVideoInfo> rustVideos,
  ) {
    return rustVideos.map(fromRust).toList();
  }
}
