import 'package:PiliPlus/features/history/domain/entities/history_item.dart';
import 'package:PiliPlus/features/history/domain/entities/history_tab.dart';

/// 历史记录结果实体
///
/// 封装历史记录API返回结果
class HistoryResultEntity {
  /// 历史记录列表
  final List<HistoryItemEntity> items;

  /// 分类标签
  final List<HistoryTabEntity> tabs;

  /// 是否有更多数据
  final bool hasMore;

  /// 分页最大ID
  final int? maxId;

  /// 分页查看时间
  final int? viewAt;

  const HistoryResultEntity({
    required this.items,
    required this.tabs,
    required this.hasMore,
    this.maxId,
    this.viewAt,
  });

  /// 空结果
  factory HistoryResultEntity.empty() {
    return const HistoryResultEntity(
      items: [],
      tabs: [],
      hasMore: false,
    );
  }
}
