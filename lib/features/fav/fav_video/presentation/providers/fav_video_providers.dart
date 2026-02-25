import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/fav/fav_video/data/datasources/fav_video_remote_datasource.dart';
import 'package:PiliPlus/features/fav/fav_video/data/repositories/fav_video_repository_impl.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/repositories/fav_video_repository.dart';
import 'package:PiliPlus/features/fav/fav_video/domain/usecases/get_fav_folders_usecase.dart';
import 'package:PiliPlus/features/fav/fav_video/presentation/providers/fav_video_list_controller.dart';

/// Provider for FavVideoRemoteDatasource
final favVideoRemoteDatasourceProvider = Provider<FavVideoRemoteDatasource>((
  ref,
) {
  return FavVideoRemoteDatasource();
});

/// Provider for FavVideoRepository
final favVideoRepositoryProvider = Provider<FavVideoRepository>((ref) {
  final datasource = ref.watch(favVideoRemoteDatasourceProvider);
  return FavVideoRepositoryImpl(datasource);
});

/// Provider for GetFavFoldersUseCase
final getFavFoldersUseCaseProvider = Provider<GetFavFoldersUseCase>((ref) {
  final repository = ref.watch(favVideoRepositoryProvider);
  return GetFavFoldersUseCase(repository);
});

/// Provider for FavVideoController
final favVideoControllerProvider = Provider<FavVideoController>((ref) {
  return FavVideoController(
    getFavFoldersUseCase: ref.watch(getFavFoldersUseCaseProvider),
  );
});
