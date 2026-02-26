import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/music/domain/entities/music_detail.dart';

/// Music repository interface
abstract class MusicRepository {
  /// Get music detail by music ID
  Future<LoadingState<MusicDetailEntity>> getMusicDetail(String musicId);

  /// Update music favorite status
  Future<LoadingState<void>> updateFavoriteStatus({
    required String musicId,
    required bool isFavorite,
  });

  /// Get music recommendations
  Future<LoadingState<List<MusicRecommendEntity>>> getMusicRecommendations(String musicId);
}
