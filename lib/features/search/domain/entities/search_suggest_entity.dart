/// 搜索建议实体
///
/// 包含搜索建议关键词
class SearchSuggestEntity {
  /// 建议关键词
  final String? term;

  /// 富文本显示名称
  final String textRich;

  const SearchSuggestEntity({
    this.term,
    required this.textRich,
  });

  SearchSuggestEntity copyWith({
    String? term,
    String? textRich,
  }) {
    return SearchSuggestEntity(
      term: term ?? this.term,
      textRich: textRich ?? this.textRich,
    );
  }
}
