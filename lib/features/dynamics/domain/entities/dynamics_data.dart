import 'package:PiliPlus/features/dynamics/domain/entities/dynamic_item.dart';

/// Data model for dynamics list response.
class DynamicsDataEntity {
  const DynamicsDataEntity({
    this.items,
    this.hasMore,
    this.offset,
    this.total,
    this.loadNext,
  });

  final List<DynamicItemEntity>? items;
  final bool? hasMore;
  final String? offset;
  final int? total;
  final bool? loadNext;
}
