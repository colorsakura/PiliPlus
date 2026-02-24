import 'package:PiliPlus/models/common/search/search_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// State for search result
@immutable
class SearchResultState {
  const SearchResultState({
    required this.keyword,
    required this.counts,
    required this.toTopIndex,
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
/// Manages:
/// - Search keyword
/// - Result count for each search type tab
/// - Scroll-to-top functionality
class SearchResultController extends Notifier<SearchResultState> {
  @override
  SearchResultState build() {
    return SearchResultState(
      keyword: '',
      counts: List.filled(SearchType.values.length, -1),
      toTopIndex: -1,
    );
  }

  /// Initialize with keyword
  void initKeyword(String keyword) {
    state = SearchResultState(
      keyword: keyword,
      counts: List.filled(SearchType.values.length, -1),
      toTopIndex: -1,
    );
  }

  /// Update count for a specific search type
  void updateCount(int index, int count) {
    final newCounts = List<int>.from(state.counts);
    newCounts[index] = count;
    state = state.copyWith(counts: newCounts);
  }

  /// Set the index of the tab to scroll to top
  void setToTopIndex(int index) {
    state = state.copyWith(toTopIndex: index);
  }
}
