import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_sort/domain/entities/fav_sort_entity.dart';

/// Repository interface for favorite sort operations
abstract class FavSortRepository {
  /// Sort items in a favorite folder
  ///
  /// [mediaId] - The media ID of the favorite folder
  /// [sort] - The sort string in format "prevItemId:prevItemType:currItemId:currItemType"
  ///
  /// Returns [Success] if sort was successful, [Error] otherwise
  Future<LoadingState<Null>> sortFavorites(FavSortEntity params);
}
