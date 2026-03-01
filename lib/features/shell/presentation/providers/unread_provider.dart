import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_dynamic.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_message.dart';
import 'package:PiliPlus/features/shell/domain/usecases/check_unread_dynamics.dart';
import 'package:PiliPlus/features/shell/domain/usecases/check_unread_messages.dart';
import 'package:PiliPlus/features/shell/presentation/providers/shell_providers.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/msg/msg_unread_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 未读消息 Controller
class UnreadMessageController extends Notifier<UnreadMessage> {
  late final CheckUnreadMessagesUseCase _useCase;
  int _lastCheckTime = 0;

  @override
  UnreadMessage build() {
    _useCase = ref.read(checkUnreadMessagesUseCaseProvider);
    return const UnreadMessage.zero();
  }

  /// 获取未读消息
  Future<void> fetchUnread() async {
    final result = await _useCase.getUnreadMessage();
    state = result;
    _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 检查是否需要更新
  Future<void> checkIfNeeded() async {
    final result = await _useCase.checkUnread(_lastCheckTime);
    if (result != null) {
      state = result;
      _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 清除未读
  void clear() {
    state = const UnreadMessage.zero();
  }

  /// 重置检查时间
  void resetCheckTime() {
    _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }
}

/// 未读消息 Provider
final unreadMessageControllerProvider =
    NotifierProvider<UnreadMessageController, UnreadMessage>(
      UnreadMessageController.new,
    );

/// 未读动态 Controller
class UnreadDynamicController extends Notifier<UnreadDynamic> {
  late final CheckUnreadDynamicsUseCase _useCase;
  int _lastCheckTime = 0;

  @override
  UnreadDynamic build() {
    _useCase = ref.read(checkUnreadDynamicsUseCaseProvider);
    return const UnreadDynamic.zero();
  }

  /// 获取未读动态
  Future<void> fetchUnread() async {
    final result = await _useCase.getUnreadDynamic();
    state = result;
    _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }

  /// 检查是否需要更新
  Future<void> checkIfNeeded({
    required bool checkDynamic,
    required int dynamicPeriod,
  }) async {
    final result = await _useCase.checkUnread(
      checkDynamic: checkDynamic,
      dynamicPeriod: dynamicPeriod,
      lastCheckTime: _lastCheckTime,
    );

    if (result != null) {
      state = result;
      _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  /// 设置未读数
  void setCount(int count) {
    state = UnreadDynamic(count: count);
  }

  /// 清除未读
  void clear() {
    state = const UnreadDynamic.zero();
  }

  /// 重置检查时间
  void resetCheckTime() {
    _lastCheckTime = DateTime.now().millisecondsSinceEpoch;
  }
}

/// 未读动态 Provider
final unreadDynamicControllerProvider =
    NotifierProvider<UnreadDynamicController, UnreadDynamic>(
      UnreadDynamicController.new,
    );

/// 消息未读类型配置
final msgUnreadTypesProvider = Provider<Set<MsgUnReadType>>((ref) {
  return Pref.msgUnReadTypeV2;
});

/// 消息角标模式配置
final msgBadgeModeProvider = Provider<DynamicBadgeMode>((ref) {
  return Pref.msgBadgeMode;
});

/// 是否显示消息角标
bool showMsgBadge(DynamicBadgeMode mode) {
  return mode != DynamicBadgeMode.hidden;
}

/// 是否显示动态角标
bool showDynBadge(DynamicBadgeMode mode) {
  return mode != DynamicBadgeMode.hidden;
}
