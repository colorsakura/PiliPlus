import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_item.dart';

/// 黑名单列表结果实体
///
/// 封装黑名单API返回结果
class BlacklistResultEntity {
  /// 黑名单用户列表
  final List<BlacklistItemEntity> items;

  /// 总数
  final int total;

  /// 是否有更多数据
  final bool hasMore;

  /// 当前页码
  final int currentPage;

  const BlacklistResultEntity({
    required this.items,
    required this.total,
    required this.hasMore,
    required this.currentPage,
  });

  /// 空结果
  factory BlacklistResultEntity.empty() {
    return const BlacklistResultEntity(
      items: [],
      total: 0,
      hasMore: false,
      currentPage: 1,
    );
  }
}
