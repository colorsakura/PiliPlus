import 'package:PiliPlus/features/music/data/datasources/music_api_datasource.dart' as impl;
import 'package:PiliPlus/features/music/data/datasources/music_remote_datasource_interface.dart';
import 'package:PiliPlus/features/music/data/repositories/music_repository_impl.dart';
import 'package:PiliPlus/features/music/domain/repositories/music_repository.dart';
import 'package:PiliPlus/features/music/domain/usecases/get_music_detail.dart';
import 'package:PiliPlus/features/music/domain/usecases/get_music_recommendations.dart';
import 'package:PiliPlus/features/music/domain/usecases/update_music_favorite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Music remote data source adapter
class _MusicRemoteDataSourceAdapter implements MusicRemoteDataSource {
  final impl.MusicRemoteDataSource _dataSource;

  const _MusicRemoteDataSourceAdapter(this._dataSource);

  @override
  Future<Map<String, dynamic>> getBgmDetail(String musicId) {
    return _dataSource.bgmDetail(musicId);
  }

  @override
  Future<void> updateWishStatus({
    required String musicId,
    required bool hasLike,
  }) {
    return _dataSource.wishUpdate(musicId, hasLike);
  }

  @override
  Future<List<dynamic>?> getBgmRecommend(String musicId) {
    return _dataSource.bgmRecommend(musicId);
  }
}

/// Music remote data source provider
final musicRemoteDataSourceProvider = Provider<MusicRemoteDataSource>((ref) {
  return _MusicRemoteDataSourceAdapter(
    impl.MusicRemoteDataSource(),
  );
});

/// Music repository provider
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final remoteDataSource = ref.watch(musicRemoteDataSourceProvider);
  return MusicRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Get music detail use case provider
final getMusicDetailUseCaseProvider = Provider<GetMusicDetail>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return GetMusicDetail(repository);
});

/// Update music favorite use case provider
final updateMusicFavoriteUseCaseProvider = Provider<UpdateMusicFavorite>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return UpdateMusicFavorite(repository);
});

/// Get music recommendations use case provider
final getMusicRecommendationsUseCaseProvider = Provider<GetMusicRecommendations>((ref) {
  final repository = ref.watch(musicRepositoryProvider);
  return GetMusicRecommendations(repository);
});
