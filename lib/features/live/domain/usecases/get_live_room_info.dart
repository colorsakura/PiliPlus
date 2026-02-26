import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live/domain/repositories/live_repository.dart';

/// Get live room info use case
class GetLiveRoomInfo {
  final LiveRepository repository;

  const GetLiveRoomInfo(this.repository);

  Future<LoadingState<Map<String, dynamic>>> call({
    required Object roomId,
    Object? qn,
    bool onlyAudio = false,
  }) {
    return repository.getLiveRoomInfo(
      roomId: roomId,
      qn: qn,
      onlyAudio: onlyAudio,
    );
  }
}
