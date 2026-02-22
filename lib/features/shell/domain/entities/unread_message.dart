/// 未读消息实体
class UnreadMessage {
  /// 总未读数
  final int count;

  /// 显示文本（空字符串、数字或 '99+'）
  final String displayText;

  const UnreadMessage({
    required this.count,
    required this.displayText,
  });

  /// 创建零未读状态
  const UnreadMessage.zero()
      : count = 0,
        displayText = '';

  /// 从数量创建实体
  factory UnreadMessage.fromCount(int count) {
    final displayText = count == 0
        ? ''
        : count > 99
            ? '99+'
            : count.toString();
    return UnreadMessage(
      count: count,
      displayText: displayText,
    );
  }

  /// 是否有未读
  bool get hasUnread => count > 0;

  UnreadMessage copyWith({
    int? count,
    String? displayText,
  }) {
    return UnreadMessage(
      count: count ?? this.count,
      displayText: displayText ?? this.displayText,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnreadMessage &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          displayText == other.displayText;

  @override
  int get hashCode => count.hashCode ^ displayText.hashCode;
}
