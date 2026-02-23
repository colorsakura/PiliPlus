/// 导出数据实体
///
/// 封装导入/导出的数据
class ExportDataEntity {
  /// JSON数据
  final Map<String, dynamic> jsonData;

  /// 数据类型（如：登录信息、设置）
  final String dataType;

  /// 是否包含标签（用于文件名）
  final bool hasLabel;

  const ExportDataEntity({
    required this.jsonData,
    required this.dataType,
    this.hasLabel = false,
  });
}
