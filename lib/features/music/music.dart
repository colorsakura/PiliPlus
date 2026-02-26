// Domain
export 'domain/entities/music_detail.dart' show MusicDetailEntity, MusicCommentEntity, MusicRecommendEntity;
export 'domain/repositories/music_repository.dart' show MusicRepository;
export 'domain/usecases/get_music_detail.dart' show GetMusicDetail;
export 'domain/usecases/get_music_recommendations.dart' show GetMusicRecommendations;
export 'domain/usecases/update_music_favorite.dart' show UpdateMusicFavorite;

// Data
export 'data/datasources/music_remote_datasource_interface.dart' show MusicRemoteDataSource;
export 'data/repositories/music_repository_impl.dart' show MusicRepositoryImpl;

// Presentation
export 'presentation/pages/music_page.dart' show MusicDetailPage;
export 'presentation/pages/music_recommend_page.dart' show MusicRecommendPage;
export 'presentation/providers/music_recommend_controller.dart'
    show MusicRecommendController, MusicRecommendArgs;
export 'presentation/providers/music_providers.dart' show
  musicRemoteDataSourceProvider,
  musicRepositoryProvider,
  getMusicDetailUseCaseProvider,
  updateMusicFavoriteUseCaseProvider,
  getMusicRecommendationsUseCaseProvider;
export 'presentation/pages/music_controller.dart' show MusicDetailController;
