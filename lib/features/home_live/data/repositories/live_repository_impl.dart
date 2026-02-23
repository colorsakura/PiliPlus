import 'package:PiliPlus/features/home_live/data/datasources/live_remote_datasource.dart';
import 'package:PiliPlus/features/home_live/domain/entities/live_area_result.dart';
import 'package:PiliPlus/features/home_live/domain/entities/live_feed_result.dart';
import 'package:PiliPlus/features/home_live/domain/repositories/live_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 直播仓库实现
class LiveRepositoryImpl implements LiveRepository {
  final LiveRemoteDataSource _remoteDataSource;

  LiveRepositoryImpl({
    required LiveRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LiveFeedResult> getLiveFeed({
    required int pn,
    bool moduleSelect = false,
  }) async {
    final result = await _remoteDataSource.fetchLiveFeed(
      pn: pn,
      moduleSelect: moduleSelect,
    );

    return switch (result) {
      Success(:final response) => response,
      Error(:final errMsg) => throw Exception(errMsg),
      _ => throw Exception('Unknown error'),
    };
  }

  @override
  Future<LiveAreaResult> getLiveAreaList({
    required int pn,
    int? areaId,
    int? parentAreaId,
    String? sortType,
  }) async {
    final result = await _remoteDataSource.fetchLiveAreaList(
      pn: pn,
      areaId: areaId,
      parentAreaId: parentAreaId,
      sortType: sortType,
    );

    return switch (result) {
      Success(:final response) => response,
      Error(:final errMsg) => throw Exception(errMsg),
      _ => throw Exception('Unknown error'),
    };
  }
}
