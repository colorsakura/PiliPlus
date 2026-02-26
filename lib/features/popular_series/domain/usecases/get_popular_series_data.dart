import 'package:PiliPlus/features/popular_series/domain/repositories/popular_series_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/data.dart';

/// Get popular series list use case
class GetPopularSeriesListUseCase {
  final PopularSeriesRepository _repository;

  const GetPopularSeriesListUseCase(this._repository);

  Future<LoadingState<List<PopularSeriesListItem>?>> call() =>
      _repository.getPopularSeriesList();
}

/// Get popular series one use case
class GetPopularSeriesOneUseCase {
  final PopularSeriesRepository _repository;

  const GetPopularSeriesOneUseCase(this._repository);

  Future<LoadingState<PopularSeriesOneData>> call({required int number}) =>
      _repository.getPopularSeriesOne(number: number);
}
