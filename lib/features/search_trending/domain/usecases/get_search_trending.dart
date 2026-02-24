import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/search_trending/domain/entities/search_trending_item.dart';
import 'package:PiliPlus/features/search_trending/domain/repositories/search_trending_repository.dart';

/// Get search trending use case
class GetSearchTrendingUseCase {
  final SearchTrendingRepository _repository;

  const GetSearchTrendingUseCase(this._repository);

  Future<LoadingState<List<SearchTrendingItemEntity>>> call() {
    return _repository.getSearchTrending();
  }
}
