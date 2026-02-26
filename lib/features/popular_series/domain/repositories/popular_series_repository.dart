import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/data.dart';

/// Popular series repository interface
abstract interface class PopularSeriesRepository {
  /// Get popular series list
  Future<LoadingState<List<PopularSeriesListItem>?>> getPopularSeriesList();

  /// Get popular series one (videos)
  Future<LoadingState<PopularSeriesOneData>> getPopularSeriesOne({
    required int number,
  });
}
