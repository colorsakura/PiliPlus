import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/controllers/common_controller_v2.dart';

/// Base controller for paginated list pages (Riverpod version)
///
/// Provides pagination, list data handling, and loading state management.
/// This is the Riverpod equivalent of the GetX CommonListController.
///
/// Generic types:
/// - R: The raw API response type
/// - T: The individual item type in the list
abstract class CommonListControllerV2<R, T> extends CommonControllerV2<R, T> {
  int page = 1;
  bool isEnd = false;
  bool? hasFooter;

  @override
  LoadingState<List<T>?> loadingState = LoadingState<List<T>?>.loading();

  /// Hook for subclasses to handle the response data list
  void handleListResponse(List<T> dataList) {}

  /// Extract the data list from the API response.
  /// Override this if response is not directly a List<T>
  List<T>? getDataList(R response) {
    return response as List<T>?;
  }

  /// Check if we've reached the end of the list
  /// Override to implement custom end detection logic
  void checkIsEnd(int length) {}

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (isLoading || (!isRefresh && isEnd)) return;
    isLoading = true;
    notifyListeners();

    final LoadingState<R> res = await customGetData();

    if (res case Success(:final response)) {
      if (!customHandleResponse(isRefresh, res)) {
        final dataList = getDataList(response);
        if (dataList == null || dataList.isEmpty) {
          isEnd = true;
          if (isRefresh) {
            loadingState = Success(dataList);
          } else if (hasFooter == true) {
            // Refresh to show empty state
            notifyListeners();
          }
          isLoading = false;
          notifyListeners();
          return;
        }
        handleListResponse(dataList);
        if (isRefresh) {
          checkIsEnd(dataList.length);
          loadingState = Success(dataList);
        } else if (loadingState case Success(:final response)) {
          final currentList = response!;
          final combinedList = [...currentList, ...dataList];
          checkIsEnd(combinedList.length);
          loadingState = Success(combinedList);
        }
      }
      page++;
    } else {
      if (isRefresh && !handleError(res is Error ? res.errMsg : null)) {
        loadingState = res as Error;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> onRefresh() async {
    page = 1;
    isEnd = false;
    notifyListeners();
    return super.onRefresh();
  }

  @override
  Future<void> onReload() async {
    loadingState = LoadingState<List<T>?>.loading();
    notifyListeners();
    return super.onReload();
  }
}
