/// 未读动态实体
class UnreadDynamic {
  /// 未读数量
  final int count;

  const UnreadDynamic({required this.count});

  /// 创建零未读状态
  const UnreadDynamic.zero() : count = 0;

  /// 是否有未读
  bool get hasUnread => count > 0;

  UnreadDynamic copyWith({int? count}) {
    return UnreadDynamic(count: count ?? this.count);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnreadDynamic &&
          runtimeType == other.runtimeType &&
          count == other.count;

  @override
  int get hashCode => count.hashCode;
}
