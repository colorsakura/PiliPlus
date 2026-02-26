import 'package:PiliPlus/models/common/reply/reply_option_type.dart';
import 'package:PiliPlus/models/dynamic/dyn_reserve_info/data.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';
import 'package:PiliPlus/shared/widgets/pair.dart';

/// Parameters for creating a new dynamic
class CreateDynamicParams {
  final int mid;
  final String? rawText;
  final List? pictures;
  final int? publishTime; // Unix timestamp for scheduled publish
  final ReplyOptionType replyOption;
  final bool isPrivate;
  final String? title;
  final Pair<int, String>? topic;
  final List? extraContent;
  final ReserveInfoData? reserveCard;

  const CreateDynamicParams({
    required this.mid,
    this.rawText,
    this.pictures,
    this.publishTime,
    this.replyOption = ReplyOptionType.allow,
    this.isPrivate = false,
    this.title,
    this.topic,
    this.extraContent,
    this.reserveCard,
  });

  /// Build attach card from reserve card
  Map<String, dynamic>? get attachCard {
    if (reserveCard == null) return null;
    return {
      "common_card": {
        "type": 14,
        "biz_id": reserveCard!.id,
        "reserve_source": 0,
        "reserve_lottery": 0,
      },
    };
  }

  /// Get private pub value (1 if private, null otherwise)
  int? get privatePub => isPrivate ? 1 : null;
}

/// Parameters for editing an existing dynamic
class EditDynamicParams {
  final Object dynId;
  final Object? repostDynId;
  final String? rawText;
  final List? pictures;
  final ReplyOptionType replyOption;
  final bool isPrivate;
  final String? title;
  final Pair<int, String>? topic;
  final List? extraContent;

  const EditDynamicParams({
    required this.dynId,
    this.repostDynId,
    this.rawText,
    this.pictures,
    this.replyOption = ReplyOptionType.allow,
    this.isPrivate = false,
    this.title,
    this.topic,
    this.extraContent,
  });

  /// Get private pub value (1 if private, null otherwise)
  int? get privatePub => isPrivate ? 1 : null;
}
