import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_emote/datum.dart';
import 'package:PiliPlus/features/live_emote/domain/repositories/live_emote_repository.dart';
import 'package:PiliPlus/features/live_emote/data/datasources/live_emote_remote_datasource.dart';

/// Repository implementation for live emote
class LiveEmoteRepositoryImpl implements LiveEmoteRepository {
  const LiveEmoteRepositoryImpl(this._remoteDatasource);

  final LiveEmoteRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<List<LiveEmoteDatum>?>> getLiveEmoticons(int roomId) =>
      _remoteDatasource.getLiveEmoticons(roomId);
}
