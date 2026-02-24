import 'dart:async';

import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Core scroll and refresh mixin for list controllers
///
/// Provides common scroll-to-top and refresh functionality
mixin ScrollOrRefreshMixin {
  ScrollController get scrollController;

  void animateToTop() => scrollController.animToTop();

  Future<void> onRefresh();

  void toTopOrRefresh() {
    if (scrollController.hasClients) {
      if (scrollController.position.pixels == 0) {
        EasyThrottle.throttle(
          'topOrRefresh',
          const Duration(milliseconds: 500),
          onRefresh,
        );
      } else {
        animateToTop();
      }
    }
  }
}

/// Base controller for pages with scrollable lists
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
abstract class CommonController<R, T> extends GetxController
    with ScrollOrRefreshMixin {
  @override
  final ScrollController scrollController = ScrollController();

  bool isLoading = false;
  Rx<LoadingState> get loadingState;

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

  @override
  Future<void> onRefresh() {
    return queryData();
  }

  Future<void> onLoadMore() {
    return queryData(false);
  }

  Future<void> onReload() {
    return onRefresh();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
