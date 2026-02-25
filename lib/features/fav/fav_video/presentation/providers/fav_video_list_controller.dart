import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_folder/list.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/usecases/get_fav_folders_usecase.dart';

/// State for fav folder list
class FavVideoListState {
  const FavVideoListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FavFolderInfo>?> listState;
  final int currentPage;
  final bool isEnd;

  FavVideoListState copyWith({
    LoadingState<List<FavFolderInfo>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavVideoListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite folders list
class FavVideoController extends ChangeNotifier {
  FavVideoController({
    required this.getFavFoldersUseCase,
  }) : _state = FavVideoListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final GetFavFoldersUseCase getFavFoldersUseCase;

  FavVideoListState _state;

  FavVideoListState get state => _state;

  final ScrollController scrollController = ScrollController();

  void _updateState(FavVideoListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query folder list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavFoldersUseCase(page);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<FavFolderInfo>?>).response ?? []
          : <FavFolderInfo>[];

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
      FavVideoListState(
        listState: LoadingState.loading(),
        currentPage: _state.currentPage,
        isEnd: _state.isEnd,
      ),
    );
    await queryData(isRefresh: true);
  }

  /// Remove a folder from the list
  void removeFolder(int index) {
    if (_state.listState is Success) {
      final currentList =
          (_state.listState as Success<List<FavFolderInfo>?>).response ??
          <FavFolderInfo>[];
      final newList = List<FavFolderInfo>.from(currentList)..removeAt(index);
      _updateState(_state.copyWith(listState: Success(newList)));
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
