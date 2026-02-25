import 'dart:async';

import 'package:PiliPlus/features/shell/domain/usecases/check_unread_dynamics.dart';
import 'package:PiliPlus/features/shell/domain/usecases/check_unread_messages.dart';

/// 定时检查调度器
///
/// 负责协调定时任务的执行，替代原有的 NetworkManager
class PeriodicCheckScheduler {
  final CheckUnreadMessagesUseCase _checkMessages;
  final CheckUnreadDynamicsUseCase _checkDynamics;

  Timer? _periodicTimer;

  // 定时检查间隔：5分钟
  static const Duration _checkInterval = Duration(minutes: 5);

  // 状态跟踪
  int _lastMessageCheckTime = 0;
  int _lastDynamicCheckTime = 0;

  // 配置
  bool _checkDynamic = true;
  int _dynamicPeriod = 5 * 60 * 1000; // 5分钟

  PeriodicCheckScheduler({
    required CheckUnreadMessagesUseCase checkMessages,
    required CheckUnreadDynamicsUseCase checkDynamics,
  }) : _checkMessages = checkMessages,
       _checkDynamics = checkDynamics;

  /// 配置动态检查参数
  void configureDynamicCheck({
    required bool enabled,
    required int periodMs,
  }) {
    _checkDynamic = enabled;
    _dynamicPeriod = periodMs;
  }

  /// 启动定时检查
  void start() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(_checkInterval, (_) {
      performPeriodicChecks();
    });
  }

  /// 停止定时检查
  void stop() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// 执行定期检查
  Future<void> performPeriodicChecks() async {
    // 并行执行所有检查任务
    await Future.wait([
      _checkMessages.checkUnread(_lastMessageCheckTime).then((result) {
        if (result != null) {
          _lastMessageCheckTime = DateTime.now().millisecondsSinceEpoch;
        }
      }),
      _checkDynamics
          .checkUnread(
            checkDynamic: _checkDynamic,
            dynamicPeriod: _dynamicPeriod,
            lastCheckTime: _lastDynamicCheckTime,
          )
          .then((result) {
            if (result != null) {
              _lastDynamicCheckTime = DateTime.now().millisecondsSinceEpoch;
            }
          }),
    ]);
  }

  /// 手动触发消息检查
  Future<void> triggerMessageCheck() async {
    final result = await _checkMessages.checkUnread(_lastMessageCheckTime);
    if (result != null) {
      _lastMessageCheckTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 手动触发动态检查
  Future<void> triggerDynamicCheck() async {
    final result = await _checkDynamics.checkUnread(
      checkDynamic: _checkDynamic,
      dynamicPeriod: _dynamicPeriod,
      lastCheckTime: _lastDynamicCheckTime,
    );
    if (result != null) {
      _lastDynamicCheckTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 释放资源
  void dispose() {
    stop();
  }
}
