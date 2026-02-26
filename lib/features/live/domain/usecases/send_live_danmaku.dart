import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live/domain/repositories/live_repository.dart';

/// Send live danmaku use case
class SendLiveDanmaku {
  final LiveRepository repository;

  const SendLiveDanmaku(this.repository);

  Future<LoadingState<void>> call({
    required Object roomId,
    required Object msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) {
    return repository.sendLiveDanmaku(
      roomId: roomId,
      msg: msg,
      dmType: dmType,
      emoticonOptions: emoticonOptions,
      replyMid: replyMid,
      replayDmid: replayDmid,
    );
  }
}
