import 'package:PiliPlus/models/common/search/search_type.dart';

/// Search result state entity
class SearchResultStateEntity {
  final String keyword;
  final List<int> counts;
  final int toTopIndex;

  const SearchResultStateEntity({
    required this.keyword,
    required this.counts,
    required this.toTopIndex,
  });

  /// Initial state
  factory SearchResultStateEntity.initial() {
    return SearchResultStateEntity(
      keyword: '',
      counts: List.filled(SearchType.values.length, -1),
      toTopIndex: -1,
    );
  }

  /// Create state with keyword
  factory SearchResultStateEntity.withKeyword(String keyword) {
    return SearchResultStateEntity(
      keyword: keyword,
      counts: List.filled(SearchType.values.length, -1),
      toTopIndex: -1,
    );
  }

  SearchResultStateEntity copyWith({
    String? keyword,
    List<int>? counts,
    int? toTopIndex,
  }) {
    return SearchResultStateEntity(
      keyword: keyword ?? this.keyword,
      counts: counts ?? this.counts,
      toTopIndex: toTopIndex ?? this.toTopIndex,
    );
  }

  /// Update count at specific index
  SearchResultStateEntity updateCount(int index, int count) {
    final newCounts = List<int>.from(counts);
    newCounts[index] = count;
    return copyWith(counts: newCounts);
  }

  /// Set to top index
  SearchResultStateEntity setToTopIndex(int index) {
    return copyWith(toTopIndex: index);
  }

  @override
  String toString() =>
      'SearchResultStateEntity(keyword: $keyword, toTopIndex: $toTopIndex)';
}
