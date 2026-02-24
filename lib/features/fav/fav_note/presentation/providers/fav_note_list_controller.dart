import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_note/list.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/usecases/get_fav_notes_usecase.dart';
import 'package:PiliPlus/features/fav/fav_note/domain/usecases/remove_notes_usecase.dart';

/// State for fav note list
class FavNoteListState {
  const FavNoteListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FavNoteItemModel>?> listState;
  final int currentPage;
  final bool isEnd;

  FavNoteListState copyWith({
    LoadingState<List<FavNoteItemModel>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavNoteListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite notes list with multi-select support
class FavNoteController extends ChangeNotifier {
  FavNoteController({
    required this.isPublish,
    required this.getFavNotesUseCase,
    required this.removeNotesUseCase,
  }) : _state = FavNoteListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final bool isPublish;
  final GetFavNotesUseCase getFavNotesUseCase;
  final RemoveNotesUseCase removeNotesUseCase;

  FavNoteListState _state;

  FavNoteListState get state => _state;

  final ScrollController scrollController = ScrollController();

  // Multi-select state
  bool _enableMultiSelect = false;
  bool _allSelected = false;
  int _checkedCount = 0;

  bool get enableMultiSelect => _enableMultiSelect;
  bool get allSelected => _allSelected;
  int get checkedCount => _checkedCount;

  void _updateState(FavNoteListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query note list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavNotesUseCase(page, isPublish);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<FavNoteItemModel>?>).response ?? []
          : <FavNoteItemModel>[];

      // Preserve checked state for existing items
      final checkedItems = <String, bool>{};
      for (final item in currentList) {
        final id = isPublish ? item.cvid?.toString() : item.noteId?.toString();
        if (id != null) {
          checkedItems[id] = item.checked;
        }
      }

      // Update checked state for new/updated items
      for (final item in response) {
        final id = isPublish ? item.cvid?.toString() : item.noteId?.toString();
        if (id != null && checkedItems.containsKey(id)) {
          item.checked = checkedItems[id]!;
        }
      }

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
    _updateState(FavNoteListState(
      listState: LoadingState.loading(),
      currentPage: _state.currentPage,
      isEnd: _state.isEnd,
    ));
    await queryData(isRefresh: true);
  }

  /// Toggle multi-select mode
  void setMultiSelectMode(bool enabled) {
    if (!enabled && _checkedCount != 0) {
      handleSelect(checked: false);
    }
    _enableMultiSelect = enabled;
    notifyListeners();
  }

  /// Handle select all / deselect all
  void handleSelect({bool checked = false}) {
    if (_state.listState is Success) {
      final list = (_state.listState as Success<List<FavNoteItemModel>?>).response;
      if (list != null) {
        for (final item in list) {
          item.checked = checked;
        }
      }
    }
    _allSelected = checked;
    _checkedCount = checked ? (_state.listState as Success).response?.length ?? 0 : 0;
    notifyListeners();
  }

  /// Toggle item selection
  void onSelect(FavNoteItemModel item) {
    item.checked = !item.checked;
    if (item.checked) {
      _checkedCount++;
    } else {
      _checkedCount--;
    }

    if (_state.listState is Success) {
      final list = (_state.listState as Success<List<FavNoteItemModel>?>).response;
      if (list != null && list.isNotEmpty) {
        _allSelected = _checkedCount == list.length;
      }
    }

    if (_checkedCount == 0) {
      _enableMultiSelect = false;
    }

    notifyListeners();
  }

  /// Get all checked items
  Set<FavNoteItemModel> get allChecked {
    if (_state.listState is Success) {
      final list = (_state.listState as Success<List<FavNoteItemModel>?>).response;
      return list?.where((v) => v.checked).toSet() ?? {};
    }
    return {};
  }

  /// Remove selected notes
  Future<bool> onRemove() async {
    final removeList = allChecked;
    final result = await removeNotesUseCase(removeList, isPublish);
    if (result.isSuccess) {
      afterDelete(removeList);
      return true;
    }
    return false;
  }

  /// Handle post-delete cleanup
  void afterDelete(Set<FavNoteItemModel> removeList) {
    if (_state.listState is Success) {
      final list = (_state.listState as Success<List<FavNoteItemModel>?>).response;
      if (list != null) {
        if (removeList.length == list.length) {
          list.clear();
        } else if (removeList.length == 1) {
          list.remove(removeList.first);
        } else {
          list.removeWhere(removeList.contains);
        }
      }
    }

    if (_state.listState is Success) {
      final list = (_state.listState as Success<List<FavNoteItemModel>?>).response;
      if (list != null && list.isNotEmpty || _state.isEnd) {
        _updateState(_state.copyWith(listState: Success(list)));
      } else {
        onReload();
      }
    }

    if (_enableMultiSelect) {
      _checkedCount = 0;
      _enableMultiSelect = false;
      _allSelected = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
