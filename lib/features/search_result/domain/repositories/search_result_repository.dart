import 'package:PiliPlus/features/search_result/domain/entities/search_result_state.dart';

/// Search result repository interface
abstract class SearchResultRepository {
  /// Get current search result state
  SearchResultStateEntity getState();

  /// Update state with new keyword
  void updateKeyword(String keyword);

  /// Update count for a specific search type
  void updateCount(int index, int count);

  /// Set the index of the tab to scroll to top
  void setToTopIndex(int index);
}
