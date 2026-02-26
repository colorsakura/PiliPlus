import 'package:PiliPlus/http/loading_state.dart';

/// Data source interface for favorite sort operations
abstract class FavSortRemoteDataSource {
  /// Sort items in a favorite folder via API
  ///
  /// [mediaId] - The media ID of the favorite folder
  /// [sort] - The sort string in format "prevItemId:prevItemType:currItemId:currItemType"
  ///
  /// Returns [Success] if sort was successful, [Error] otherwise
  Future<LoadingState<Null>> sortFavorites({
    required Object mediaId,
    required String sort,
  });
}
