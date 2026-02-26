import 'package:PiliPlus/features/search_result/domain/entities/search_result_state.dart';

/// Search result memory data source
abstract class SearchResultMemoryDataSource {
  /// Get current state
  SearchResultStateEntity getState();

  /// Update state
  void updateState(SearchResultStateEntity state);
}

/// Search result memory data source implementation
class SearchResultMemoryDataSourceImpl implements SearchResultMemoryDataSource {
  SearchResultStateEntity _state = SearchResultStateEntity.initial();

  @override
  SearchResultStateEntity getState() => _state;

  @override
  void updateState(SearchResultStateEntity state) {
    _state = state;
  }
}
