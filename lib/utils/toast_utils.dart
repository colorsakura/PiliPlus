/// Toast 工具类
///
/// 提供统一的 Toast 消息显示功能
library;

import 'package:flutter/material.dart' as FlutterMaterial show showDialog;
import 'package:flutter/material.dart';
import 'overlay_entry_manager.dart';

/// Toast 工具类
class ToastUtils {
  ToastUtils._();

  static OverlayEntry? _toastEntry;
  static OverlayEntry? _loadingEntry;

  /// 显示 Toast 消息
  ///
  /// [msg] 要显示的消息内容
  /// [duration] 显示时长，默认2秒
  static Future<void> showToast(
    String msg, {
    Duration duration = const Duration(seconds: 2),
  }) async {
    // 移除之前的 toast
    dismissToast();

    final overlay = OverlayEntryManager.overlay;
    if (overlay == null) {
      debugPrint('ToastUtils: No overlay found');
      return;
    }

    _toastEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: msg,
        onDisposed: () => _toastEntry = null,
      ),
    );

    overlay.insert(_toastEntry!);

    // 自动移除
    await Future.delayed(duration, () {
      dismissToast();
    });
  }

  /// 显示 Loading
  ///
  /// [msg] 加载提示信息
  static void showLoading({String msg = '加载中...'}) {
    // 如果已经在显示loading，不重复创建
    if (_loadingEntry != null) {
      return;
    }

    final overlay = OverlayEntryManager.overlay;
    if (overlay == null) {
      debugPrint('ToastUtils: No overlay found');
      return;
    }

    _loadingEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        message: msg,
        onDisposed: () => _loadingEntry = null,
      ),
    );

    overlay.insert(_loadingEntry!);
  }

  /// 关闭 Loading
  static void dismiss() {
    if (_loadingEntry != null) {
      _loadingEntry?.remove();
      _loadingEntry = null;
    }
  }

  /// 关闭 Toast
  static void dismissToast() {
    if (_toastEntry != null) {
      _toastEntry?.remove();
      _toastEntry = null;
    }
  }

  /// 检查是否有弹窗显示
  static bool checkExist() {
    return _toastEntry != null || _loadingEntry != null;
  }

  /// 显示对话框
  ///
  /// [builder] 对话框内容构建器
  /// [barrierDismissible] 点击外部是否关闭，默认true
  static Future<T?> showDialog<T>({
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    final buildContext = OverlayEntryManager.context;
    if (buildContext == null) {
      debugPrint('ToastUtils: No context found');
      return Future.value(null);
    }

    // Ignore the unused future
    // ignore: unused_result
    return FlutterMaterial.showDialog(
      context: buildContext,
      builder: builder,
      barrierDismissible: barrierDismissible,
    );
  }
}

/// Toast Widget
class _ToastWidget extends StatelessWidget {
  final String message;
  final VoidCallback onDisposed;

  const _ToastWidget({
    required this.message,
    required this.onDisposed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Positioned(
      bottom: MediaQuery.viewPaddingOf(context).bottom + 30,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(
              alpha: _CustomToast.toastOpacity,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading Widget
class _LoadingWidget extends StatelessWidget {
  final String message;
  final VoidCallback onDisposed;

  const _LoadingWidget({
    required this.message,
    required this.onDisposed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        decoration: BoxDecoration(
          color: theme.dialogTheme.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // loading animation
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            // msg
            Text(message, style: TextStyle(color: onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _CustomToast {
  static double toastOpacity = 0.9;
}
