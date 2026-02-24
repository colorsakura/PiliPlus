import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Mixin for list controllers with pagination support
///
/// This mixin provides common pagination functionality for controllers
/// that need to load paginated data.
///
/// Generic types:
/// - T: The individual item type in the list
mixin ListControllerMixin<T> on Notifier<LoadingState<List<T>?>> {
  int _page = 1;
  bool _isEnd = false;
  bool _isLoading = false;

  /// Current page number
  int get page => _page;

  /// Whether we've reached the end of the list
  bool get isEnd => _isEnd;

  /// Whether data is currently loading
  bool get isLoading => _isLoading;

  /// Load data with pagination support
  ///
  /// [fetchData] - Function to fetch data for the given page
  /// [isRefresh] - Whether this is a refresh operation (reset to page 1)
  Future<void> loadData(
    Future<LoadingState<List<T>>> Function(int page) fetchData, {
    bool isRefresh = true,
  }) async {
    if (_isLoading || (!isRefresh && _isEnd)) return;

    _isLoading = true;
    final currentPage = isRefresh ? 1 : _page;

    try {
      final result = await fetchData(currentPage);

      if (result is Loading) {
        if (isRefresh) {
          state = LoadingState.loading();
        }
      } else if (result is Error) {
        if (isRefresh) {
          state = result;
        }
      } else if (result is Success<List<T>>) {
        final dataList = result.response;

        if (dataList.isEmpty) {
          _isEnd = true;
          if (isRefresh) {
            state = Success(dataList);
          }
        } else {
          if (isRefresh) {
            state = Success(dataList);
            _checkIsEnd(dataList.length);
          } else if (state is Success<List<T>?>) {
            final currentState = state as Success<List<T>?>;
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            state = Success(updatedList);
            _checkIsEnd(updatedList.length);
          }
        }
      }

      if (!isRefresh) {
        _page++;
      }
    } finally {
      _isLoading = false;
    }
  }

  /// Check if we've reached the end of the list
  /// Override this to implement custom end detection logic
  void _checkIsEnd(int length) {
    // Default implementation: no automatic end detection
    // Subclasses can override this
  }

  /// Reset to page 1
  void resetPagination() {
    _page = 1;
    _isEnd = false;
  }

  /// Mark list as ended
  void markAsEnd() {
    _isEnd = true;
  }
}

/// Base class for list controllers with pagination
///
/// This class provides a foundation for controllers that manage paginated lists.
/// Extend this class and implement the [fetchData] method.
///
/// Example usage:
/// ```dart
/// class MyController extends BaseListController<MyItem> {
///   @override
///   Future<LoadingState<List<MyItem>>> fetchData(int page) async {
///     return await myRepository.getItems(page: page);
///   }
/// }
/// ```
abstract class BaseListController<T> extends Notifier<LoadingState<List<T>?>>
    with ListControllerMixin<T> {
  @override
  LoadingState<List<T>?> build() {
    return LoadingState.loading();
  }

  /// Fetch data for the specified page
  ///
  /// Subclasses must implement this method to provide the actual data fetching logic.
  Future<LoadingState<List<T>>> fetchData(int page);

  /// Load data with optional refresh
  Future<void> loadItems({bool isRefresh = true}) {
    return loadData(fetchData, isRefresh: isRefresh);
  }

  /// Refresh the list (reset to page 1)
  Future<void> onRefresh() {
    resetPagination();
    return loadItems(isRefresh: true);
  }

  /// Reload the current page
  Future<void> onReload() {
    state = LoadingState.loading();
    return loadItems(isRefresh: true);
  }

  /// Load more items (next page)
  Future<void> onLoadMore() {
    return loadItems(isRefresh: false);
  }
}
