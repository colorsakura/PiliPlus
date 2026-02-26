import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_folder_sort/data/datasources/fav_folder_sort_remote_datasource.dart';
import 'package:PiliPlus/http/fav.dart' as http;

/// Implementation of favorite folder sort remote data source using FavHttp
class FavFolderSortRemoteDataSourceImpl implements FavFolderSortRemoteDataSource {
  const FavFolderSortRemoteDataSourceImpl();

  @override
  Future<LoadingState<Null>> sortFolders({
    required String sort,
  }) {
    return http.FavHttp.sortFavFolder(sort: sort);
  }
}
