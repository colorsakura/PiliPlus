import 'package:flutter/foundation.dart';
import 'package:PiliPlus/features/popular_series/domain/usecases/get_popular_series_data.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/config.dart';

/// Popular series state
class PopularSeriesState {
  final LoadingState<List<HotVideoItemModel>?> videoListState;
  final LoadingState<List<PopularSeriesListItem>?> seriesListState;
  final PopularSeriesConfig? config;
  final String? reminder;
  final int currentNumber;

  const PopularSeriesState({
    required this.videoListState,
    required this.seriesListState,
    this.config,
    this.reminder,
    this.currentNumber = 1,
  });

  PopularSeriesState copyWith({
    LoadingState<List<HotVideoItemModel>?>? videoListState,
    LoadingState<List<PopularSeriesListItem>?>? seriesListState,
    PopularSeriesConfig? config,
    String? reminder,
    int? currentNumber,
  }) {
    return PopularSeriesState(
      videoListState: videoListState ?? this.videoListState,
      seriesListState: seriesListState ?? this.seriesListState,
      config: config ?? this.config,
      reminder: reminder ?? this.reminder,
      currentNumber: currentNumber ?? this.currentNumber,
    );
  }
}

/// Popular series controller
class PopularSeriesController extends ChangeNotifier {
  final GetPopularSeriesListUseCase _getPopularSeriesListUseCase;
  final GetPopularSeriesOneUseCase _getPopularSeriesOneUseCase;

  PopularSeriesState _state = PopularSeriesState(
    videoListState: LoadingState.loading(),
    seriesListState: LoadingState.loading(),
  );

  PopularSeriesState get state => _state;

  List<PopularSeriesListItem>? get seriesList {
    if (_state.seriesListState is Success<List<PopularSeriesListItem>?>) {
      return (_state.seriesListState as Success<List<PopularSeriesListItem>?>)
          .response;
    }
    return null;
  }

  PopularSeriesController({
    required GetPopularSeriesListUseCase getPopularSeriesListUseCase,
    required GetPopularSeriesOneUseCase getPopularSeriesOneUseCase,
  }) : _getPopularSeriesListUseCase = getPopularSeriesListUseCase,
       _getPopularSeriesOneUseCase = getPopularSeriesOneUseCase {
    Future.microtask(() => getSeriesList());
  }

  void _updateState(PopularSeriesState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Get series list
  Future<void> getSeriesList() async {
    final result = await _getPopularSeriesListUseCase();
    if (result case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        _updateState(
          _state.copyWith(
            seriesListState: result,
            currentNumber: response.first.number!,
          ),
        );
        await queryVideoList();
      } else {
        _updateState(_state.copyWith(seriesListState: result));
      }
    } else {
      _updateState(_state.copyWith(seriesListState: result));
    }
  }

  /// Query video list for current series
  Future<void> queryVideoList() async {
    final result = await _getPopularSeriesOneUseCase(
      number: _state.currentNumber,
    );
    if (result case Success(:final response)) {
      _updateState(
        _state.copyWith(
          videoListState: Success(response.list),
          config: response.config,
          reminder: response.reminder,
        ),
      );
    } else if (result is Error) {
      _updateState(_state.copyWith(videoListState: result));
    }
  }

  /// Refresh all data
  Future<void> onRefresh() async {
    await getSeriesList();
  }

  /// Reload video list
  Future<void> onReload() async {
    if (seriesList == null) {
      return getSeriesList();
    }
    await queryVideoList();
  }

  /// Switch to different series
  void switchSeries(int number) {
    _updateState(_state.copyWith(currentNumber: number));
    onReload();
  }
}
