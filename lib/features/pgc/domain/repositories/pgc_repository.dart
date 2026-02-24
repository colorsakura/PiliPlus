import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC repository interface
abstract interface class PgcRepository {
  /// Get PGC index list
  Future<LoadingState<List<PgcIndexItem>?>> getPgcIndex(
    int page,
    HomeTabType tabType,
  );

  /// Get PGC follow list
  Future<LoadingState<List<FavPgcItemModel>?>> getPgcFollow(
    int page,
    HomeTabType tabType,
  );

  /// Get PGC timeline
  Future<LoadingState<List<TimelineResult>?>> getPgcTimeline();
}
