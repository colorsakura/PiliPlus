import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/history_search/domain/entities/history_search.dart';

/// History search repository interface
abstract class HistorySearchRepository {
  /// Search history
  Future<LoadingState<HistorySearchResultEntity>> searchHistory(HistorySearchParamsEntity params);

  /// Delete history item
  Future<LoadingState<void>> deleteHistory(HistoryDeleteParamsEntity params);

  /// Delete multiple history items
  Future<LoadingState<void>> deleteMultipleHistory(List<String> historyKeys, String account);
}
