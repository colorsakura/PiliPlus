import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/fav/fav_pgc/data.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';

/// Remote data source for favorite PGC
class FavPgcRemoteDatasource {
  /// Get favorite PGC from API
  Future<LoadingState<FavPgcData>> getFavPgc({
    required int page,
    required int type,
    required int followStatus,
  }) {
    return FavHttp.favPgc(
      type: type,
      followStatus: followStatus,
      pn: page,
    );
  }

  /// Remove PGC from favorites via API
  Future<LoadingState<String?>> removePgc(int seasonId) {
    return VideoHttp.pgcDel(seasonId: seasonId);
  }

  /// Update PGC follow status via API
  Future<LoadingState<String?>> updatePgcFollowStatus({
    required String seasonId,
    required int followStatus,
  }) {
    return VideoHttp.pgcUpdate(
      seasonId: seasonId,
      status: followStatus,
    );
  }
}

/// Extension to convert FavPgcData to List<FavPgcItemModel>
extension FavPgcDataExtension on FavPgcData {
  List<FavPgcItemModel> toItemList() {
    return list ?? [];
  }
}
