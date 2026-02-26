import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart' show DetailItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Use case for fetching audio playlist
class FetchAudioPlaylist {
  final AudioRepository repository;

  const FetchAudioPlaylist(this.repository);

  Future<LoadingState<List<DetailItem>?>> call(FetchAudioPlaylistParams params) =>
      repository.fetchPlaylist(params);
}
