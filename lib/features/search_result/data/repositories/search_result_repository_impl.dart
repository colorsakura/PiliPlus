import 'package:PiliPlus/features/search_result/data/datasources/search_result_memory_datasource.dart';
import 'package:PiliPlus/features/search_result/domain/entities/search_result_state.dart';
import 'package:PiliPlus/features/search_result/domain/repositories/search_result_repository.dart';

/// Search result repository implementation
class SearchResultRepositoryImpl implements SearchResultRepository {
  final SearchResultMemoryDataSource memoryDataSource;

  const SearchResultRepositoryImpl({
    required this.memoryDataSource,
  });

  @override
  SearchResultStateEntity getState() {
    return memoryDataSource.getState();
  }

  @override
  void updateKeyword(String keyword) {
    final currentState = memoryDataSource.getState();
    memoryDataSource.updateState(SearchResultStateEntity.withKeyword(keyword));
  }

  @override
  void updateCount(int index, int count) {
    final currentState = memoryDataSource.getState();
    memoryDataSource.updateState(currentState.updateCount(index, count));
  }

  @override
  void setToTopIndex(int index) {
    final currentState = memoryDataSource.getState();
    memoryDataSource.updateState(currentState.setToTopIndex(index));
  }
}
