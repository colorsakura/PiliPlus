import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_article/item.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/usecases/get_fav_articles_usecase.dart';
import 'package:PiliPlus/features/fav/fav_article/domain/usecases/remove_article_usecase.dart';

/// State for fav article list
class FavArticleListState {
  const FavArticleListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FavArticleItemModel>?> listState;
  final int currentPage;
  final bool isEnd;

  FavArticleListState copyWith({
    LoadingState<List<FavArticleItemModel>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavArticleListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite articles list
class FavArticleController extends ChangeNotifier {
  FavArticleController({
    required this.getFavArticlesUseCase,
    required this.removeArticleUseCase,
  }) : _state = FavArticleListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final GetFavArticlesUseCase getFavArticlesUseCase;
  final RemoveArticleUseCase removeArticleUseCase;

  FavArticleListState _state;

  FavArticleListState get state => _state;

  final ScrollController scrollController = ScrollController();

  void _updateState(FavArticleListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query article list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavArticlesUseCase(page);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<FavArticleItemModel>?>)
                    .response ??
                []
          : <FavArticleItemModel>[];

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
      FavArticleListState(
        listState: LoadingState.loading(),
        currentPage: _state.currentPage,
        isEnd: _state.isEnd,
      ),
    );
    await queryData(isRefresh: true);
  }

  /// Remove an article from favorites
  Future<bool> removeArticle(int index, String opusId) async {
    final result = await removeArticleUseCase(opusId);
    if (result.isSuccess && _state.listState is Success) {
      final currentList =
          (_state.listState as Success<List<FavArticleItemModel>?>).response ??
          <FavArticleItemModel>[];
      final newList = List<FavArticleItemModel>.from(currentList)
        ..removeAt(index);
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
