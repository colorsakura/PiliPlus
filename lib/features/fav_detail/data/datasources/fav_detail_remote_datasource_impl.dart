import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';
import 'package:PiliPlus/features/fav_detail/data/datasources/fav_detail_remote_datasource.dart';
import 'package:PiliPlus/features/fav_detail/domain/entities/fav_detail_params.dart';

/// Implementation of favorite detail remote data source using FavHttp
class FavDetailRemoteDataSourceImpl implements FavDetailRemoteDataSource {
  const FavDetailRemoteDataSourceImpl();

  @override
  Future<LoadingState<FavDetailData>> fetchFavDetail(FetchFavDetailParams params) {
    return FavHttp.userFavFolderDetail(
      pn: params.page,
      ps: params.pageSize,
      mediaId: params.mediaId,
      order: params.order,
    );
  }

  @override
  Future<LoadingState<Null>> cancelFavorites(CancelFavoriteParams params) {
    return FavHttp.favVideo(
      resources: params.resources,
      delIds: params.mediaId.toString(),
    );
  }

  @override
  Future<LoadingState<Null>> favFolder(int mediaId) {
    return FavHttp.favFavFolder(mediaId);
  }

  @override
  Future<LoadingState<Null>> unfavFolder(int mediaId) {
    return FavHttp.unfavFavFolder(mediaId);
  }

  @override
  Future<LoadingState<Null>> cleanFavorites(CleanFavoritesParams params) {
    return FavHttp.cleanFav(mediaId: params.mediaId);
  }
}
