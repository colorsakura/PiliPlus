import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/popular_series/domain/usecases/get_popular_series_data.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/model_hot_video_item.dart';
import 'package:PiliPlus/models/popular/popular_series_list/list.dart';
import 'package:PiliPlus/models/popular/popular_series_one/config.dart';
import 'package:PiliPlus/features/popular_series/presentation/providers/popular_series_providers.dart';

part 'popular_series_list_controller.g.dart';

/// Popular series state
class PopularSeriesListState {
  final LoadingState<List<HotVideoItemModel>?> videoListState;
  final LoadingState<List<PopularSeriesListItem>?> seriesListState;
  final PopularSeriesConfig? config;
  final String? reminder;
  final int currentNumber;

  const PopularSeriesListState({
    required this.videoListState,
    required this.seriesListState,
    this.config,
    this.reminder,
    this.currentNumber = 1,
  });

  PopularSeriesListState copyWith({
    LoadingState<List<HotVideoItemModel>?>? videoListState,
    LoadingState<List<PopularSeriesListItem>?>? seriesListState,
    PopularSeriesConfig? config,
    String? reminder,
    int? currentNumber,
  }) {
    return PopularSeriesListState(
      videoListState: videoListState ?? this.videoListState,
      seriesListState: seriesListState ?? this.seriesListState,
      config: config ?? this.config,
      reminder: reminder ?? this.reminder,
      currentNumber: currentNumber ?? this.currentNumber,
    );
  }
}

/// Popular series controller (Riverpod version)
@riverpod
class PopularSeriesListController extends _$PopularSeriesListController {
  @override
  PopularSeriesListState build() {
    // Fetch data on initialization
    Future.microtask(() => getSeriesList());
    return PopularSeriesListState(
      videoListState: LoadingState.loading(),
      seriesListState: LoadingState.loading(),
    );
  }

  List<PopularSeriesListItem>? get seriesList {
    if (state.seriesListState is Success<List<PopularSeriesListItem>?>) {
      return (state.seriesListState as Success<List<PopularSeriesListItem>?>)
          .response;
    }
    return null;
  }

  /// Get series list
  Future<void> getSeriesList() async {
    final getList = ref.read(getPopularSeriesListUseCaseProvider);
    final result = await getList();

    if (result case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        state = state.copyWith(
          seriesListState: result,
          currentNumber: response.first.number!,
        );
        await queryVideoList();
      } else {
        state = state.copyWith(seriesListState: result);
      }
    } else {
      state = state.copyWith(seriesListState: result);
    }
  }

  /// Query video list for current series
  Future<void> queryVideoList() async {
    final getOne = ref.read(getPopularSeriesOneUseCaseProvider);
    final result = await getOne(number: state.currentNumber);

    if (result case Success(:final response)) {
      state = state.copyWith(
        videoListState: Success(response.list),
        config: response.config,
        reminder: response.reminder,
      );
    } else if (result is Error) {
      state = state.copyWith(videoListState: result);
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
    state = state.copyWith(currentNumber: number);
    onReload();
  }
}
