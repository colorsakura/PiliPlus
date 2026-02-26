import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/data.dart';

/// Popular series remote data source
class PopularSeriesRemoteDataSource {
  /// Get popular series list from API
  Future<LoadingState<List<PopularSeriesListItem>?>> getPopularSeriesList() {
    return VideoHttp.popularSeriesList();
  }

  /// Get popular series one from API
  Future<LoadingState<PopularSeriesOneData>> getPopularSeriesOne({
    required int number,
  }) {
    return VideoHttp.popularSeriesOne(number: number);
  }
}
