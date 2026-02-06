import 'package:PiliPlus/models/search/result.dart';
import 'package:PiliPlus/src/rust/models/search.dart' as rust;

/// Adapter for converting Rust search models to Flutter search models.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/)
///
/// Key conversions:
/// - `owner_name` (Rust) → `author` (Flutter SearchOwner)
/// - `owner_face` (Rust) → `upic` (Flutter SearchOwner)
/// - `duration` (Rust: u32 seconds) → `Duration` (Flutter)
/// - `stat` fields: `view_count` → `play`, etc.
class SearchAdapter {
  /// Convert Rust SearchVideoResult to Flutter SearchVideoData.
  ///
  /// Since SearchVideoData extends SearchNumData, we create it directly
  /// with the list of items and numResults.
  static SearchVideoData fromRustSearchResult(
    rust.SearchVideoResult rustResult,
  ) {
    return SearchVideoData(
      numResults: rustResult.num_results,
      list: rustResult.items.map(fromRustSearchVideoItem).toList(),
    );
  }

  /// Convert Rust SearchVideoItem to Flutter SearchVideoItemModel.
  ///
  /// Provides field mappings and type conversions:
  /// - Maps owner fields (name → author, face → upic)
  /// - Converts duration from seconds to Duration
  /// - Maps stat fields (view_count → play, etc.)
  /// - Uses fromJson constructor for proper initialization
  static SearchVideoItemModel fromRustSearchVideoItem(
    rust.SearchVideoItem rustItem,
  ) {
    // Create a JSON map that SearchVideoItemModel.fromJson can parse
    final json = <String, dynamic>{
      'type': rustItem.type,
      'id': null, // Not in Rust model
      'arcurl': null, // Not in Rust model
      'aid': rustItem.aid.toInt(),
      'bvid': rustItem.bvid,
      'title': rustItem.title,
      'description': rustItem.description,
      'pic': rustItem.cover,
      'pubdate': rustItem.pubdate,
      'senddate': rustItem.ctime,
      'duration': rustItem.duration, // in seconds
      'mid': rustItem.owner.mid.toInt(),
      'author': rustItem.owner.name,
      'upic': rustItem.owner.face,
      'play': rustItem.stat.view.toInt(),
      'danmaku': rustItem.stat.danmaku.toInt(),
      'like': rustItem.stat.like.toInt(),
      'is_union_video': rustItem.isUnionVideo == 1,
      // Optional fields not in Rust model
      'favorite': null,
      'review': null,
      'tag': rustItem.tag,
    };

    return SearchVideoItemModel.fromJson(json);
  }
}
