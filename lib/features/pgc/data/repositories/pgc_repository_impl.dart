import 'package:PiliPlus/features/pgc/data/datasources/pgc_remote_datasource.dart';
import 'package:PiliPlus/features/pgc/domain/repositories/pgc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC repository implementation
class PgcRepositoryImpl implements PgcRepository {
  final PgcApiDataSource _remoteDataSource;

  PgcRepositoryImpl({
    required PgcApiDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<PgcIndexItem>?>> getPgcIndex(
    int page,
    HomeTabType tabType,
  ) {
    // Map HomeTabType to indexType values
    final indexType = switch (tabType) {
      HomeTabType.bangumi => 1,
      HomeTabType.cinema => 2,
      _ => 1,
    };
    return _remoteDataSource.getPgcIndex(page: page, indexType: indexType);
  }

  @override
  Future<LoadingState<List<FavPgcItemModel>?>> getPgcFollow(
    int page,
    HomeTabType tabType,
  ) {
    // Map HomeTabType to type values for fav API
    final type = switch (tabType) {
      HomeTabType.bangumi => 1,
      HomeTabType.cinema => 2,
      _ => 1,
    };
    return _remoteDataSource.getPgcFollowList(page: page, type: type);
  }

  @override
  Future<LoadingState<List<TimelineResult>?>> getPgcTimeline() {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final oneDayAgo = now - 86400;
    return _remoteDataSource.getPgcTimeline(before: now, after: oneDayAgo);
  }
}
