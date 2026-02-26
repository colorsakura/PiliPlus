import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_fav/data.dart';
import 'package:PiliPlus/features/member_favorite/domain/repositories/member_favorite_repository.dart';

/// Use case for fetching member space favorites
class FetchSpaceFavorites {
  final MemberFavoriteRepository repository;

  const FetchSpaceFavorites(this.repository);

  /// Execute the fetch operation
  ///
  /// [mid] is the user ID
  ///
  /// Returns [Success] with list of space fav data, or [Error] if failed
  Future<LoadingState<List<SpaceFavData>?>> call(int mid) {
    return repository.fetchSpaceFavorites(mid);
  }
}
