import 'package:PiliPlus/models/sponsor_block/segment_item.dart';

/// Sponsor segment entity
class SponsorSegmentEntity {
  final String uuid;
  final double startTime;
  final double endTime;
  final String category;
  final String? actionType;

  SponsorSegmentEntity({
    required this.uuid,
    required this.startTime,
    required this.endTime,
    required this.category,
    this.actionType,
  });

  /// Create from SegmentItemModel
  factory SponsorSegmentEntity.fromModel(SegmentItemModel model) {
    return SponsorSegmentEntity(
      uuid: model.uuid,
      startTime: model.segment[0].toDouble(),
      endTime: model.segment[1].toDouble(),
      category: model.category,
      actionType: model.actionType,
    );
  }

  /// Convert to SegmentItemModel
  SegmentItemModel toModel() {
    return SegmentItemModel(
      uuid: uuid,
      segment: [startTime.toInt(), endTime.toInt()],
      category: category,
      actionType: actionType,
    );
  }

  /// Duration of the segment
  double get duration => endTime - startTime;

  @override
  String toString() =>
      'SponsorSegmentEntity(uuid: $uuid, startTime: $startTime, endTime: $endTime, category: $category)';
}
