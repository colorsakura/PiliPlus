/// Overlay 管理器
///
/// 用于全局管理 OverlayEntry，提供统一的访问入口
library;

import 'package:flutter/material.dart';
import 'package:PiliPlus/app/app.dart';

/// Overlay 管理器
class OverlayEntryManager {
  OverlayEntryManager._();

  /// 获取全局 OverlayState
  static OverlayState? get overlay {
    final context = MyApp.rootNavigatorKey.currentContext;
    if (context == null) return null;

    return Overlay.of(context);
  }

  /// 获取全局 BuildContext
  static BuildContext? get context => MyApp.rootNavigatorKey.currentContext;
}
