import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';

/// Repository interface for member favorite operations
abstract class MemberFavoriteRepository {
  /// Fetch member space favorites (both fav and sub folders)
  ///
  /// [mid] is the user ID
  ///
  /// Returns [Success] with list of space fav data, or [Error] if failed
  Future<LoadingState<List<SpaceFavData>?>> fetchSpaceFavorites(int mid);

  /// Fetch user favorite folders with pagination
  ///
  /// [params] contains mid, page, and pageSize
  ///
  /// Returns [Success] with response data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>>> fetchUserFavFolders(UserFavFolderParams params);

  /// Fetch user subscription folders with pagination
  ///
  /// [params] contains mid, page, and pageSize
  ///
  /// Returns [Success] with response data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>>> fetchUserSubFolders(UserSubFolderParams params);
}
