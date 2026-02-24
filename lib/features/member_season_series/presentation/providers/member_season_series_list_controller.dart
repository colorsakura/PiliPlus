import 'package:PiliPlus/features/member_season_series/domain/entities/member_season_series_item_entity.dart';
import 'package:PiliPlus/features/member_season_series/domain/usecases/fetch_member_season_series.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for member season series list
class MemberSeasonSeriesListState {
  MemberSeasonSeriesListState({
    LoadingState<List<MemberSeasonSeriesItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.count,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberSeasonSeriesItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int? count;

  MemberSeasonSeriesListState copyWith({
    LoadingState<List<MemberSeasonSeriesItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? count,
  }) {
    return MemberSeasonSeriesListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      count: count ?? this.count,
    );
  }
}

/// Controller for member season series list
class MemberSeasonSeriesListController extends ChangeNotifier {
  MemberSeasonSeriesListController({
    required this.mid,
    required FetchMemberSeasonSeriesUseCase fetchSeasonSeries,
  }) : _fetchSeasonSeries = fetchSeasonSeries {
    queryData(isRefresh: true);
  }

  final int mid;
  final FetchMemberSeasonSeriesUseCase _fetchSeasonSeries;

  MemberSeasonSeriesListState _state = MemberSeasonSeriesListState();

  MemberSeasonSeriesListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchSeasonSeries(mid: mid, page: page);

    if (result is Loading) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: LoadingState.loading(),
          isLoading: false,
        );
      }
    } else if (result is Error) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: result,
          isLoading: false,
        );
      }
    } else if (result is Success<List<MemberSeasonSeriesItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        _state = _state.copyWith(isEnd: true, isLoading: false);
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        // Custom checkIsEnd logic from original controller
        final totalCount = _state.count;
        final currentLength = isRefresh
            ? dataList.length
            : (_state.listState is Success<List<MemberSeasonSeriesItemEntity>?>
                ? (_state.listState as Success<List<MemberSeasonSeriesItemEntity>?>)
                        .response
                        ?.length ??
                    0
                : 0) + dataList.length;

        final shouldEnd =
            totalCount != null && currentLength >= totalCount;

        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
            isEnd: shouldEnd,
          );
        } else {
          final currentState = _state.listState;
          if (currentState is Success<List<MemberSeasonSeriesItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            _state = _state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
              isEnd: shouldEnd,
            );
          }
        }
      }
    }

    notifyListeners();
  }

  Future<void> onRefresh() {
    _state = _state.copyWith(currentPage: 1, isEnd: false, count: null);
    return queryData(isRefresh: true);
  }

  Future<void> onReload() {
    _state = _state.copyWith(listState: LoadingState.loading());
    notifyListeners();
    return queryData(isRefresh: true);
  }

  Future<void> onLoadMore() {
    return queryData(isRefresh: false);
  }
}
