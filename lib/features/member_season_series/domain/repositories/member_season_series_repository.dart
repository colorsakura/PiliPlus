import 'package:PiliPlus/features/member_season_series/domain/entities/member_season_series_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member season series data
abstract class MemberSeasonSeriesRepository {
  Future<LoadingState<List<MemberSeasonSeriesItemEntity>>> fetchMemberSeasonSeries({
    required int mid,
    required int page,
  });
}
