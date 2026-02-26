import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_search/domain/entities/fav_search_result.dart';

/// Favorite search repository interface
abstract class FavSearchRepository {
  /// Search favorites in a folder
  Future<LoadingState<FavSearchResultEntity>> searchFavorites(FavSearchParamsEntity params);
}
