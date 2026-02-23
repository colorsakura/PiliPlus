/// 历史记录标签实体
///
/// 封装历史记录分类标签信息
class HistoryTabEntity {
  /// 标签类型
  final String? type;

  /// 标签名称
  final String? name;

  const HistoryTabEntity({
    this.type,
    this.name,
  });

  /// 从模型创建实体
  factory HistoryTabEntity.fromModel(dynamic model) {
    return HistoryTabEntity(
      type: model.type as String?,
      name: model.name as String?,
    );
  }
}
