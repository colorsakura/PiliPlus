import 'package:PiliPlus/features/member_season_series/domain/entities/member_season_series_item_entity.dart';
import 'package:PiliPlus/features/member_season_series/domain/repositories/member_season_series_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member season series
class FetchMemberSeasonSeriesUseCase {
  const FetchMemberSeasonSeriesUseCase(this._repository);

  final MemberSeasonSeriesRepository _repository;

  Future<LoadingState<List<MemberSeasonSeriesItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberSeasonSeries(mid: mid, page: page);
  }
}
