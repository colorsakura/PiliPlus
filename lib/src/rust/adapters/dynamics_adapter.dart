import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/src/rust/models/video.dart' as rust;

/// Adapter for converting Rust DynamicsList to Flutter DynamicsDataModel.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/dynamics/)
///
/// Key conversions:
/// - `DynamicsItem.id` (Rust) → `idStr` (Flutter)
/// - `DynamicsItem.uid` (Rust) → `modules.moduleAuthor.mid` (Flutter)
/// - `DynamicsItem.username` (Rust) → `modules.moduleAuthor.name` (Flutter)
/// - `DynamicsItem.avatar` (Rust) → `modules.moduleAuthor.avatar` (Flutter)
/// - `DynamicsItem.content` (Rust) → `modules.moduleDynamic.desc.text` (Flutter)
/// - `DynamicsItem.images` (Rust) → `modules.moduleDynamic.desc.richTextNodes` (Flutter)
/// - `DynamicsItem.publishTime` (Rust) → `modules.moduleAuthor.pubTs` (Flutter)
/// - `DynamicsItem.likeCount` (Rust) → `modules.moduleStat.like.count` (Flutter)
/// - `DynamicsItem.replyCount` (Rust) → `modules.moduleStat.comment.count` (Flutter)
/// - `PlatformInt64` (Rust) → int (Flutter)
/// - `BigInt` (Rust) → int (Flutter for counts)
///
/// Note: The Rust DynamicsItem model is a simplified subset of the full Flutter
/// DynamicItemModel. Fields not present in Rust are left null or set to defaults.
class DynamicsAdapter {
  /// Convert Rust DynamicsList to Flutter DynamicsDataModel.
  ///
  /// Provides sensible defaults for fields not present in the Rust model.
  /// Only maps the basic fields available in the Rust implementation.
  static DynamicsDataModel fromRustList(rust.DynamicsList rustList) {
    return DynamicsDataModel.fromJson(
      {
        'has_more': rustList.hasMore,
        'offset': rustList.offset,
        'items': rustList.items.map(_convertItemToJson).toList(),
      },
    );
  }

  /// Convert a single Rust DynamicsItem to Flutter DynamicItemModel.
  ///
  /// This is used for individual dynamic detail retrieval.
  static DynamicItemModel fromRustItem(rust.DynamicsItem rustItem) {
    return DynamicItemModel.fromJson(_convertItemToJson(rustItem));
  }

  /// Convert Rust DynamicsItem to JSON map for Flutter DynamicItemModel.
  ///
  /// Handles nested objects and creates the full module structure expected by Flutter UI.
  static Map<String, dynamic> _convertItemToJson(rust.DynamicsItem rustItem) {
    // Convert images to rich text nodes
    final List<Map<String, dynamic>> richTextNodes = [];

    // Add text node
    richTextNodes.add({
      'text': rustItem.content,
      'type': 'TEXT',
      'orig_text': rustItem.content,
    });

    // Add image nodes
    for (final img in rustItem.images) {
      richTextNodes.add({
        'type': 'IMAGE',
        'pics': [
          {
            'url': img.url,
            'width': img.width,
            'height': img.height,
          },
        ],
      });
    }

    return {
      'id_str': rustItem.id,
      'type': 'DYN_TYPE_WORD', // Default to text type
      'modules': {
        'module_author': {
          'mid': rustItem.uid.toInt().toString(),
          'name': rustItem.username,
          'face': rustItem.avatar.url,
          'pub_ts': rustItem.publishTime.toInt(),
          'pub_time': _formatTimestamp(rustItem.publishTime.toInt()),
          'pub_action': '发布了动态',
        },
        'module_dynamic': {
          'desc': {
            'text': rustItem.content,
            'rich_text_nodes': richTextNodes,
          },
        },
        'module_stat': {
          'like': {
            'count': rustItem.likeCount.toInt(),
          },
          'comment': {
            'count': rustItem.replyCount.toInt(),
          },
        },
      },
    };
  }

  /// Format timestamp to readable string.
  ///
  /// This is a simplified version. In production, you might want to use
  /// a more sophisticated time formatting function.
  static String _formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }
}
