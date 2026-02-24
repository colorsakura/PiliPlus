import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';

/// Repository interface for live emote
abstract class LiveEmoteRepository {
  /// Fetch live emote icons for a room
  Future<LoadingState<List<LiveEmoteDatum>?>> getLiveEmoticons(int roomId);
}
