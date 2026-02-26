import 'package:PiliPlus/models/common/reply/reply_option_type.dart';
import 'package:PiliPlus/shared/widgets/pair.dart';
import 'package:PiliPlus/models/dynamics/result.dart';

/// Entity representing parameters for creating/reposting a dynamic
class DynamicsRepostParams {
  /// User ID
  final int? mid;

  /// Dynamic ID string (for reposting existing dynamic)
  final String? dynIdStr;

  /// Resource ID (for sharing video to dynamic)
  final int? rid;

  /// Dynamic type
  final int? dynType;

  /// Raw text content
  final String? rawText;

  /// List of picture URLs
  final List<String>? pics;

  /// Scheduled publish time
  final int? publishTime;

  /// Reply option setting
  final ReplyOptionType? replyOption;

  /// Private publish setting
  final int? privatePub;

  /// Extra content (rich text nodes, mentions, emojis)
  final List<Map<String, dynamic>>? extraContent;

  /// Topic ID and name pair
  final Pair<int, String>? topic;

  /// Title for the dynamic
  final String? title;

  /// Attach card data
  final Map? attachCard;

  /// Original dynamic item (for repost context)
  final DynamicItemModel? item;

  const DynamicsRepostParams({
    this.mid,
    this.dynIdStr,
    this.rid,
    this.dynType,
    this.rawText,
    this.pics,
    this.publishTime,
    this.replyOption,
    this.privatePub,
    this.extraContent,
    this.topic,
    this.title,
    this.attachCard,
    this.item,
  });

  /// Check if this is a repost operation (vs sharing video)
  bool get isRepost => item != null || dynIdStr != null;

  /// Check if this is a video share operation
  bool get isVideoShare => rid != null && dynType != null;

  DynamicsRepostParams copyWith({
    int? mid,
    String? dynIdStr,
    int? rid,
    int? dynType,
    String? rawText,
    List<String>? pics,
    int? publishTime,
    ReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
    DynamicItemModel? item,
  }) {
    return DynamicsRepostParams(
      mid: mid ?? this.mid,
      dynIdStr: dynIdStr ?? this.dynIdStr,
      rid: rid ?? this.rid,
      dynType: dynType ?? this.dynType,
      rawText: rawText ?? this.rawText,
      pics: pics ?? this.pics,
      publishTime: publishTime ?? this.publishTime,
      replyOption: replyOption ?? this.replyOption,
      privatePub: privatePub ?? this.privatePub,
      extraContent: extraContent ?? this.extraContent,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      attachCard: attachCard ?? this.attachCard,
      item: item ?? this.item,
    );
  }
}
