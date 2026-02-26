import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav_create/data/datasources/fav_folder_remote_datasource.dart';
import 'package:PiliPlus/features/fav_create/domain/entities/fav_folder.dart';
import 'package:PiliPlus/features/fav_create/domain/repositories/fav_folder_repository.dart';
import 'package:PiliPlus/utils/fav_utils.dart';

/// Favorite folder repository implementation
class FavFolderRepositoryImpl implements FavFolderRepository {
  final FavFolderRemoteDataSource remoteDataSource;

  const FavFolderRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<FavFolderEntity>> getFolderInfo(String mediaId) async {
    final result = await remoteDataSource.getFolderInfo(mediaId);

    if (result case Success(:final data)) {
      return Success(
        FavFolderEntity(
          mediaId: mediaId,
          title: data.title,
          intro: data.intro,
          cover: data.cover,
          attr: data.attr,
          isPublic: FavUtils.isPublicFav(data.attr),
        ),
      );
    } else {
      return result as Error;
    }
  }

  @override
  Future<LoadingState<String>> createOrEditFolder(
    FavFolderParamsEntity params,
  ) async {
    final result = await remoteDataSource.addOrEditFolder(
      isAdd: params.isAdd,
      mediaId: params.mediaId,
      title: params.title,
      privacy: params.isPublic ? 0 : 1,
      cover: params.cover ?? '',
      intro: params.intro ?? '',
    );

    if (result case Success(:final data)) {
      return Success(data.id.toString());
    } else {
      return result as Error;
    }
  }

  @override
  Future<LoadingState<String>> uploadCover(String imagePath) async {
    final result = await remoteDataSource.uploadImage(
      path: imagePath,
      bucket: 'medialist',
      dir: 'cover',
    );

    if (result case Success(:final data)) {
      return Success(data['location']?.toString() ?? '');
    } else {
      return result as Error;
    }
  }
}
