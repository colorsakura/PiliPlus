import 'package:PiliPlus/http/loading_state.dart';

/// Live repository interface
abstract class LiveRepository {
  /// Send live danmaku message
  Future<LoadingState<void>> sendLiveDanmaku({
    required Object roomId,
    required Object msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  });

  /// Get live room play info
  Future<LoadingState<Map<String, dynamic>>> getLiveRoomInfo({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  });

  /// Get live room info (H5)
  Future<LoadingState<Map<String, dynamic>>> getLiveRoomInfoH5({
    required Object roomId,
  });

  /// Get live room danmaku prefetch
  Future<LoadingState<List<dynamic>?>> getLiveRoomDanmakuPrefetch({
    required Object roomId,
  });
}
