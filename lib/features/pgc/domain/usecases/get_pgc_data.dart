import 'package:PiliPlus/features/pgc/domain/repositories/pgc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// Get PGC index use case
class GetPgcIndexUseCase {
  final PgcRepository _repository;

  const GetPgcIndexUseCase(this._repository);

  Future<LoadingState<List<PgcIndexItem>?>> call(
    int page,
    HomeTabType tabType,
  ) {
    return _repository.getPgcIndex(page, tabType);
  }
}

/// Get PGC follow list use case
class GetPgcFollowUseCase {
  final PgcRepository _repository;

  const GetPgcFollowUseCase(this._repository);

  Future<LoadingState<List<FavPgcItemModel>?>> call(
    int page,
    HomeTabType tabType,
  ) {
    return _repository.getPgcFollow(page, tabType);
  }
}

/// Get PGC timeline use case
class GetPgcTimelineUseCase {
  final PgcRepository _repository;

  const GetPgcTimelineUseCase(this._repository);

  Future<LoadingState<List<TimelineResult>?>> call() {
    return _repository.getPgcTimeline();
  }
}
