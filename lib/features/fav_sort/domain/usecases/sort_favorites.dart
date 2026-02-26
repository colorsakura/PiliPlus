import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_sort/domain/entities/fav_sort_entity.dart';
import 'package:PiliPlus/features/fav_sort/domain/repositories/fav_sort_repository.dart';

/// Use case for sorting items in a favorite folder
class SortFavorites {
  final FavSortRepository repository;

  const SortFavorites(this.repository);

  /// Execute the sort operation
  ///
  /// [params] contains the media ID and sort string
  ///
  /// Returns [Success] if sort was successful, [Error] otherwise
  Future<LoadingState<Null>> call(FavSortEntity params) {
    return repository.sortFavorites(params);
  }
}
