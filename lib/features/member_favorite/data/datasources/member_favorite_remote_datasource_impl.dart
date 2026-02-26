import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/api.dart';
import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/features/member_favorite/data/datasources/member_favorite_remote_datasource.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';

/// Implementation of member favorite remote data source
class MemberFavoriteRemoteDataSourceImpl implements MemberFavoriteRemoteDataSource {
  const MemberFavoriteRemoteDataSourceImpl();

  @override
  Future<LoadingState<List<SpaceFavData>?>> fetchSpaceFavorites(int mid) {
    return FavHttp.spaceFav(mid: mid);
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> fetchUserFavFolders(UserFavFolderParams params) async {
    try {
      final res = await Request().get(
        Api.userFavFolder,
        queryParameters: {
          'pn': params.page,
          'ps': params.pageSize,
          'up_mid': params.mid,
        },
      );
      if (res.data['code'] == 0) {
        return Success(res.data['data'] ?? {});
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> fetchUserSubFolders(UserSubFolderParams params) async {
    try {
      final res = await Request().get(
        Api.userSubFolder,
        queryParameters: {
          'up_mid': params.mid,
          'ps': params.pageSize,
          'pn': params.page,
          'platform': 'web',
        },
      );
      if (res.data['code'] == 0) {
        return Success(res.data['data'] ?? {});
      } else {
        return Error(res.data['message']);
      }
    } catch (e) {
      return Error(e.toString());
    }
  }
}
