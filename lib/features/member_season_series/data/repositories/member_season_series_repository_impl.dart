import 'package:PiliPlus/features/member_season_series/domain/entities/member_season_series_item_entity.dart';
import 'package:PiliPlus/features/member_season_series/domain/repositories/member_season_series_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member season series repository
class MemberSeasonSeriesRepositoryImpl implements MemberSeasonSeriesRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberSeasonSeriesRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberSeasonSeriesItemEntity>>>
  fetchMemberSeasonSeries({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.seasonSeriesList(
        mid: mid,
        pn: page,
      );
      // Merge seasonsList and seriesList as in the original controller
      final items =
          (data.seasonsList ?? <MemberSeasonSeriesItemEntity>[]) +
          (data.seriesList ?? <MemberSeasonSeriesItemEntity>[]);
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
