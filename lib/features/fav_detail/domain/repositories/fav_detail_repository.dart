import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';

/// Repository interface for favorite folder detail operations
abstract class FavDetailRepository {
  /// Fetch favorite folder detail with pagination
  Future<LoadingState<FavDetailData>> fetchFavDetail(FetchFavDetailParams params);

  /// Cancel/unfavorite items
  Future<LoadingState<Null>> cancelFavorites(CancelFavoriteParams params);

  /// Favorite or unfavorite a folder
  Future<LoadingState<Null>> toggleFavFolder(ToggleFavFolderParams params);

  /// Clean all favorites in a folder
  Future<LoadingState<Null>> cleanFavorites(CleanFavoritesParams params);
}
