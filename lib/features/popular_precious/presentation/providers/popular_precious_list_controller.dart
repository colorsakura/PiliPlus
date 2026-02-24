import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/usecases/fetch_popular_precious.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for popular precious list
class PopularPreciousListState {
  PopularPreciousListState({
    LoadingState<List<PopularPreciousItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.mediaId,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<PopularPreciousItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int? mediaId;

  PopularPreciousListState copyWith({
    LoadingState<List<PopularPreciousItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? mediaId,
  }) {
    return PopularPreciousListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      mediaId: mediaId ?? this.mediaId,
    );
  }
}

/// Controller for popular precious list
class PopularPreciousListController extends ChangeNotifier {
  PopularPreciousListController({
    required FetchPopularPreciousUseCase fetchPopularPrecious,
  }) : _fetchPopularPrecious = fetchPopularPrecious {
    queryData(isRefresh: true);
  }

  final FetchPopularPreciousUseCase _fetchPopularPrecious;

  PopularPreciousListState _state = PopularPreciousListState();

  PopularPreciousListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchPopularPrecious(page: page);

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
    } else if (result is Success<List<PopularPreciousItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        _state = _state.copyWith(isEnd: true, isLoading: false);
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
          );
        } else {
          final currentState = _state.listState;
          if (currentState is Success<List<PopularPreciousItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            _state = _state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
            );
          }
        }
      }
    }

    notifyListeners();
  }

  Future<void> onRefresh() {
    _state = _state.copyWith(currentPage: 1, isEnd: false);
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
