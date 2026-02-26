import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/music/domain/entities/music_detail.dart';
import 'package:PiliPlus/features/music/domain/repositories/music_repository.dart';

/// Get music detail use case
class GetMusicDetail {
  final MusicRepository repository;

  const GetMusicDetail(this.repository);

  Future<LoadingState<MusicDetailEntity>> call(String musicId) {
    return repository.getMusicDetail(musicId);
  }
}
