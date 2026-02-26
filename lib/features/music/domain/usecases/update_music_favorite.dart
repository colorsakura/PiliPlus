import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/music/domain/repositories/music_repository.dart';

/// Update music favorite status use case
class UpdateMusicFavorite {
  final MusicRepository repository;

  const UpdateMusicFavorite(this.repository);

  Future<LoadingState<void>> call({
    required String musicId,
    required bool isFavorite,
  }) {
    return repository.updateFavoriteStatus(
      musicId: musicId,
      isFavorite: isFavorite,
    );
  }
}
