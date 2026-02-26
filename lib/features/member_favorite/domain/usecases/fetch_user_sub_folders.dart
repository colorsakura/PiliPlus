import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_favorite/domain/entities/space_fav_params.dart';
import 'package:PiliPlus/features/member_favorite/domain/repositories/member_favorite_repository.dart';

/// Use case for fetching user subscription folders
class FetchUserSubFolders {
  final MemberFavoriteRepository repository;

  const FetchUserSubFolders(this.repository);

  /// Execute the fetch operation
  ///
  /// [params] contains mid, page, and pageSize
  ///
  /// Returns [Success] with response data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>>> call(UserSubFolderParams params) {
    return repository.fetchUserSubFolders(params);
  }
}
