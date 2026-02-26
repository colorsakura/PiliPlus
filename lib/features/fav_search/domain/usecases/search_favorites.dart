import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_search/domain/entities/fav_search_result.dart';
import 'package:PiliPlus/features/fav_search/domain/repositories/fav_search_repository.dart';

/// Search favorites use case
class SearchFavorites {
  final FavSearchRepository repository;

  const SearchFavorites(this.repository);

  Future<LoadingState<FavSearchResultEntity>> call(FavSearchParamsEntity params) {
    return repository.searchFavorites(params);
  }
}
