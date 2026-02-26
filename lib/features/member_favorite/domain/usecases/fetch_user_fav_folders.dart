import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';
import 'package:PiliPlus/features/member_favorite/domain/repositories/member_favorite_repository.dart';

/// Use case for fetching user favorite folders
class FetchUserFavFolders {
  final MemberFavoriteRepository repository;

  const FetchUserFavFolders(this.repository);

  /// Execute the fetch operation
  ///
  /// [params] contains mid, page, and pageSize
  ///
  /// Returns [Success] with response data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>>> call(UserFavFolderParams params) {
    return repository.fetchUserFavFolders(params);
  }
}
