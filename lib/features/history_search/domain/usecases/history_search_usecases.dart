import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/history_search/domain/entities/history_search.dart';
import 'package:PiliPlus/features/history_search/domain/repositories/history_search_repository.dart';

/// Search history use case
class SearchHistory {
  final HistorySearchRepository repository;

  const SearchHistory(this.repository);

  Future<LoadingState<HistorySearchResultEntity>> call(HistorySearchParamsEntity params) {
    return repository.searchHistory(params);
  }
}

/// Delete history item use case
class DeleteHistoryItem {
  final HistorySearchRepository repository;

  const DeleteHistoryItem(this.repository);

  Future<LoadingState<void>> call(HistoryDeleteParamsEntity params) {
    return repository.deleteHistory(params);
  }
}

/// Delete multiple history items use case
class DeleteMultipleHistoryItems {
  final HistorySearchRepository repository;

  const DeleteMultipleHistoryItems(this.repository);

  Future<LoadingState<void>> call(List<String> historyKeys, String account) {
    return repository.deleteMultipleHistory(historyKeys, account);
  }
}
