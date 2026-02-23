import 'package:PiliPlus/features/later/domain/entities/later_item.dart';

/// 稍后再看结果实体
class LaterResultEntity {
  /// 稍后再看列表
  final List<LaterItemEntity> items;

  /// 总数量
  final int totalCount;

  const LaterResultEntity({
    required this.items,
    required this.totalCount,
  });

  /// 空结果
  factory LaterResultEntity.empty() {
    return const LaterResultEntity(
      items: [],
      totalCount: 0,
    );
  }
}
