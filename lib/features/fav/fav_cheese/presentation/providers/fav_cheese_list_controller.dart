import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_cheese/item.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/usecases/get_fav_cheese_usecase.dart';
import 'package:PiliPlus/features/fav/fav_cheese/domain/usecases/remove_cheese_usecase.dart';

/// State for fav cheese list
class FavCheeseListState {
  const FavCheeseListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<SpaceCheeseItem>?> listState;
  final int currentPage;
  final bool isEnd;

  FavCheeseListState copyWith({
    LoadingState<List<SpaceCheeseItem>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavCheeseListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite cheese list
class FavCheeseController extends ChangeNotifier {
  FavCheeseController({
    required this.getFavCheeseUseCase,
    required this.removeCheeseUseCase,
  }) : _state = FavCheeseListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final GetFavCheeseUseCase getFavCheeseUseCase;
  final RemoveCheeseUseCase removeCheeseUseCase;

  FavCheeseListState _state;

  FavCheeseListState get state => _state;

  final ScrollController scrollController = ScrollController();

  void _updateState(FavCheeseListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query cheese list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavCheeseUseCase(page);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<SpaceCheeseItem>?>).response ?? []
          : <SpaceCheeseItem>[];

      final newList = isRefresh ? response : [...currentList, ...response];

      // Detect end by checking if response is empty
      final isEnd = response.isEmpty;

      _updateState(
        _state.copyWith(
          listState: Success(newList),
          currentPage: page + 1,
          isEnd: isEnd,
        ),
      );
    } else if (result case Error(:final errMsg)) {
      _updateState(_state.copyWith(listState: Error(errMsg)));
    }
  }

  /// Refresh the list
  Future<void> onRefresh() async {
    await queryData(isRefresh: true);
  }

  /// Load more items
  Future<void> onLoadMore() async {
    await queryData(isRefresh: false);
  }

  /// Reload the list
  Future<void> onReload() async {
    _updateState(
      FavCheeseListState(
        listState: LoadingState.loading(),
        currentPage: _state.currentPage,
        isEnd: _state.isEnd,
      ),
    );
    await queryData(isRefresh: true);
  }

  /// Remove cheese from favorites
  Future<bool> removeCheese(int index, int sid) async {
    final result = await removeCheeseUseCase(sid);
    if (result.isSuccess && _state.listState is Success) {
      final currentList =
          (_state.listState as Success<List<SpaceCheeseItem>?>).response ??
          <SpaceCheeseItem>[];
      final newList = List<SpaceCheeseItem>.from(currentList)..removeAt(index);
      _updateState(_state.copyWith(listState: Success(newList)));
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
