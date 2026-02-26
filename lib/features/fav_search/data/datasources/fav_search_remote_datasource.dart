import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_detail/data.dart';

/// Favorite search remote data source interface
abstract class FavSearchRemoteDataSource {
  /// Search favorites in a folder
  Future<LoadingState<FavDetailData>> searchFolderDetail({
    required int pn,
    required int ps,
    required int mediaId,
    required String keyword,
    required int type,
    required dynamic order,
  });
}

/// Favorite search remote data source implementation
class FavSearchRemoteDataSourceImpl implements FavSearchRemoteDataSource {
  const FavSearchRemoteDataSourceImpl();

  @override
  Future<LoadingState<FavDetailData>> searchFolderDetail({
    required int pn,
    required int ps,
    required int mediaId,
    required String keyword,
    required int type,
    required dynamic order,
  }) {
    return FavHttp.userFavFolderDetail(
      pn: pn,
      ps: ps,
      mediaId: mediaId,
      keyword: keyword,
      type: type,
      order: order,
    );
  }
}
