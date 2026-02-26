import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_sort/data/datasources/fav_sort_remote_datasource.dart';
import 'package:PiliPlus/http/fav.dart' as http;

/// Implementation of favorite sort remote data source using FavHttp
class FavSortRemoteDataSourceImpl implements FavSortRemoteDataSource {
  const FavSortRemoteDataSourceImpl();

  @override
  Future<LoadingState<Null>> sortFavorites({
    required Object mediaId,
    required String sort,
  }) {
    return http.FavHttp.sortFav(
      mediaId: mediaId,
      sort: sort,
    );
  }
}
