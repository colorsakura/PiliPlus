import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';
import 'package:PiliPlus/features/member_favorite/domain/repositories/member_favorite_repository.dart';
import 'package:PiliPlus/features/member_favorite/data/datasources/member_favorite_remote_datasource.dart';

/// Implementation of member favorite repository
class MemberFavoriteRepositoryImpl implements MemberFavoriteRepository {
  final MemberFavoriteRemoteDataSource remoteDataSource;

  const MemberFavoriteRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<List<SpaceFavData>?>> fetchSpaceFavorites(int mid) {
    return remoteDataSource.fetchSpaceFavorites(mid);
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> fetchUserFavFolders(UserFavFolderParams params) {
    return remoteDataSource.fetchUserFavFolders(params);
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> fetchUserSubFolders(UserSubFolderParams params) {
    return remoteDataSource.fetchUserSubFolders(params);
  }
}
