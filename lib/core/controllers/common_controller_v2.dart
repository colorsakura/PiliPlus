import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:easy_debounce/easy_throttle.dart';

/// Core scroll and refresh functionality for list controllers (Riverpod version)
///
/// Provides common functionality:
/// - Scroll controller management
/// - Loading state tracking
/// - Refresh and pagination support
/// - Error handling
///
/// Generic types:
/// - R: The raw API response type
/// - T: The individual item type in the list
abstract class CommonControllerV2<R, T> extends ChangeNotifier {
  CommonControllerV2();

  @override
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
  LoadingState<List<T>?> loadingState = LoadingState<List<T>?>.loading();

  /// Subclasses override this to fetch data from API
  Future<LoadingState<R>> customGetData();

  /// Query data with optional refresh flag
  Future<void> queryData([bool isRefresh = true]);

  /// Handle API response - return true to override default handling
  bool customHandleResponse(bool isRefresh, Success<R> response) {
    return false;
  }

  /// Handle errors - return true to override default error handling
  bool handleError(String? errMsg) {
    return false;
  }

  /// Scroll to top
  void animateToTop() => scrollController.animToTop();

  Future<void> onRefresh() => queryData();

  Future<void> onLoadMore() => queryData(false);

  Future<void> onReload() => onRefresh();

  /// Scroll to top or refresh if already at top
  void toTopOrRefresh() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == 0) {
        EasyThrottle.throttle(
          'topOrRefresh',
          const Duration(milliseconds: 500),
          () => onRefresh(),
        );
      } else {
        animateToTop();
      }
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
