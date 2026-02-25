import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';

/// Repository interface for favorite PGC (anime/bangumi)
abstract class FavPgcRepository {
  /// Get favorite PGC list
  Future<LoadingState<List<FavPgcItemModel>>> getFavPgc(
    int page,
    int type,
    int followStatus,
  );

  /// Remove PGC from favorites
  Future<LoadingState<String?>> removePgc(int seasonId);

  /// Update PGC follow status
  Future<LoadingState<String?>> updatePgcFollowStatus(
    String seasonId,
    int followStatus,
  );
}
