import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/home_zone/data/datasources/rank_remote_datasource.dart';
import 'package:PiliPlus/features/home_zone/domain/entities/rank_params.dart';

/// Implementation of rank remote data source using VideoHttp
class RankRemoteDataSourceImpl implements RankRemoteDataSource {
  const RankRemoteDataSourceImpl();

  @override
  Future<LoadingState> fetchRank(FetchRankParams params) {
    switch (params.type) {
      case RankType.byPartition:
        final rid = params.rid!;
        return VideoHttp.getRankVideoList(rid);
      case RankType.pgc:
        return VideoHttp.pgcRankList(seasonType: params.seasonType!);
      case RankType.pgcSeason:
        final seasonType = params.seasonType ?? 0;
        return VideoHttp.pgcSeasonRankList(seasonType: seasonType);
    }
  }
}
