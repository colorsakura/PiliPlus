import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/pgc.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC remote data source
///
/// Handles API calls for PGC data
class PgcRemoteDataSource {
  /// Get PGC index list from API
  Future<LoadingState<List<PgcIndexItem>?>> getPgcIndex(
    int page,
    HomeTabType tabType,
  ) {
    return PgcHttp.pgcIndex(
      page: page,
      indexType: tabType == HomeTabType.cinema ? 102 : null,
    );
  }

  /// Get PGC follow list from API
  Future<LoadingState<List<FavPgcItemModel>?>> getPgcFollow(
    int page,
    HomeTabType tabType,
  ) async {
    final result = await FavHttp.favPgc(
      type: tabType == HomeTabType.bangumi ? 1 : 2,
      pn: page,
    );

    return switch (result) {
      Loading() => result,
      Success(:final response) => Success(response.list),
      Error() => result,
    };
  }

  /// Get PGC timeline from API
  Future<LoadingState<List<TimelineResult>?>> getPgcTimeline() async {
    final res = await Future.wait([
      PgcHttp.pgcTimeline(types: 1, before: 6, after: 6),
      PgcHttp.pgcTimeline(types: 4, before: 6, after: 6),
    ]);

    final list1 = res.first.dataOrNull;
    final list2 = res[1].dataOrNull;

    if (list1 != null && list2 != null && list1.isNotEmpty && list2.isNotEmpty) {
      for (var i = 0; i < list1.length; i++) {
        list1[i].addAll(list2[i]);
      }
    }

    return Success(list1 ?? list2);
  }
}
