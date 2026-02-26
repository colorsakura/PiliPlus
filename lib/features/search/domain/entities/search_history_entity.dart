/// 搜索历史实体
///
/// 管理搜索历史记录
class SearchHistoryEntity {
  /// 历史记录列表
  final List<String> historyList;

  /// 是否记录搜索历史
  final bool recordHistory;

  const SearchHistoryEntity({
    this.historyList = const [],
    this.recordHistory = true,
  });

  SearchHistoryEntity copyWith({
    List<String>? historyList,
    bool? recordHistory,
  }) {
    return SearchHistoryEntity(
      historyList: historyList ?? this.historyList,
      recordHistory: recordHistory ?? this.recordHistory,
    );
  }

  /// 添加搜索历史
  SearchHistoryEntity addHistory(String keyword) {
    if (!recordHistory || keyword.isEmpty) {
      return this;
    }
    final newList = List<String>.from(historyList);
    newList.remove(keyword);
    newList.insert(0, keyword);
    return copyWith(historyList: newList);
  }

  /// 删除搜索历史
  SearchHistoryEntity removeHistory(String keyword) {
    final newList = List<String>.from(historyList);
    newList.remove(keyword);
    return copyWith(historyList: newList);
  }

  /// 清空搜索历史
  SearchHistoryEntity clearHistory() {
    return copyWith(historyList: <String>[]);
  }

  /// 是否为空
  bool get isEmpty => historyList.isEmpty;

  /// 是否不为空
  bool get isNotEmpty => historyList.isNotEmpty;
}
