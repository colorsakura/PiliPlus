import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';

/// Remote data source for live emote
class LiveEmoteRemoteDatasource {
  const LiveEmoteRemoteDatasource();

  /// Fetch live emote icons for a room
  Future<LoadingState<List<LiveEmoteDatum>?>> getLiveEmoticons(int roomId) =>
      LiveHttp.getLiveEmoticons(roomId: roomId);
}
