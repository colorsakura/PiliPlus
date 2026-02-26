import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';

/// Data source interface for favorite folder detail operations
abstract class FavDetailRemoteDataSource {
  /// Fetch favorite folder detail via API
  Future<LoadingState<FavDetailData>> fetchFavDetail(FetchFavDetailParams params);

  /// Cancel favorites via API
  Future<LoadingState<Null>> cancelFavorites(CancelFavoriteParams params);

  /// Favorite a folder via API
  Future<LoadingState<Null>> favFolder(int mediaId);

  /// Unfavorite a folder via API
  Future<LoadingState<Null>> unfavFolder(int mediaId);

  /// Clean all favorites via API
  Future<LoadingState<Null>> cleanFavorites(CleanFavoritesParams params);
}
