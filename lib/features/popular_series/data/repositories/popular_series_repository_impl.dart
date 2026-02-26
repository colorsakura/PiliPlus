import 'package:PiliPlus/features/popular_series/data/datasources/popular_series_remote_datasource.dart';
import 'package:PiliPlus/features/popular_series/domain/repositories/popular_series_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/data.dart';

/// Popular series repository implementation
class PopularSeriesRepositoryImpl implements PopularSeriesRepository {
  final PopularSeriesRemoteDataSource _remoteDataSource;

  const PopularSeriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoadingState<List<PopularSeriesListItem>?>> getPopularSeriesList() {
    return _remoteDataSource.getPopularSeriesList();
  }

  @override
  Future<LoadingState<PopularSeriesOneData>> getPopularSeriesOne({
    required int number,
  }) {
    return _remoteDataSource.getPopularSeriesOne(number: number);
  }
}
