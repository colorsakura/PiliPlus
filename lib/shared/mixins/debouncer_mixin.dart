/// 防抖 Mixin
///
/// 为控制器提供防抖功能
library;

import 'dart:async';
import 'package:flutter/widgets.dart';

/// 防抖 Mixin
///
/// 用于延迟执行操作，避免频繁触发
mixin DebouncerMixin on ChangeNotifier {
  final Map<String, Timer> _timers = {};

  /// 防抖执行
  ///
  /// [key] - 操作的唯一标识
  /// [delay] - 延迟时间
  /// [action] - 要执行的操作
  void debounce(
    String key,
    Duration delay,
    VoidCallback action,
  ) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, action);
  }

  /// 取消指定操作
  void cancelDebounce(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// 取消所有操作
  void cancelAllDebouncers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    cancelAllDebouncers();
    super.dispose();
  }
}
