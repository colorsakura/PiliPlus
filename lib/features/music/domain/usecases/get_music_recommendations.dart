import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/music/domain/entities/music_detail.dart';
import 'package:PiliPlus/features/music/domain/repositories/music_repository.dart';

/// Get music recommendations use case
class GetMusicRecommendations {
  final MusicRepository repository;

  const GetMusicRecommendations(this.repository);

  Future<LoadingState<List<MusicRecommendEntity>>> call(String musicId) {
    return repository.getMusicRecommendations(musicId);
  }
}
