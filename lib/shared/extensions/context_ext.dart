/// BuildContext 扩展
///
/// 提供常用的 Context 相关工具方法
library;

import 'package:flutter/material.dart';
import 'package:PiliPlus/shared/data/models/loading_state.dart';

/// BuildContext 扩展
extension ContextExtension on BuildContext {
  /// 获取主题
  ThemeData get theme => Theme.of(this);

  /// 获取文本主题
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// 获取 MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// 获取屏幕尺寸
  Size get screenSize => mediaQuery.size;

  /// 获取屏幕宽度
  double get screenWidth => screenSize.width;

  /// 获取屏幕高度
  double get screenHeight => screenSize.height;

  /// 获取是否为深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// 获取主色调
  Color get primaryColor => theme.colorScheme.primary;

  /// 获取 ScaffoldMessenger
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    return ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// 显示 LoadingState 的错误信息
  void showError(LoadingState state) {
    if (state case Error(:final errMsg)) {
      showSnackBar(errMsg ?? '操作失败');
    }
  }

  /// 隐藏键盘
  void hideKeyboard() {
    final currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  /// 弹出页面
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop(result);
  }

  /// 路由到新页面
  Future<T?> push<T extends Object?>(Route<T> route) {
    return Navigator.of(this).push(route);
  }

  /// 替换当前页面
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute,
  ) {
    return Navigator.of(this).pushReplacement(newRoute);
  }

  /// 替换并清除所有历史页面
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) {
    return Navigator.of(this).pushAndRemoveUntil(newRoute, predicate);
  }
}
