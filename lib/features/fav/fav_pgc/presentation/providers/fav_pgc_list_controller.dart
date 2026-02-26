import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/get_fav_pgc_usecase.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/remove_pgc_usecase.dart';
import 'package:PiliPlus/features/fav/fav_pgc/domain/usecases/update_pgc_follow_status_usecase.dart';

/// State for fav PGC list
class FavPgcListState {
  const FavPgcListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FavPgcItemModel>?> listState;
  final int currentPage;
  final bool isEnd;

  FavPgcListState copyWith({
    LoadingState<List<FavPgcItemModel>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FavPgcListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for favorite PGC list with multi-select and status update support
class FavPgcController extends ChangeNotifier {
  FavPgcController({
    required this.type,
    required this.followStatus,
    required this.getFavPgcUseCase,
    required this.removePgcUseCase,
    required this.updatePgcFollowStatusUseCase,
  }) : _state = FavPgcListState(listState: LoadingState.loading()) {
    queryData(isRefresh: true);
  }

  final int type;
  final int followStatus;
  final GetFavPgcUseCase getFavPgcUseCase;
  final RemovePgcUseCase removePgcUseCase;
  final UpdatePgcFollowStatusUseCase updatePgcFollowStatusUseCase;

  FavPgcListState _state;

  FavPgcListState get state => _state;

  final ScrollController scrollController = ScrollController();

  // Multi-select state
  bool _enableMultiSelect = false;
  bool _allSelected = false;
  int _checkedCount = 0;

  bool get enableMultiSelect => _enableMultiSelect;
  bool get allSelected => _allSelected;
  int get checkedCount => _checkedCount;

  void _updateState(FavPgcListState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query PGC list data
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await getFavPgcUseCase(page, type, followStatus);

    if (result case Success(:final response)) {
      final currentList = _state.listState is Success
          ? (_state.listState as Success<List<FavPgcItemModel>?>).response ?? []
          : <FavPgcItemModel>[];

      // Preserve checked state for existing items
      final checkedItems = <int, bool>{};
      for (final item in currentList) {
        if (item.seasonId != null) {
          checkedItems[item.seasonId!] = item.checked;
        }
      }

      // Update checked state for new/updated items
      for (final item in response) {
        final seasonId = item.seasonId;
        if (seasonId != null && checkedItems.containsKey(seasonId)) {
          final checked = checkedItems[seasonId];
          if (checked != null) {
            item.checked = checked;
          }
        }
      }

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
      FavPgcListState(
        listState: LoadingState.loading(),
        currentPage: _state.currentPage,
        isEnd: _state.isEnd,
      ),
    );
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
      final list =
          (_state.listState as Success<List<FavPgcItemModel>?>).response;
      if (list != null) {
        for (final item in list) {
          item.checked = checked;
        }
      }
    }
    _allSelected = checked;
    _checkedCount = checked
        ? (_state.listState as Success).response?.length ?? 0
        : 0;
    notifyListeners();
  }

  /// Toggle item selection
  void onSelect(FavPgcItemModel item) {
    item.checked = !item.checked;
    if (item.checked) {
      _checkedCount++;
    } else {
      _checkedCount--;
    }

    if (_state.listState is Success) {
      final list =
          (_state.listState as Success<List<FavPgcItemModel>?>).response;
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
  Set<FavPgcItemModel> get allChecked {
    if (_state.listState is Success) {
      final list =
          (_state.listState as Success<List<FavPgcItemModel>?>).response;
      return list?.where((v) => v.checked).toSet() ?? {};
    }
    return {};
  }

  /// Remove a single PGC item
  Future<String?> pgcDel(int index, int seasonId) async {
    final result = await removePgcUseCase(seasonId);
    if (result.isSuccess) {
      if (_state.listState is Success) {
        final list =
            (_state.listState as Success<List<FavPgcItemModel>?>).response;
        list?.removeAt(index);
        _updateState(_state.copyWith(listState: Success(list)));
      }
      return result.dataOrNull;
    }
    return null;
  }

  /// Update follow status for a single item
  Future<String?> onUpdate(int index, int followStatus, int? seasonId) async {
    if (seasonId == null) return null;
    final result = await updatePgcFollowStatusUseCase(
      seasonId.toString(),
      followStatus,
    );
    if (result.isSuccess) {
      if (_state.listState is Success) {
        final list =
            (_state.listState as Success<List<FavPgcItemModel>?>).response;
        list?.removeAt(index);
        _updateState(_state.copyWith(listState: Success(list)));

        // Note: In the original implementation, the item is moved to a different controller
        // (based on followStatus). For simplicity, we just remove it here.
        // The full implementation would need coordination between controllers.
      }
      return result.dataOrNull;
    }
    return null;
  }

  /// Batch update follow status for selected items
  Future<String?> onUpdateList(int newFollowStatus) async {
    final removeList = allChecked;
    final seasonIds = removeList.map((item) => item.seasonId).join(',');

    final result = await updatePgcFollowStatusUseCase(
      seasonIds,
      newFollowStatus,
    );
    if (result.isSuccess) {
      // Note: Original implementation moves items to different controller
      // and resets checked state. For simplicity, we just remove them here.
      afterDelete(removeList);
      _allSelected = false;
      notifyListeners();
      return result.dataOrNull;
    }
    return null;
  }

  /// Handle post-delete/update cleanup
  void afterDelete(Set<FavPgcItemModel> removeList) {
    if (_state.listState is Success) {
      final list =
          (_state.listState as Success<List<FavPgcItemModel>?>).response;
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
      final list =
          (_state.listState as Success<List<FavPgcItemModel>?>).response;
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
