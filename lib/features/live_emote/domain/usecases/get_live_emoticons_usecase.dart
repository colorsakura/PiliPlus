import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';
import 'package:PiliPlus/features/live_emote/domain/repositories/live_emote_repository.dart';

/// Use case for getting live emote icons
class GetLiveEmoticonsUseCase {
  const GetLiveEmoticonsUseCase(this._repository);

  final LiveEmoteRepository _repository;

  Future<LoadingState<List<LiveEmoteDatum>?>> call(int roomId) =>
      _repository.getLiveEmoticons(roomId);
}
