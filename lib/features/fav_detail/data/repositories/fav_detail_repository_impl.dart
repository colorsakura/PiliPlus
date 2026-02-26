import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/features/fav_detail/data/datasources/fav_detail_remote_datasource.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';
import 'package:PiliPlus/features/fav_detail/domain/repositories/fav_detail_repository.dart';

/// Implementation of favorite detail repository
class FavDetailRepositoryImpl implements FavDetailRepository {
  final FavDetailRemoteDataSource remoteDataSource;

  const FavDetailRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<FavDetailData>> fetchFavDetail(FetchFavDetailParams params) {
    return remoteDataSource.fetchFavDetail(params);
  }

  @override
  Future<LoadingState<Null>> cancelFavorites(CancelFavoriteParams params) {
    return remoteDataSource.cancelFavorites(params);
  }

  @override
  Future<LoadingState<Null>> toggleFavFolder(ToggleFavFolderParams params) {
    return params.isFavorite
        ? remoteDataSource.unfavFolder(params.mediaId)
        : remoteDataSource.favFolder(params.mediaId);
  }

  @override
  Future<LoadingState<Null>> cleanFavorites(CleanFavoritesParams params) {
    return remoteDataSource.cleanFavorites(params);
  }
}
