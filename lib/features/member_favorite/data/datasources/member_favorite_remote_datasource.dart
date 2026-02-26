import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';

/// Data source interface for member favorite operations
abstract class MemberFavoriteRemoteDataSource {
  /// Fetch member space favorites via API
  Future<LoadingState<List<SpaceFavData>?>> fetchSpaceFavorites(int mid);

  /// Fetch user favorite folders via API
  Future<LoadingState<Map<String, dynamic>>> fetchUserFavFolders(UserFavFolderParams params);

  /// Fetch user subscription folders via API
  Future<LoadingState<Map<String, dynamic>>> fetchUserSubFolders(UserSubFolderParams params);
}
