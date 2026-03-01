/// 联系人页面配置
///
/// 定义联系人页面的行为模式
class ContactConfig {
  /// 是否为选择模式
  final bool isFromSelect;

  /// 用户ID
  final int userId;

  const ContactConfig({
    this.isFromSelect = true,
    required this.userId,
  });

  /// 复制并修改部分属性
  ContactConfig copyWith({
    bool? isFromSelect,
    int? userId,
  }) {
    return ContactConfig(
      isFromSelect: isFromSelect ?? this.isFromSelect,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactConfig &&
        other.isFromSelect == isFromSelect &&
        other.userId == userId;
  }

  @override
  int get hashCode {
    return isFromSelect.hashCode ^ userId.hashCode;
  }
}
