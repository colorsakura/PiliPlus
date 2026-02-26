import 'package:PiliPlus/features/search_result/domain/entities/search_result_state.dart';
import 'package:PiliPlus/features/search_result/domain/repositories/search_result_repository.dart';

/// Manage search result state use case
class ManageSearchResultState {
  final SearchResultRepository repository;

  const ManageSearchResultState(this.repository);

  /// Get current state
  SearchResultStateEntity call() {
    return repository.getState();
  }

  /// Initialize with keyword
  void initKeyword(String keyword) {
    repository.updateKeyword(keyword);
  }

  /// Update count for a specific search type
  void updateCount(int index, int count) {
    repository.updateCount(index, count);
  }

  /// Set the index of the tab to scroll to top
  void setToTopIndex(int index) {
    repository.setToTopIndex(index);
  }
}
