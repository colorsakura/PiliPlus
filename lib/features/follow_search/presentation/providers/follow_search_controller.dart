import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/features/follow_search/domain/usecases/search_follows_usecase.dart';

/// State for follow search
class FollowSearchState {
  const FollowSearchState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FollowItemModel>?> listState;
  final int currentPage;
  final bool isEnd;

  FollowSearchState copyWith({
    LoadingState<List<FollowItemModel>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FollowSearchState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for follow search
class FollowSearchController extends ChangeNotifier {
  FollowSearchController({
    required this.mid,
    required SearchFollowsUseCase searchFollowsUseCase,
  }) : _searchFollowsUseCase = searchFollowsUseCase,
       _state = FollowSearchState(listState: LoadingState.loading());

  final int mid;
  final SearchFollowsUseCase _searchFollowsUseCase;

  FollowSearchState _state;
  final ScrollController scrollController = ScrollController();
  final TextEditingController editController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  FollowSearchState get state => _state;

  /// Search follows
  Future<void> searchFollows({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await _searchFollowsUseCase(
      mid: mid,
      name: editController.text,
      page: page,
    );

    // Convert LoadingState<FollowData> to LoadingState<List<FollowItemModel>?>
    final listState = switch (result) {
      Loading() => LoadingState<List<FollowItemModel>?>.loading(),
      Success(:final response) => Success(response.list),
      Error(:final errMsg) => Error(errMsg),
    };

    if (listState case Success(:final response)) {
      final newList = response ?? <FollowItemModel>[];
      final isEnd = newList.isEmpty;

      if (isRefresh) {
        _state = _state.copyWith(
          listState: Success(newList),
          currentPage: 2,
          isEnd: isEnd,
        );
      } else {
        final currentList = _state.listState is Success
            ? (_state.listState as Success<List<FollowItemModel>?>).response ??
                  []
            : <FollowItemModel>[];
        _state = _state.copyWith(
          listState: Success([...currentList, ...newList]),
          currentPage: page + 1,
          isEnd: isEnd,
        );
      }
    } else {
      _state = _state.copyWith(listState: listState);
    }

    notifyListeners();
  }

  /// Load more results
  void onLoadMore() {
    if (!_state.isEnd) {
      searchFollows(isRefresh: false);
    }
  }

  /// Refresh search
  Future<void> onRefresh() => searchFollows(isRefresh: true);

  /// Reload search
  Future<void> onReload() => searchFollows(isRefresh: true);

  /// Clear search
  void onClear() {
    editController.clear();
    _state = FollowSearchState(listState: LoadingState.loading());
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    scrollController.dispose();
    editController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
