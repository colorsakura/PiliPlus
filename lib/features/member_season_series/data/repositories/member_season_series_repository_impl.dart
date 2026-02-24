import 'package:PiliPlus/features/member_season_series/domain/entities/member_season_series_item_entity.dart';
import 'package:PiliPlus/features/member_season_series/domain/repositories/member_season_series_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space/space_season_series/season.dart';

/// Implementation of member season series repository
class MemberSeasonSeriesRepositoryImpl
    implements MemberSeasonSeriesRepository {
  const MemberSeasonSeriesRepositoryImpl();

  @override
  Future<LoadingState<List<MemberSeasonSeriesItemEntity>>>
      fetchMemberSeasonSeries({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.seasonSeriesList(
      mid: mid,
      pn: page,
    );

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        // Merge seasonsList and seriesList as in the original controller
        final items = (data.seasonsList ?? <MemberSeasonSeriesItemEntity>[]) +
            (data.seriesList ?? <MemberSeasonSeriesItemEntity>[]);
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
