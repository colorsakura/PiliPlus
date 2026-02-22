/// 搜索建议实体
///
/// 包含默认搜索词建议
class SearchSuggestion {
  /// 搜索词
  final String keyword;

  /// 显示名称
  final String showName;

  const SearchSuggestion({
    required this.keyword,
    required this.showName,
  });

  /// 从 JSON 创建
  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      keyword: json['name'] ?? json['keyword'] ?? '',
      showName: json['show_name'] ?? json['name'] ?? '',
    );
  }

  /// 获取主要显示文本
  String get displayText => showName.isNotEmpty ? showName : keyword;

  SearchSuggestion copyWith({
    String? keyword,
    String? showName,
  }) {
    return SearchSuggestion(
      keyword: keyword ?? this.keyword,
      showName: showName ?? this.showName,
    );
  }
}
