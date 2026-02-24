import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/usecases/get_fav_topics_usecase.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/usecases/remove_topic_usecase.dart';

/// State for fav topic list
class FavTopicListState {
  const FavTopicListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FavTopicItem>?> listState;
  final int currentPage;
  final bool isEnd;

  FavTopicListState copyWith({
    LoadingState<List<FavTopicItem>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavTopicListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite topics list
class FavTopicController extends ChangeNotifier {
  FavTopicController({
    required this.getFavTopicsUseCase,
    required this.removeTopicUseCase,
  }) : _state = FavTopicListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final GetFavTopicsUseCase getFavTopicsUseCase;
  final RemoveTopicUseCase removeTopicUseCase;

  FavTopicListState _state;

  FavTopicListState get state => _state;

  final ScrollController scrollController = ScrollController();

  void _updateState(FavTopicListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query topic list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavTopicsUseCase(page);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<FavTopicItem>?>).response ?? []
          : <FavTopicItem>[];

      final newList = isRefresh ? response : [...currentList, ...response];

      // Detect end by checking if response is empty
      final isEnd = response.isEmpty;

      _updateState(_state.copyWith(
        listState: Success(newList),
        currentPage: page + 1,
        isEnd: isEnd,
      ));
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
    _updateState(FavTopicListState(
      listState: LoadingState.loading(),
      currentPage: _state.currentPage,
      isEnd: _state.isEnd,
    ));
    await queryData(isRefresh: true);
  }

  /// Remove a topic from favorites
  Future<bool> removeTopic(int index, int id) async {
    final result = await removeTopicUseCase(id);
    if (result.isSuccess && _state.listState is Success) {
      final currentList =
          (_state.listState as Success<List<FavTopicItem>?>).response ??
              <FavTopicItem>[];
      final newList = List<FavTopicItem>.from(currentList)..removeAt(index);
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
