import 'package:PiliPlus/features/fav_create/data/datasources/fav_folder_remote_datasource.dart';
import 'package:PiliPlus/features/fav_create/data/repositories/fav_folder_repository_impl.dart';
import 'package:PiliPlus/features/fav_create/domain/repositories/fav_folder_repository.dart';
import 'package:PiliPlus/features/fav_create/domain/usecases/fav_folder_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Favorite folder remote data source provider
final favFolderRemoteDataSourceProvider = Provider<FavFolderRemoteDataSource>((ref) {
  return const FavFolderRemoteDataSourceImpl();
});

/// Favorite folder repository provider
final favFolderRepositoryProvider = Provider<FavFolderRepository>((ref) {
  final remoteDataSource = ref.watch(favFolderRemoteDataSourceProvider);
  return FavFolderRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

/// Get favorite folder info use case provider
final getFavFolderInfoUseCaseProvider = Provider<GetFavFolderInfo>((ref) {
  final repository = ref.watch(favFolderRepositoryProvider);
  return GetFavFolderInfo(repository);
});

/// Create or edit favorite folder use case provider
final createOrEditFavFolderUseCaseProvider = Provider<CreateOrEditFavFolder>((ref) {
  final repository = ref.watch(favFolderRepositoryProvider);
  return CreateOrEditFavFolder(repository);
});

/// Upload favorite folder cover use case provider
final uploadFavCoverUseCaseProvider = Provider<UploadFavCover>((ref) {
  final repository = ref.watch(favFolderRepositoryProvider);
  return UploadFavCover(repository);
});
