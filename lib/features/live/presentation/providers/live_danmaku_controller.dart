import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/live/domain/usecases/send_live_danmaku.dart';
import 'package:PiliPlus/features/live/presentation/providers/live_room_controller.dart';
import 'package:PiliPlus/http/loading_state.dart';

part 'live_danmaku_controller.g.dart';

/// Provider for SendLiveDanmaku use case
final sendLiveDanmakuProvider = Provider<SendLiveDanmaku>((ref) {
  final repository = ref.watch(liveRepositoryProvider);
  return SendLiveDanmaku(repository);
});

/// Live Danmaku state
class LiveDanmakuState {
  final bool isSending;
  final String? errorMessage;
  final String? lastSentMessage;

  const LiveDanmakuState({
    this.isSending = false,
    this.errorMessage,
    this.lastSentMessage,
  });

  LiveDanmakuState copyWith({
    bool? isSending,
    String? errorMessage,
    String? lastSentMessage,
  }) {
    return LiveDanmakuState(
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSentMessage: lastSentMessage ?? this.lastSentMessage,
    );
  }
}

/// Controller for managing live danmaku (chat messages)
@riverpod
class LiveDanmakuController extends _$LiveDanmakuController {
  @override
  LiveDanmakuState build() {
    return const LiveDanmakuState();
  }

  /// Send danmaku to live room
  Future<bool> sendDanmaku({
    required Object roomId,
    required String msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) async {
    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      final sendDanmaku = ref.read(sendLiveDanmakuProvider);
      final result = await sendDanmaku(
        roomId: roomId,
        msg: msg,
        dmType: dmType,
        emoticonOptions: emoticonOptions,
        replyMid: replyMid,
        replayDmid: replayDmid,
      );

      switch (result) {
        case Success():
          state = state.copyWith(
            isSending: false,
            lastSentMessage: msg,
            errorMessage: null,
          );
          return true;
        case Error(:final errMsg):
          state = state.copyWith(
            isSending: false,
            errorMessage: errMsg,
          );
          return false;
        case Loading():
          state = state.copyWith(isSending: false);
          return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear state
  void clearState() {
    state = const LiveDanmakuState();
  }
}
