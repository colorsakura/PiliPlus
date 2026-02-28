import 'package:PiliPlus/core/constants/constants.dart' show StyleString;
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class CommonPageState<T extends StatefulWidget> extends State<T> {
  RxDouble? _barOffset;
  RxBool? _showTopBar;
  RxBool? _showBottomBar;

  // NOTE: MainController has been removed. Bar hiding functionality is now
  // managed locally. Pages that need scroll-based bar hiding should implement
  // their own scroll notification listeners.

  @override
  void initState() {
    super.initState();
    // Bar offset and show/hide states are no longer initialized from MainController
    // Subclasses can initialize them locally if needed
  }

  Widget onBuild(Widget child) {
    if (_barOffset != null) {
      return NotificationListener<ScrollNotification>(
        onNotification: onNotificationType2,
        child: child,
      );
    }
    if (_showTopBar != null || _showBottomBar != null) {
      return NotificationListener<UserScrollNotification>(
        onNotification: onNotificationType1,
        child: child,
      );
    }
    return child;
  }

  bool onNotificationType1(UserScrollNotification notification) {
    // Check if this page should handle scroll-based bar hiding
    if (!shouldHandleScrollBars()) return false;
    if (notification.metrics.axis == Axis.horizontal) return false;
    switch (notification.direction) {
      case .forward:
        _showTopBar?.value = true;
        _showBottomBar?.value = true;
      case .reverse:
        _showTopBar?.value = false;
        _showBottomBar?.value = false;
      case _:
    }
    return false;
  }

  void _updateOffset(double scrollDelta) {
    _barOffset!.value = clampDouble(
      _barOffset!.value + scrollDelta,
      0.0,
      StyleString.topBarHeight,
    );
  }

  bool onNotificationType2(ScrollNotification notification) {
    if (!shouldHandleScrollBars()) return false;

    if (notification.metrics.axis == Axis.horizontal) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.dragDetails == null) return false;
      _updateOffset(notification.scrollDelta ?? 0.0);
      return false;
    }

    if (notification is OverscrollNotification) {
      _updateOffset(notification.overscroll);
      return false;
    }

    return false;
  }

  /// Override this in subclasses to determine if this page should handle
  /// scroll-based bar hiding. MinePage returns false since state is managed
  /// by StatefulShellRoute.
  bool shouldHandleScrollBars() => false;

  @override
  void dispose() {
    _barOffset = null;
    _showTopBar = null;
    _showBottomBar = null;
    super.dispose();
  }
}
