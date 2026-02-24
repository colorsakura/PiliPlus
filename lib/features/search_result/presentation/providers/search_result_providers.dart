import 'package:PiliPlus/models/common/search/search_type.dart';

/// State for search result page
class SearchResultState {
  const SearchResultState({
    required this.keyword,
    required this.counts,
    this.toTopIndex = -1,
  });

  final String keyword;
  final List<int> counts;
  final int toTopIndex;

  SearchResultState copyWith({
    String? keyword,
    List<int>? counts,
    int? toTopIndex,
  }) {
    return SearchResultState(
      keyword: keyword ?? this.keyword,
      counts: counts ?? this.counts,
      toTopIndex: toTopIndex ?? this.toTopIndex,
    );
  }
}

/// Controller for search result page (Clean Architecture with Riverpod)
///
/// This controller manages:
/// - Search keyword from route parameters
/// - Result count for each search type tab
/// - Scroll-to-top functionality
class SearchResultController {
  SearchResultState _state;

  SearchResultState get state => _state;

  SearchResultController({required String keyword})
      : _state = SearchResultState(
          keyword: keyword,
          counts: List.filled(SearchType.values.length, -1),
        );

  void updateCount(int index, int count) {
    final newCounts = List<int>.from(_state.counts);
    newCounts[index] = count;
    _state = _state.copyWith(counts: newCounts);
  }

  void setToTopIndex(int index) {
    _state = _state.copyWith(toTopIndex: index);
  }

  void refreshToTop() {
    // Signal to refresh scroll to top (same index to trigger refresh)
    // The caller will handle the actual refresh
  }
}
