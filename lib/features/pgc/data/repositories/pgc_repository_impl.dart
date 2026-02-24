import 'package:PiliPlus/features/pgc/data/datasources/pgc_remote_datasource.dart';
import 'package:PiliPlus/features/pgc/domain/repositories/pgc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC repository implementation
class PgcRepositoryImpl implements PgcRepository {
  final PgcRemoteDataSource _remoteDataSource;

  PgcRepositoryImpl({
    required PgcRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<PgcIndexItem>?>> getPgcIndex(
    int page,
    HomeTabType tabType,
  ) {
    return _remoteDataSource.getPgcIndex(page, tabType);
  }

  @override
  Future<LoadingState<List<FavPgcItemModel>?>> getPgcFollow(
    int page,
    HomeTabType tabType,
  ) {
    return _remoteDataSource.getPgcFollow(page, tabType);
  }

  @override
  Future<LoadingState<List<TimelineResult>?>> getPgcTimeline() {
    return _remoteDataSource.getPgcTimeline();
  }
}
